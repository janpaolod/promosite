class PagesController < ApplicationController
  def privacy
    @title = "Privacy Policy"
  end

  def term_use
    @title = "Term of Use"
  end

  def term_sale
    @title = "Term of Sale"
  end

end
