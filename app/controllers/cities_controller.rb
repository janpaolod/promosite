class CitiesController < ApplicationController
  respond_to :html
  before_filter :authenticate_admin!
  
  def index
    @cities = City.all
    respond_with @cities
  end

  def show
    @city = City.find(params[:id])
    respond_with @city 
  end

  def new
    @city = City.new
    respond_with @city 
  end

  def edit
    @city = City.find(params[:id])
  end

  def create
    @city = City.new(params[:city])
    flash[:notice] = 'City was successfully created.' if @city.save
    respond_with @city
  end

  def update
    @city = City.find(params[:id])
    flash[:notice] = 'City was successfully updated.' if @city.update_attributes(params[:city])
    respond_with @city
  end

  def destroy
    @city = City.find(params[:id])
    @city.destroy
    redirect_to :action => 'index'
  end
end

