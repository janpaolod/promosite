require "spec_helper"

describe User do
  before(:each) do
    @attr = {
      :email => 'user@example.com',
      :password => 'foobar',
      :password_confirmation => 'foobar'
    }
  end

  it "create" do
    User.create!( @attr )
  end

  it "requires an email" do
    no_email_user = User.new( @attr.merge( email: "" ) )
    no_email_user.should_not be_valid
  end

  it "requires a password" do
    User.new(@attr.merge(:password => "")).
      should_not be_valid
  end

  it "requires matching password confirmation" do
    User.new(@attr.merge(:password_confirmation => "invalid")).
      should_not be_valid
  end

  it "has a #promos attribute" do
    User.new( @attr ).should respond_to(:promos)
  end
end