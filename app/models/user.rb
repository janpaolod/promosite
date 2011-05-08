require 'filsale_validator'

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include FilsaleValidator

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :first_name, :last_name, :email, :gender,
    :address_line_1, :city, :agree, :password, :password_confirmation

  field :first_name,     :type => String
  field :last_name,      :type => String
  #field :birth_date,     :type => Date
  field :gender,         :type => Boolean
  field :address_line_1, :type => String
  #field :province,       :type => String
  field :agree,          :type => Boolean

  validates :agree, :presence => {:message => 'to the terms and conditions'}
  validates :first_name, :last_name, :presence => true, :on => :update
  validates :email, :email_unique_in_filsale => true

  referenced_in   :city
  references_many :claimed_promos, :class_name => 'PromoClaim'

  before_validation do |user|
    user.email.downcase!
  end

  def claimed?( promo )
    PromoClaim.where(:user_id => self.id, :promo_id => promo.id).first != nil
  end
  
  #def claimed_promos
  #  promos.inject([]) { |array, promo| array << promo.claimed_by(self) }
  #end

  def update_with_password(params = {})
    cp = :current_password
    pw = params.delete(cp)
    msg = "can't be blank if First Name and/or Last Name is being updated"

    self.errors.add(cp, msg) if pw.blank? && name_is_being_updated(params)
    self.errors.add(cp, :invalid) if pw.present? && !valid_password?(pw)

    result = if self.errors.empty?
      update_attributes(params)
    else 
      self.attributes = params
      false
    end

    clean_up_passwords
    result
  end

private

    def password_required?
      user_is_being_updated ? false : true
    end

    def user_is_being_updated
      self.created_at && self.password.blank?
    end

    def name_is_being_updated(params)
      (self.first_name != params[:first_name]) || (self.last_name != params[:last_name])
    end

end
