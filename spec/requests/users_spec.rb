require 'spec_helper'

describe "User" do
  before(:each) do
    @user = Factory(:user)
  end

  it "is able to sign in" do
    integration_signin( new_user_session_path, @user )
    response.should contain(/signed in successfully/i)
  end

  context "when signed in" do
    before(:each) do
      integration_signin( new_user_session_path, @user )
      @new_attributes = { email: 'new@example.com', password: 'new password', 
        first_name: 'New firstname', last_name: 'New lastname' }
    end

    it "is able to sign out" do
      click_link "Signout"
      response.should contain(/signed out successfully/i)
    end

    it "is able to update his/her profile" do
      update_profile(@new_attributes, @user.password)
      response.should contain(/updated(.*)successfully/i)
    end

    it "is able to update his/her profile without changing his/her password" do
      update_profile(@new_attributes, @user.password)
      response.should contain(/updated(.*)successfully/i)
    end

    context "edit profile page" do
      it "reflects the changes made by the user" do
        update_profile(@new_attributes, @user.password)

        click_link "Edit profile" # again to see if it reflects the changes made
        response.should have_selector("form input", :type => 'text',
          :id => 'user_first_name', value: @new_attributes[:first_name])
        response.should have_selector("form input", :type => 'text',
          :id => 'user_last_name', value: @new_attributes[:last_name])
        response.should have_selector("form input", :type => 'text',
          :id => 'user_email', value: @new_attributes[:email])
      end
    end
  end





  private

  def update_profile(new_attr, current_password)
    click_link "Edit profile"
    fill_in "First name", with: new_attr[:first_name]
    fill_in "Last name", with: new_attr[:last_name]
    fill_in "Email", with: new_attr[:email]
    fill_in "Password", with: new_attr[:password]
    fill_in "Password confirmation", with: new_attr[:password]
    fill_in "Current password", with: current_password
    click_button "Update"
  end
end
