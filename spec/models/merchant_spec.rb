require "spec_helper"

describe Merchant do
  let(:leisure)  { Factory(:classification, :name => "Leisure") }
  let(:shopping) { Factory(:classification, :name => "Shopping") }

  before(:each) do
    @classifications = [ leisure, shopping ]
  end
  
  describe "#classifications" do  
    it "returns an array of Classifications associated with the merchant" do
      m = Merchant.new( classifications: @classifications )
      m.classifications.should eq( @classifications )
    end
  end

  describe "#set_classifications" do
    before(:each) do
      @merchant = Merchant.create!( name: 'M', info: 'm',
        classifications: @classifications )
    end

    it "it assigns the argument passed to it to self.classifications" do
      @merchant.set_classifications [leisure]
      @merchant.classifications.first.should eq( leisure )
    end
  end

  describe '#featured?' do
    it "returns false if the merchant isn't featured" do
      Merchant.new.featured?.should == false
    end

    it "returns true otherwise" do
      m = Merchant.new
      m.featured = true
      m.featured?.should == true
    end
  end
end
