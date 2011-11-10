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

  def cta_links(res, obj)
    cnt = [link_to('Show', obj)]
    if can?(:update, obj)
    cnt << link_to('Edit', self.send("edit_#{res}_path".to_sym, obj))
    cnt << link_to('Archive', self.send("edit_#{res}_path".to_sym, obj))
    end
    if can?(:destroy, obj)
    cnt << link_to('Remove', obj, confirm: 'Are you sure?', method: :delete)
    end
    cnt.join(" | ").html_safe
  end

  def download_resume(c)
    style = c.resume_content_type == "application/pdf" ? "icon_pdf.gif" : "icon_word.png"
    ("<span class='download'>"+ image_tag("#{style}", :align => "absmiddle") + "&nbsp;" + link_to("Download Resume", c.resume.url, :class => "download")+"</span>").html_safe
  end

  def show_resume(candidate)
    unless candidate.resume_content_type.blank?
    style = candidate.resume_content_type == "application/pdf" ? "icon_pdf.gif" : "icon_word.png"
    ("<span class='download'>"+ image_tag("#{style}", :align => "absmiddle") + "&nbsp; #{candidate.resume_file_name} </span>").html_safe
    end
  end

end
