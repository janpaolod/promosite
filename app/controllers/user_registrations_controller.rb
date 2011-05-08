class UserRegistrationsController < Devise::RegistrationsController

  def new
    @user = User.new
    render :template => 'devise/registrations/new'
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "You've successfully signed up. Before anything else, please complete your profile below to get the most out of Twiggzy. It's easy and it only takes less than 30 secs."
      sign_in @user
      redirect_to edit_user_registration_path(:new => true)
    else
      render :template => 'devise/registrations/new'
    end
  end

  def edit
    @user = current_user
    @cities = find_cities
    render :template => 'devise/registrations/edit'
  end

  def update
    @user = current_user
    @user.city = City.find(params[:city])
    if @user.update_with_password(params[:user])
      flash[:notice] = "Profile successfully updated!"
      redirect_to root_url
    else
      @cities = find_cities
      render :template => 'devise/registrations/edit'
    end
  end

private

  def find_cities
    @cities ||= City.all.map { |city| [city.name, city.id] }
  end

end
