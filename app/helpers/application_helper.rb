module ApplicationHelper
  def title
    base_title = "Twiggzy"
    if @title.nil? 
      base_title 
    else
      "#{base_title} | #{@title}"
    end
  end

  def  link_to_collection(name, url, permalink=nil)
    classification = params[:classification]
    
    if (classification.nil? && name=='All') || classification == permalink
      raw("<li class=\"portlet-tab-nav-active\">#{link_to name, ''}</li>")
    else
      raw("<li>#{link_to name, url}</li>")
    end
  end
end
