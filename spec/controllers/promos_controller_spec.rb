require "spec_helper"

describe PromosController do
  include Devise::TestHelpers

  render_views

  let(:merchant) { mock_model("Merchant").as_null_object }
  let(:promo) { mock_model("Promo").as_null_object }
  let(:classifications) { [ mock_model("Classification").as_null_object ] }

  before(:each) do
    sign_in Factory(:admin)

    Merchant.stub(:find).and_return( merchant )
    Promo.stub(:new).and_return( promo )
    merchant.stub(:classifications).and_return( classifications )
    merchant.stub(:promos).and_return( promo )
  end

  describe "GET 'new'" do
    it "renders a checkbox for the 'featured' field" do
      get :new, :merchant_id => mock_model("Merchant").id
      response.should have_selector("form") do |f|
        f.should have_selector("input", :type => 'checkbox', :id => 'promo_featured')
        f.should have_selector('label', :content => 'Is this a featured promo?')
      end
    end
  end

  describe "GET 'edit'" do
    it "renders a checkbox for the 'featured' field" do
      get :edit, :merchant_id => mock_model("Merchant").id, :id => promo.id
      response.should have_selector("form") do |f|
        f.should have_selector("input", :type => 'checkbox', :id => 'promo_featured')
        f.should have_selector('label', :content => 'Is this a featured promo?')
      end
    end
  end
  
end