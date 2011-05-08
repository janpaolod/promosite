class BranchesController < ApplicationController
  before_filter :find_cities, :only => [:new, :create, :edit, :update]
  before_filter :find_merchant

  def new
    @branch = @merchant.branches.build
  end

  def edit
    @branch = @merchant.branches.where(:permalink => params[:id]).first
  end

  def create
    @branch = @merchant.branches.build(params[:branch])
    @branch.city = City.find(params[:city])

    if @branch.save
      redirect_to @merchant, :notice => 'Branch was successfully added.'
    else
      render :action => :new, :merchant_id => params[:merchant_id]
    end
  end

  def update
    @branch = @merchant.branches.where(:permalink => params[:id]).first
    @branch.city = City.find(params[:city])

    if @branch.update_attributes(params[:branch])
      redirect_to @merchant, :notice => 'Branch was successfully updated.'
    else
      render :action => :edit, :merchant_id => params[:merchant_id]
    end
  end

  def destroy
    @merchant.branches.where(:permalink => params[:id]).first.destroy
    redirect_to @merchant, :notice => 'Branch was successfully deleted.'
  end

private

  def find_cities
    @cities = City.all.map { |city| [city.name, city.id] }
  end

  def find_merchant
    @merchant = Merchant.where(:permalink => params[:merchant_id]).first
  end

end
