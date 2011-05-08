class MerchantRegistrationsController < Devise::RegistrationsController

  def new
    @title = 'Merchant Signup'
    @merchant = Merchant.new
    @classifications = Classification.all
    render :template => 'merchants/new'
  end

  def create
    @merchant = Merchant.new(params[:merchant])

    if @merchant.save

      @merchant.set_classifications( checked_classifications )
      sign_in @merchant unless admin_signed_in?
      flash[:notice] = 'Merchant ' + @merchant.name  + ' was created.'
      redirect_to @merchant

    else
      @classifications = Classification.all
      render :template => 'merchants/new'
    end
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
end
