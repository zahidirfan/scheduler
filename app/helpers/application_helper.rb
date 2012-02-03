module ApplicationHelper
  include ActsAsTaggableOn::TagsHelper

  def feedback_link(interview)
    unless interview.comments.exists?
      link_to image_tag("feedback.jpg", :title => "Feedback", :alt => "Feedback"), new_candidate_interview_comment_path(interview.candidate, interview)
    else
      link_to image_tag("feedback.jpg", :title => "Edit Feedback", :alt => "Edit Feedback"), edit_candidate_interview_comment_path(interview.candidate, interview, interview.comments.first)
    end
  end

  def show_candidate_status(c)
    c.status.nil? ? "Not Scheduled" : c.status
  end

  def show_candidate_feedback_status(i)
    i.comments.exists? ? "#{i.comments.first.status} by #{clickable_user(i.comments.first.user)}" : "Scheduled to #{clickable_user(i.user)}"
  end

  def show_candidate_interview_details(c)
    if i = c.interviews.upcoming.try(:first)
      "Scheduled for #{clickable_user(i.user)} on #{i.formated_scheduled_at}"
    elsif i = c.interviews.last
      ret_str = "Interviewed on #{i.formated_scheduled_at}"
      ret_str << " | #{show_candidate_feedback_status(i)}"
      p ret_str
    else
      "Posted on #{c.created_at.strftime("%b %d, %Y")} | #{show_candidate_status(c)}"
    end
  end

  def clickable_user(user)
    link_to "#{user.name.capitalize}", user_path(user)
  end

  def clickable_scheduled_at(i)
    link_to "#{i.formated_scheduled_at}", interviews_path(:view => 'calendar', :calendar_view => 'agendaDay')
  end

  def show_tags(c)
    return if c.tags.empty?
    c.tags.collect { |tag| link_to tag.name, tag_candidates_path(tag.name) }
  end

  def flash_notifications
    message = flash[:error] || flash[:notice] || flash[:alert]
    if message
    type = flash.keys[0].to_s
    "<script>$(function() { $(\"#notification_bar\").bar({background_color:'#fbef75',message:\"#{message}\"})\; })\;</script>".html_safe
    end
  end

  def show_comment_status(i)
    val = (i == "Cancelled") ? i : FEEDBACK_STATUS.key(i.to_s)
  end

  def cta_links(res, obj, interview=nil)
    cnt = []

    if can?(:create, Interview)
      schedule_link, title = interview.nil? ? self.send("#{res}_path".to_sym, obj) : [self.send("edit_#{res}_interview_path".to_sym, obj, interview), "Re"]
      cnt << link_to(image_tag('calendar16.png', :alt => "#{title}schedule an interview".capitalize, :title => "#{title}schedule an interview".capitalize), schedule_link)
    end

   follow_link = current_user.following?(obj) ? image_tag('un-trackit.png', :alt => 'Untrack', :title => 'Untrack', :id => "follow_link_#{obj.id}") : image_tag('trackit.png', :alt => 'Track', :title => 'Track', :id => "follow_link_#{obj.id}")
    cnt << link_to(follow_link, '#', :class => "follow_link", :data => {:candidate_id => obj.id})

    if can?(:update, obj)
#      cnt << link_to(archive_link, self.send("#{res}_mark_archive_path".to_sym, obj))
      #archive_link = (obj.status == "Archive") ? "Unarchive" : "Archive"
    end
    delete_link, title = interview.nil? ? [obj, "Delete this candidate"] : [candidate_interview_path(obj, interview, :cancel=>true), "Cancel this interview"]
    if can?(:destroy, delete_link)
      cnt << link_to(image_tag('delete.png', :alt => title, :title => title), delete_link, confirm: "Are you sure to #{title}?".capitalize, method: :delete)
    end
    cnt.join(" - ").html_safe
  end

  def download_resume(c, only_online=false)
     online_link = link_to("View Online", "http://docs.google.com/gview?url=#{c.resume.url}&embedded=true", :class => "download", :target => "blank")
     return online_link if only_online

    style, target = c.resume_content_type == "application/pdf" ? ["icon_pdf.gif", "blank"] : "icon_word.png"
     ("<span class='download'>"+ image_tag("#{style}", :align => "absmiddle") + " Resume " + link_to("Download", c.resume.url, :class => "download", :target => target) + " | #{online_link}</span>").html_safe
  end

  def show_resume(candidate)
    unless candidate.resume_content_type.blank?
    style = candidate.resume_content_type == "application/pdf" ? "icon_pdf.gif" : "icon_word.png"
    ("<span class='download'>"+ image_tag("#{style}", :align => "absmiddle") + "&nbsp; #{candidate.resume_file_name} </span>").html_safe
    end
  end

  def show_interview_title
    u = ""; u = "for " + User.find(params[:interviewer_filter]).name if params[:interviewer_filter]
    "Interviews #{u}"
  end

  def get_interview_title(cat_name)
    categories = {"today" => "Today", "tomorrow" => "Tomorrow", "week" => "This Week", "later" => "Later", "total" => "Total"}
    categories[cat_name]
  end

  def get_hostname
    "http://#{request.nil? ? APP_HOST_URL : request.env['HTTP_HOST']}"
  end

end
