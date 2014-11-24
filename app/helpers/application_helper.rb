module ApplicationHelper

  def title(page_title)
	  content_for(:title) { page_title }
  end

  def sortable_feedback(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column_feedback ? "current #{sort_direction}" : nil
    direction = column == sort_column_feedback && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction} #, {:class => css_class}
  end

  def sortable_user(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column_user ? "current #{sort_direction}" : nil
    direction = column == sort_column_user && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction} #, {:class => css_class}
  end
	
end
