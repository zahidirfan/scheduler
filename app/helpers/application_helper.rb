module ApplicationHelper
  def show_candidate_status(c)
    c.status.nil? ? "New" : c.status
  end
  
  def show_tags(c)
    return if c.tags.empty?
    c.tag_list
  end
  
  def flash_notifications
    message = flash[:error] || flash[:notice] || flash[:alert]
    if message
    type = flash.keys[0].to_s
    "<script>$(function() { $(\"#notification_bar\").bar({background_color:'#fbef75',message:\"#{message}\"})\; })\;</script>".html_safe
    end
  end
  
  def show_comment_status(i)
    val = feedback_status_hash.key(i.to_s)
    "<span class='comment_status_#{i}'>#{val}</span>".html_safe
  end  
  
end
