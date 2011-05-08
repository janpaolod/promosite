require 'carrierwave/orm/mongoid'
class Promo
  include Mongoid::Document
  include Mongoid::Timestamps

  MIN_DISCOUNT_RATE = 0.2

  # Public fields
  field :name,                   :type => String
  field :permalink,              :type => String
  field :details,                :type => String
  field :manual_code,            :type => String
  field :status,                 :type => Symbol,  :default => :pending
  field :featured,               :type => Boolean, :default => false
  field :price_actual,           :type => Integer
  field :price_discounted,       :type => Integer
  field :quota,                  :type => Integer
  field :countdown_period_start, :type => DateTime
  field :countdown_period_end,   :type => DateTime
  field :coupon_validity_start,  :type => Date
  field :coupon_validity_end,    :type => Date

  # Scope
  scope :countdown_period_start , where(:order => "desc")
  # Associations
  referenced_in   :merchant
  references_many :promo_claims
  references_many :users,           :stored_as => :array, :inverse_of => :promos
  references_many :classifications, :stored_as => :array, :inverse_of => :promos
  references_many :branches,        :stored_as => :array, :inverse_of => :promos

  # Mounted uploaders
  mount_uploader :image, ImageUploader

  # Indexes
  index :permalink, :unique => true
  
  # Private field
  field :_min_period_start, :type => Time, :default => 1.days.from_now

  # Validations
  validates :name,                   :presence => true, :uniqueness => true
  validates :details,                :presence => true
  validates :countdown_period_start, :presence => true
  validates :countdown_period_end,   :presence => true
  validates :coupon_validity_start,  :presence => true
  validates :coupon_validity_end,    :presence => true
  validates :price_actual,           :presence => true
  validates :price_discounted,       :presence => true
  validate  :minimum_discount
  validate  :code_should_be_8_characters_or_nothing
  validate  :branches_cannot_be_empty
  validate  :valid_countdown_period_start
  validate  :valid_countdown_period_end
  validate  :valid_coupon_validity_start
  validate  :min_validity_end

  # Scopes
  scope :ending_in_24_hours, where(:countdown_period_end.lte => 24.hours.from_now)
  scope :not_expired, where(:countdown_period_start.lte => Time.now,
                            :countdown_period_end.gte => Time.now,
                            :status => :active)
  scope :pending, where(:status => :pending)

  # Autosuggest period_start, period_end, and validity_start
  def initialize(options = {})
    super(options)
    self.countdown_period_start = options[:period_start] || min_period_start
    self.countdown_period_end   = options[:period_end]   || min_period_end
    self.coupon_validity_start  = 
      options[:coupon_validity_start]  || min_max_validity_start
  end

  # Create permalink just before saving
  before_save do |promo|
    promo.permalink = promo.name.parameterize
    promo.manual_code = Promo.random_code if promo.manual_code.blank?
  end

  def to_param
    self.permalink
  end

  # Remaining time til countdown period ends
  def countdown_time_left
    self.countdown_period_end.to_i - DateTime.now.to_i
  end

  def self.find_promo_items( merchant_id, permalink, page, per_page )
    promos = merchant_id ? self.where(:merchant_id => merchant_id) : all

    if permalink.nil?
      promos.not_expired.desc(:created_at).paginate(:page => page, :per_page => per_page)
    else
      c = Classification.where(:permalink => permalink).first
      c.promos.not_expired.desc(:created_at).paginate(:page => page, :per_page => per_page)
    end
  end

  def set_classifications( classifications )
    set :classifications, classifications
  end

  def set_branches( branches )
    set :branches, branches
  end

  def promo_valid?
    !quota_full? && Time.now < countdown_period_end
  end

  def quota_full?
    #(promo_claims.total_discounts == quota)
    (quota - promo_claims.count) <= 0
  end

  def discounts
    price_actual - price_discounted
  end

  def self.random_code
    alphanumerics = [('0'..'9'),('A'..'Z')].map {|range| range.to_a}.flatten
    (0...8).map { alphanumerics[Kernel.rand(alphanumerics.size)] }.join
  end

  def claim!(claiming_user)
    unless quota_full?
      unless claiming_user.claimed?(self)
        promo_claims.create({:manual_code => manual_code, :validity => expired, :user_id => claiming_user.id, :discounts => discounts})
      else
        raise "One claim per user!"
      end
    end
  end

  def featured?
    self.featured
  end

  def redeem(user_id)
    pc = promo_claims.where(:user_id => user_id).first
    pc.redeemed = true
    pc.save!
  end
  
  def percent_discounted
   ( discounts * 100 ) / price_actual 
  end

  def remaining
    total_claims - promo_claims.count
  end
  
  def total_claims
    if quota && discounts
      quota
    end
  end

  def editable?
    s = status
    s == :pending || s == :rejected
  end

  def status
    s = read_attribute(:status)
    if s == :active && countdown_period_end > Time.now
      :active
    elsif s == :active
      :recent
    else
      s # either pending or rejected
    end
  end

  def activate
    self.status = :active
  end

  def reject
    self.status = :rejected
  end

  def rejected?
    self.status == :rejected
  end
 




  private

  # hack for making many-to-many associations work in Mongoid 2 beta 20
  def set(resource, array)
    eval("self.#{resource}.each") do |r|
      r.promo_ids.delete self.id
      r.save
    end

    eval("self.#{resource.to_s.singularize}_ids = []")
    eval("self.#{resource} = array")
    self.save
  end

  def minimum_discount
    if price_actual && price_discounted
      return if discounts >= (price_actual * MIN_DISCOUNT_RATE)
      errors.add(:price_discounted, "must be at least #{MIN_DISCOUNT_RATE*100}% less than actual price")
    end
  end

  def code_should_be_8_characters_or_nothing
    return if manual_code.blank?
    errors.add(:manual_code, 'must be 8 characters or none') if manual_code.length != 8
  end

  def branches_cannot_be_empty
    errors.add(:branches, "can't be empty") if branches.blank?
  end

  def valid_countdown_period_start
    if countdown_period_start < _min_period_start
      errors.add(:countdown_period_start, 'must be at least 1 day from now')
    end
  end

  def valid_countdown_period_end
    if countdown_period_end < min_period_end
      errors.add(:countdown_period_end, 'must be at least 4 hours from countdown start')
    end
    if countdown_period_end > max_period_end
      errors.add(:countdown_period_end, 'must be at most 3 days from countdown start')
    end
  end

  def valid_coupon_validity_start
    if coupon_validity_start != min_max_validity_start
      errors.add(:coupon_validity_start, 'must be the very next day after promo countdown start')
    end
  end
  
