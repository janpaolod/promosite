require "spec_helper"

describe CitiesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/cities" }.should route_to(:controller => "cities", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/cities/new" }.should route_to(:controller => "cities", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/cities/1" }.should route_to(:controller => "cities", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/cities/1/edit" }.should route_to(:controller => "cities", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/cities" }.should route_to(:controller => "cities", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/cities/1" }.should route_to(:controller => "cities", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/cities/1" }.should route_to(:controller => "cities", :action => "destroy", :id => "1")
    end

  end
end
