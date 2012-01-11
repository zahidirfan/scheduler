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

  def user_welcome_mail(user, password)
    @user = user
    @password = password
    mail :to => @user.email, :from => NO_REPLY_EMAIL, :subject => "Welcome to Pramati Scheduler"
  end

  def candidate_profile_update_mail(candidate, user, current_user, changes)
    @user = user
    @current_user = current_user
    @candidate_name = candidate.name
    @candidate_changes = changes
    mail :to => @user.email, :from => NO_REPLY_EMAIL, :subject => "Profile updated for #{@candidate_name}"
  end

  def candidate_deleted_mail(candidate, user, current_user, follower=false)
    @user = user
    @current_user = current_user
    @candidate = candidate
    @follower = follower
    mail :to => @user.email, :from => NO_REPLY_EMAIL, :subject => "#{@candidate.name} Profile has been deleted"
  end

  def interview_schedule_mail(interview, user=nil, attachment=true)
    @user, @follower = user.nil? ? [interview.user, false] : [user, true]
    @candidate = interview.candidate
    @interview = interview
    @interviewer = interview.user
    if attachment
      attachments[@candidate.resume_file_name] = File.read(@candidate.resume.path)
      attachments["calendar_invite.ics"] = {:mime_type => 'text/calendar', :content => File.read("/tmp/invite_#{interview.candidate.name}_#{interview.user.name}_#{interview.updated_at.to_i}.ics")}
    end
    mail :to => @user.email, :from => NO_REPLY_EMAIL, :subject => "Interview Scheduled for #{@candidate.name}"
  end

  def interview_reschedule_mail(interview, user=nil, attachment=true)
    @user, @follower = user.nil? ? [interview.user, false] : [user, true]
    @candidate = interview.candidate
    @interview = interview
    @interviewer = interview.user
    if attachment
      attachments[@candidate.resume_file_name] = File.read(@candidate.resume.path)
      attachments["calendar_invite.ics"] = {:mime_type => 'text/calendar', :content => File.read("/tmp/invite_#{interview.candidate.name}_#{interview.user.name}_#{interview.updated_at.to_i}.ics")}
    end
    mail :to => @user.email, :from => NO_REPLY_EMAIL, :subject => "Interview Rescheduled for #{@candidate.name}"
  end

   def interview_cancel_mail(user_id,candidate_name,scheduled_at, user=nil)
    @interviewer = User.find(user_id)
    @user, @follower = user.nil? ? [@interviewer, false] : [user, true]
    @candidate_name = candidate_name
    @scheduled_at = scheduled_at
    mail :to => @user.email, :from => NO_REPLY_EMAIL, :subject => "Interview Cancelled for #{@candidate_name} scheduled on #{scheduled_at}"
  end


  def interview_feedback_mail(comment, user=nil)
    @user, @follower = user.nil? ? [comment.interview.user, false] : [user, true]
    @candidate = comment.candidate
    @interview = comment.interview
    @comment = comment
    @interviewer = comment.interview.user
    @scheduled_at = comment.interview.formated_scheduled_at
    subject = comment.status == 'Cancelled' ? "Interview Cancelled for #{@candidate.name} scheduled on #{@scheduled_at}" : "Interview Feedback for #{@candidate.name}"
    mail :to => @user.email, :from => @comment.user.email, :subject => subject
  end

  def new_message(message)
    @message = message
    attachments[message.resume.original_filename] = message.resume.read
    mail(:to => CAREER_FORM_EMAIL, :from => message.email, :subject => "[New Candidate] #{message.subject}")
  end
end
