module ApplicationHelper

  def show_candidate_status(c)
    c.status.nil? ? "New" : c.status
  end
  
end
