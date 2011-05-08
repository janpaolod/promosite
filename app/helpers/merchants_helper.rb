module MerchantsHelper
  def heading_for_new_merchant
    if admin_signed_in?
      "Create merchant"
    else
      "Merchant Signup"
    end
  end

  def image_for_merchant(merchant)
    if merchant.image.url
      image_tag merchant.image.url
    else
      image_tag "merchant.default.png"
    end
  end
end
