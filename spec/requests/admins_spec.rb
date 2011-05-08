require 'spec_helper'

describe "Admin" do
  before(:each) do
    @admin = Factory(:admin)
  end

  it "is able to sign in" do
    integration_signin(new_admin_session_path, @admin)
    response.should contain( /signed in successfully/i )
  end

  it "is able to sign out" do
    integration_signin(new_admin_session_path, @admin)
    click_link "Signout"
    response.should contain( /signed out successfully/i )
  end

  
end
