require 'carrierwave/orm/mongoid'
require 'filsale_validator'

class Merchant
  include Mongoid::Document
  include Mongoid::Timestamps
  include FilsaleValidator

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  field :name,      :type => String
  field :info,      :type => String
  field :featured,  :type => Boolean, :default => false
  field :agree,     :type => Boolean
  field :permalink, :type => String
  mount_uploader    :image, ImageUploader

  validates :name,      :presence => true, :uniqueness => true
  validates :info,      :presence => true, :length => { :maximum => 250 }
  validates :email,     :email_unique_in_filsale => true
  validates :permalink, :uniqueness => true

  references_many :branches, :dependent => :destroy
  references_many :promos,   :dependent => :destroy
  references_many :classifications, stored_as: :array, inverse_of: :merchants

  index :permalink, :unique => true

  before_validation do |merchant|
    merchant.email.downcase!
  end

  before_save do |merchant|
    self.permalink = self.name.parameterize
  end

  def to_param
    self.permalink
  end

  def set_classifications( classifications )
    self.classifications.each do |c|
      c.merchant_ids.delete self.id
      c.save!
    end

    self.classification_ids = []
    self.classifications = classifications
    self.save!
  end

  def self.classified_as( classification, page, per_page )
    if classification.nil?
      all.asc(:name).paginate(:page => page, :per_page => per_page)
    else
      classification = Classification.where(:permalink => classification).first
      classification.merchants.paginate(:page => page, :per_page => per_page)
    end
  end

  def featured?
    self.featured
  end
end