public
  def min_period_start
    _min_period_start + 1.hour
  end

  def min_period_end
    countdown_period_start + 4.hours if countdown_period_start
  end

  def max_period_end
    countdown_period_start + 3.days if countdown_period_start
  end

  def min_max_validity_start
    (countdown_period_start + 1.day).to_date if countdown_period_start
  end

  def min_validity_end
    if coupon_validity_end && coupon_validity_start && coupon_validity_end <= coupon_validity_start
      errors.add(:expired, "Canot be less than or equal to validity start")
    end
  end





  public

  def period_start
    self.countdown_period_start.strftime("%Y-%m-%d %H:00")
  end

  def period_start=(period_start)
    self.countdown_period_start = period_start
  end

  def period_end
    self.countdown_period_end.strftime("%Y-%m-%d %H:00")
  end

  def period_end=(period_end)
    self.countdown_period_end = period_end
  end

  # Deprecated APIs

  def period
    self.countdown_period_start
  end

  def period=(period)
    self.countdown_period_start = period
  end

  def start
    self.coupon_validity_start
  end

  def start=(start)
    self.coupon_validity_start = start
  end

  def expired
    self.coupon_validity_end
  end

  def expired=(expired)
    self.coupon_validity_end = expired
  end

  deprecate :period
  deprecate :period=
  deprecate :start
  deprecate :start=
  deprecate :expired=
end

