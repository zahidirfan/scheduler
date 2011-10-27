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
  
  def flash_notifications
    message = flash[:error] || flash[:notice] || flash[:alert]
    if message
    type = flash.keys[0].to_s
    "<script>$(function() { $(\"#notification_bar\").bar({background_color:'#fbef75',message:\"#{message}\"})\; })\;</script>".html_safe
    end
  end
end
