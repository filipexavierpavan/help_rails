module ApplicationHelper
  # Returns the full title on per-page basis.
  def full_title(page_title = '')
    base_title = "Ruby on Rails - Help App"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end
  
  def glyph(*names)
    content_tag :i, nil, :class => names.map{|name| "glyphicon glyphicon-#{name.to_s.gsub('_','-')}"}
  end
end
