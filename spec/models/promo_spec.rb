require "spec_helper"

describe Promo do

  before(:each) do
    @attr = {
      name: "Promo",
      details: "Details",
      manual_code: '12345678',
      price_actual: 100,
      price_discounted: 70,
      quota: 90,
      coupon_validity_end: 7.days.from_now,
      branch: ['Some Branch Name']
    }
  end

  context "Validations" do
    it "is valid with valid attributes" do
      Promo.create! @attr
    end

    it "is not valid without a name" do
      p = Promo.new @attr.merge( name: '' )
      p.should_not be_valid
    end

    it "is not valid without details" do
      p = Promo.new @attr.merge( details: '' )
      p.should_not be_valid
    end

    context "Manual Code" do
      it "is valid if it's empty" do
        p = Promo.new @attr.merge( manual_code: '' )
        p.should be_valid
      end

      it "is valid if it's exactly 8 characters long" do
        p = Promo.new @attr.merge( manual_code: 'a' * 8 )
        p.should be_valid
      end

      it "is not valid if it's less than 8 characters long" do
        p = Promo.new @attr.merge( manual_code: 'a' * 7 )
        p.should_not be_valid
      end
    
      it "is not valid if it's more than 8 characters long" do
        p = Promo.new @attr.merge( manual_code: 'a'*9 )
        p.should_not be_valid
      end
    end

    it "is not valid without start" do
      p = Promo.new @attr
      p.coupon_validity_start = nil
      p.should_not be_valid
    end

    it "is not valid without expired" do
      p = Promo.new @attr.merge( coupon_validity_end: nil )
      p.should_not be_valid
    end

    it "is not valid if not associated with a branch" do
      p = Promo.new @attr.merge( branch: nil )
      p.should_not be_valid
    end

    context "Countdown Period" do
      it "is not valid if less than 3 days from now" do
        p = Promo.new @attr.merge( countdown_period_start: 3.days.from_now - 30.seconds )
        p.should_not be_valid
      end

      it "is at least 4 hours long" do
        p = Promo.new @attr
        p.countdown_period_end = p.countdown_period_start + 3.hours + 59.minutes
        p.should_not be_valid
      end

      it "is at most 3 days long" do
        p = Promo.new @attr
        p.countdown_period_end = p.countdown_period_start + 3.days + 30.seconds
        p.should_not be_valid
      end
    end

    context "Coupon validity" do
      it "must be at least the next day after countdown period ends" do
        p = Promo.new @attr
        p.coupon_validity_start = p.countdown_period_end + 1.day
        p.should be_valid
      end

      it "is not valid before that day" do
        p = Promo.new @attr
        p.coupon_validity_start = p.countdown_period_end
        p.should_not be_valid
      end

      it "is not valid after that day" do
        p = Promo.new @attr
        p.coupon_validity_start = p.countdown_period_end + 2.days
        p.should_not be_valid
      end
    end

    context "Promo Price" do
      it "isn't valid without original price" do
        p = Promo.new @attr.merge(price_actual: nil)
        p.should_not be_valid
      end

      it "isn't valid without discounted price" do
        p = Promo.new @attr.merge(price_discounted: nil)
        p.should_not be_valid
      end

      it "isn't valid if discounted price is less 30% of original price" do
        p = Promo.new @attr.merge(price_discounted: 80)
        p.should_not be_valid
      end
    end

  end



  describe "#featured?" do
    before(:each) do
      @promo = Promo.new
    end

    it "returns true if the current promo is featured" do
      @promo.featured = true
      @promo.featured?.should be_true
    end

    it "returns false if the current promo isn't featured?" do
      @promo.featured = false
      @promo.featured?.should be_false
    end

  end
end