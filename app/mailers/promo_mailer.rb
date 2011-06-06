class PromoMailer < ActionMailer::Base.smtp_settings = {
  :address => "smtp.gmail.com",
  :port => "587",
  :domain => "twiggzy.com",
  :authentication => :plain,
  :user_name => "info@twiggzy.com",
  :password => "promosinfo"
}
  default :from => "Twiggzy Team <admin@twiggzy.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.promo_mailer.activate.subject
  #
  def activate(deal)
    @deal, @merchant = deal, deal.merchant
    @deal_url = merchant_promo_url(@merchant, @deal)

    mail :to => @merchant.email
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.promo_mailer.reject.subject
  #
  def reject(deal)
    @deal, @merchant = deal, deal.merchant
    @deal_url = merchant_promo_url(@merchant, @deal)
    
    mail :to => deal.merchant.email
  end
end
