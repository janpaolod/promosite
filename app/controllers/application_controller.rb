class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :load_sidebar_data
 
  protected

  def load_sidebar_data
    @featured_promos = Promo.where(:featured => true).limit(1)
  end

  def after_sign_in_path_for(resource)
    resource.is_a?(Merchant) ? merchant_path(current_merchant) : super
  end
end
