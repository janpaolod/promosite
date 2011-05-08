module PromosHelper
  def checked_or_unchecked(classification, deal)
    deal.classification_ids.include?( classification.id ) ?
      check_box_tag("classifications[#{classification.id}]", 1, true) :
      check_box_tag("classifications[#{classification.id}]")
  end

  def image_for_deal(deal)
    deal.image.url || 'deal.default2.png'
  end
end
