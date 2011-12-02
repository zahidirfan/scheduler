module ApplicationHelper
  include ActsAsTaggableOn::TagsHelper

  def feedback_link(event_id)
    link_to "Feedback", event_id
  end

  def feedback_link1(interview)
    unless interview.comments.exists?
      link_to "Feedback", new_candidate_interview_comment_path(interview.candidate, interview)
    else
      link_to "Edit Feedback", edit_candidate_interview_comment_path(interview.candidate, interview, interview.comments.first)
    end
  end


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
    val = FEEDBACK_STATUS.key(i.to_s)
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

  def show_interview_title
    u = ""; u = "for " + User.find(params[:interviewer_filter]).name if params[:interviewer_filter]
    "Interview Schedule #{u}  ~ Overview"
  end

end
