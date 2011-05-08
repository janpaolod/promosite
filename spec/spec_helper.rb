require 'rubygems'
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'factory_girl'

  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.mock_with :rspec

    config.before :each do
      Mongoid.master.collections.select { |c| c.name !~ /system/ }.each(&:drop)
    end

    ### Part of a Spork hack. See http://bit.ly/arY19y
    # Emulate initializer set_clear_dependencies_hook in
    # railties/lib/rails/application/bootstrap.rb
    ActiveSupport::Dependencies.clear

    def integration_signin(url, user)
      visit url
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_button "Sign in"
    end
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
end