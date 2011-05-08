require "spec_helper"

describe MerchantsController do
  include Devise::TestHelpers

  let(:merchants) { [ mock_model('Merchant'), mock_model('Merchant') ] }

  describe "GET 'index'" do
    it "assigns @title with 'All Merchants'" do
      get :index
      assigns(:title).should eq("All Merchants")
    end

    it "assign @merchants" do
      Merchant.stub(:all).and_return(merchants)
      merchants.stub(:asc).and_return(merchants)

      get :index
      assigns(:merchants).should eq(merchants)
    end
  end

  describe "GET 'show'" do
    let(:merchant) { mock_model("Merchant").as_null_object }

    before(:each) do
      Merchant.stub(:find).and_return( merchant )
    end

    it "assigns @merchant with the merchant associated with params[:id]" do
      Merchant.should_receive(:find).with( merchant.id )
      get :show, :id => merchant.id
      assigns(:merchant).should eq( merchant )
    end

    it "assigns @title with the merchant's name" do
      get :show, :id => merchant.id
      assigns(:title).should eq( merchant.name )
    end
  end

  describe "GET 'new'" do
    let(:admin) { Factory(:admin) }
    let(:merchant) { mock_model("Merchant") }

    context "when no admin is signed in" do
      it "fails" do
        get :new
        response.should_not be_success
      end
    end

    context "when an admin is signed in" do
      before do
        sign_in admin
        Merchant.stub(:new).and_return(merchant)
      end

      it "assigns @title with 'Create Merchant'" do
        get :new
        assigns(:title).should eq("Create Merchant")
      end

      it "assigns @merchant" do
        get :new
        assigns(:merchant).should eq(merchant)
      end
    end
  end

  describe "GET 'edit'" do
    let(:admin) { Factory(:admin) }
    let(:merchant) { mock_model("Merchant") }

    context "when no admin is signed in" do
      it "fails" do
        get :edit, :id => merchant.id
        response.should_not be_success
      end
    end

    context "when an admin is signed in" do
      before do
        sign_in admin
        Merchant.stub(:find).and_return(merchant)
      end

      it "assigns @title with 'Edit Merchant'" do
        get :edit, :id => merchant.id
        assigns(:title).should eq("Edit Merchant")
      end

      it "assigns @merchant with the merchant associated with params[:id]" do
        get :edit, :id => merchant.id
        assigns(:merchant).should eq(merchant)
      end

    end
  end

  describe "POST 'create'" do
    let(:admin) { Factory(:admin) }
    let(:merchant) { mock_model("Merchant").as_null_object }
    let(:attr) { {"name"=>"Merc", "info"=>"New merch", "image"=>"some_url" } }

    context "when no admin is signed in" do
      it "fails" do
        post :create, :merchant => attr
        response.should_not be_success
      end
    end

    context "when an admin is signed in" do
      before do
        sign_in admin
        Merchant.stub(:new).and_return( merchant )
      end

      it "creates a new merchant based from the info submitted by the user" do
        Merchant.should_receive(:new).with(attr)
        post :create, :merchant => attr
      end

      context "when the merchant saves successfully" do
        before(:each) do
          merchant.stub(:save).and_return(true)
        end

        it "assigns flash[:notice] with a success message" do
          post :create, :merchant => attr
          flash[:notice].should match( /created/i )
        end

        it "redirects to the show merchant path" do
          post :create, :merchant => attr
          response.should redirect_to(:action => "show", :id => merchant)
        end
      end

      context "when the merchant fails to save" do
        before(:each) do
          merchant.stub(:save).and_return(false)
        end

        it "assigns @merchant with the info submitted by the user" do
          post :create, :merchant => attr
          assigns(:merchant).should eq(merchant)
        end

        it "renders the 'new' template" do
          post :create, :merchant => attr
          response.should render_template('new')
        end
      end
    end
  end

  describe "PUT 'update'" do
    let(:admin) { Factory(:admin) }
    let(:merchant) { mock_model("Merchant").as_null_object }
    let(:attr) { {"name"=>"Merc", "info"=>"New merch", "image"=>"some_url" } }
    
    context "when no admin is signed in" do
      it "fails" do
        put :update, :id => merchant.id
        response.should_not be_success
      end
    end

    context "when an admin is signed in" do
      before(:each) do
        sign_in admin
        Merchant.stub(:find).and_return( merchant )
        merchant.stub(:update_attributes).and_return( merchant )
      end

      it "queries for the merchant record to be updated" do
        Merchant.should_receive(:find).with( merchant.id )
        put :update, :id => merchant.id, :merchant => attr
      end

      context "when the merchant updates successfully" do
        before(:each) do
          merchant.stub(:update_attributes).and_return(true)
        end

        it "assigns flash[:notice] with a success message" do
          put :update, :id => merchant.id, :merchant => attr
          flash[:notice].should match( /updated/i )
        end

        it "redirects to the show merchant page" do
          put :update, :id => merchant.id, :merchant => attr
          response.should redirect_to( :action => "show", :id => merchant.id )
        end
      end

      context "when the merchant fails to update" do
        before(:each) do
          merchant.stub(:update_attributes).and_return(false)
        end

        it "renders the 'edit' template" do
          put :update, :id => merchant.id, :merchant => attr
          response.should render_template("edit")
        end
      end
    end
  end

  describe "DELETE 'destroy'" do
    let(:admin) { Factory(:admin) }
    let(:merchant) { mock_model("Merchant").as_null_object }

    context "when no admin is signed in" do
      it "fails" do
        delete :destroy, :id => merchant.id
        response.should_not be_success
      end
    end

    context "when an admin is signed in" do
      before(:each) do
        sign_in admin
        Merchant.stub(:find).and_return( merchant )
      end

      it "queries for the merchant record to be destroyed" do
        Merchant.should_receive(:find).with( merchant.id )
        delete :destroy, :id => merchant.id
      end

      it "destroys that record" do
        merchant.should_receive(:destroy)
        delete :destroy, :id => merchant.id
      end

      it "redirects to the index action" do
        delete :destroy, :id => merchant.id
        response.should redirect_to(:action => 'index')
      end
    end
  end
end