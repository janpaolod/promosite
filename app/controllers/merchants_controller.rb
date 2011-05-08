class MerchantsController < ApplicationController

  def index
    @title = 'All Merchants'
    @classifications = Classification.all
    @merchants = Merchant.classified_as( params[:classification],
      params[:page], 5 )
  end

  def show
    @merchant = Merchant.where(:permalink => params[:id]).first
    @title = @merchant.name
  end

  def new
    @merchant = Merchant.new

    @title = 'Merchant Signup'
    @classifications = Classification.all
  end

  def edit
    @merchant = Merchant.where(:permalink => params[:id]).first

    @title = 'Edit Merchant'
    @classifications = Classification.all
  end

  def create
    @merchant = Merchant.new(params[:merchant])
    if @merchant.save
      @merchant.set_classifications( checked_classifications )
      flash[:notice] = 'Merchant ' + @merchant.name  + ' was created.'
      redirect_to @merchant
    else
      @title = 'Merchant Signup'
      render :action => "new"
    end
  end

  def update
    @merchant = Merchant.where(:permalink => params[:id]).first
    if @merchant.update_attributes(params[:merchant])
      @merchant.set_classifications( checked_classifications )
      flash[:notice] = 'Merchant ' + @merchant.name  + ' was updated.'
      redirect_to @merchant
    else
      render :action => "edit"
    end
  end

  def destroy
    @merchant = Merchant.where(:permalink => params[:id]).first
    @merchant.destroy
    redirect_to(merchants_url)
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
