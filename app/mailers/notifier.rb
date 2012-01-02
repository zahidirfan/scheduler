module QuoVadis
  class Notifier < ActionMailer::Base
    # Sends an email to <tt>user</tt> with a link to a page where they
    # can change their password.
    def change_password(user)
      @username = user.username
      @url = change_password_url user.token
      mail :to => user.email, :from => QuoVadis.from, :subject => QuoVadis.subject
    end
  end
end



class Notifier < ActionMailer::Base
  include UserInfo

  def candidate_profile_update_mail(candidate, user)
    @user = user
    @current_user = current_user
    @candidate = candidate
    changes = candidate.changes
    changes.delete("updated_at")
    @candidate_changes = changes
    mail :to => @user.email, :from => NO_REPLY_EMAIL, :subject => "Profile updated for #{@candidate.name}" if changes.length > 0
  end

  def candidate_deleted_mail(candidate, user)
    @user = user
    @current_user = current_user
    @candidate = candidate
    changes = candidate.changes
    changes.delete("updated_at")
    @candidate_changes = changes
    mail :to => @user.email, :from => NO_REPLY_EMAIL, :subject => "#{@candidate.name} Profile has been deleted" if changes.length > 0
  end

  def interview_schedule_mail(interview, attachment=true)
    @user = interview.user
    @candidate = interview.candidate
    @interview = interview
    if attachment
      attachments[@candidate.resume_file_name] = File.read(@candidate.resume.path)
      attachments["calendar_invite.ics"] = {:mime_type => 'text/calendar', :content => File.read("/tmp/invite_#{interview.candidate.name}_#{interview.user.name}_#{interview.updated_at.to_i}.ics")}
    end
    mail :to => @user.email, :from => NO_REPLY_EMAIL, :subject => "Interview Scheduled for #{@candidate.name}"
  end

  def interview_reschedule_mail(interview, attachment=true)
    @user = interview.user
    @candidate = interview.candidate
    @interview = interview
    if attachment
      attachments[@candidate.resume_file_name] = File.read(@candidate.resume.path)
      attachments["calendar_invite.ics"] = {:mime_type => 'text/calendar', :content => File.read("/tmp/invite_#{interview.candidate.name}_#{interview.user.name}_#{interview.updated_at.to_i}.ics")}
    end
    mail :to => @user.email, :from => NO_REPLY_EMAIL, :subject => "Interview Rescheduled for #{@candidate.name}"
  end

  def interview_cancel_mail(user_id,candidate_id,scheduled_at)
    @user = User.find(user_id)
    @candidate_obj = Candidate.find(candidate_id)
    @scheduled_at = scheduled_at
    mail :to => @user.email, :from => NO_REPLY_EMAIL, :subject => "Interview Cancelled for #{@candidate.name}"
  end

  def interview_feedback_mail(comment)
    @user = comment.user
    @candidate = comment.candidate
    @interview = comment.interview
    @comment = comment
    mail :to => @interview.user.email, :from => @user.email, :subject => "Interview Feedback for #{@candidate.name}"
  end

  def new_message(message)
    @message = message
    attachments[message.resume.original_filename] = message.resume.read
    mail(:to => CAREER_FORM_EMAIL, :from => message.email, :subject => "[New Candidate] #{message.subject}")
  end
end
