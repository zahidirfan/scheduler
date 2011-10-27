module ApplicationHelper

  def show_candidate_status(c)
    c.status.nil? ? "New" : c.status
  end
  
  def show_tags(c)
    return if c.tags.empty?
    c.tags.split(',').each do |t|
      "<span class='label'>#{t}</span>"
    end
  end
  
end
