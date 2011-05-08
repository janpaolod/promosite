class PromoClaim
  include Mongoid::Document
  include Mongoid::Timestamps

  referenced_in :promo
  referenced_in :user

  field :manual_code, :type => String
  field :validity,    :type => String
  field :discounts,   :type => Integer
  field :redeemed, :type => Boolean

  def user
    @user ||= User.find(user_id)
  end

  def self.total_discounts
    find(:all).sum(:discounts) || 0
  end

  def self.filshare
    total_discounts * 0.05 if total_discounts
  end

end
