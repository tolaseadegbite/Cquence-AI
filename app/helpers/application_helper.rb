module ApplicationHelper
  # returns full title if present, else returns base title
  def full_title(page_title = "")
    base_title = "Cquence AI"
    if page_title.blank?
        base_title
    else
      "#{base_title} | #{page_title}"
    end
  end
end
