class PromosController < ApplicationController
  before_filter :authenticate_user!, :only => [:claim, :track]
  before_filter :authenticate_merchant_or_admin, :only => :records
  
  def index
    @title = 'Deal list'
    if params[:merchant_id]
      merchant = Merchant.where(:permalink => params[:merchant_id]).first
      merchant_id = merchant.id
      @classifications = merchant.classifications
    elsif current_merchant
      merchant_id = current_merchant.id
      @classifications = current_merchant.classifications
    else
      @classifications = Classification.asc(:name)
    end
    @promos = Promo.find_promo_items(merchant_id, params[:classification],  params[:page], 5)
    @deals = @promos
  end

  def show
    @merchant = Merchant.where(:permalink => params[:merchant_id]).first
    @promo = @merchant.promos.where(:permalink => params[:id]).first
    @title = @promo.name
    @users = @promo.users
    @time = Time.now
  end

  def new
    @merchant = Merchant.where(:permalink => params[:merchant_id]).first
    @promo = @merchant.promos.build
    @classifications = @merchant.classifications
  end

  def edit
    @merchant = Merchant.where(:permalink => params[:merchant_id]).first
    @promo = @merchant.promos.where(:permalink => params[:id]).first
    @classifications = @merchant.classifications
  end

  def create
    @merchant = Merchant.where(:permalink => params[:merchant_id]).first
    @promo = @merchant.promos.build(params[:promo])

    override_period_start(@promo) if admin_signed_in?

    if @promo.set_branches checked_branches # promo automatically saved
      @promo.set_classifications checked_classifications
      flash[:notice] = "Your new deal was successfully created and is pending for manual review by the Twiggzy team. You will be notified whether your deal was activated or rejected through email. Thank you for using Twiggzy."
      redirect_to merchant_path(@merchant)
    else
      @classifications = Classification.all
      render :action => 'new', :merchant_id => @merchant
    end
  end

  def override_period_start(promo)
    promo._min_period_start = Time.now

    def promo.valid_countdown_period_start
      if countdown_period_start > _min_period_start
        errors.add(:countdown_period_start, 'must be greater than the current time')
      end
    end
  end

  def update
    @merchant = Merchant.where(:permalink => params[:merchant_id]).first
    @promo = @merchant.promos.where(:permalink => params[:id]).first

    override_period_start(@promo) if admin_signed_in?

    if params[:activate]
      @promo.activate
      PromoMailer.activate(@promo).deliver
      flash[:notice] = "Deal was activated. An email was sent notifying the merchant."
    elsif params[:reject]
      @promo.reject
      PromoMailer.reject(@promo).deliver
      flash[:notice] = "Deal was rejected. An email was sent notifying the merchant."
    end

    if @promo.update_attributes(params[:promo])
      @promo.set_classifications checked_classifications
      @promo.set_branches checked_branches
      flash[:notice] ||= "Deal was successfully updated."
      redirect_to merchant_path(@merchant)
    else
      render 'edit'
    end
  end
  
  def destroy
    @merchant = Merchant.where(:permalink => params[:merchant_id]).first
    @promo = @merchant.promos.where(:permalink => params[:id]).first
    @promo.destroy
    redirect_to merchant_path(@merchant)
  end

  def claim
    @promo = Promo.where(:permalink => params[:id]).first
    unless current_user.first_name.blank? && current_user.last_name.blank?
      @promo.claim!(current_user)
      flash[:notice] = "Print the coupon and present it when you will purchasing the deal."
    else
      flash[:notice] = "You can't claim a deal unless your name is complete!"
    end
    redirect_to merchant_promo_path(@promo.merchant, @promo)
  end

  def track
    @promos = current_user.claimed_promos
  end

  def records
    @promos = if merchant_signed_in?
      current_merchant.promos
    else
      Promo.pending
    end
  end

  def redeem
    @promo = Promo.where(:permalink => params[:id]).first
    begin
      @promo.redeem(params[:user_id])
      flash[:notice] = "Redeemed already"
    ensure
      redirect_to merchant_promo_path(@promo.merchant, @promo)
    end
  end

  def print
    @merchant = Merchant.where(:permalink => params[:merchant_id]).first
    @promo = @merchant.promos.where(:permalink => params[:id]).first

    render :layout => false 
  end


  private

  def checked_classifications
    return [] unless params[:classifications]
    checked = []
    params[:classifications].map do |key, value|
      checked << Classification.find( key )
    end
    checked
  end

  def checked_branches
    return [] unless params[:branches]
    checked = []
    params[:branches].map do |key, value|
      checked << Branch.find( key )
    end
    checked
  end

  def authenticate_merchant_or_admin
    return true if admin_signed_in? || merchant_signed_in?
    authenticate_merchant!
  end
end
