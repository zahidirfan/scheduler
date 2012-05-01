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

require 'open-uri'

class Notifier < ActionMailer::Base
  include UserInfo
  helper :application

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

  def candidate_profile_delete_mail(candidate, user, current_user, scheduled_at)
    @user = user
    @current_user = current_user
    @candidate_name = candidate
    @interview_scheduled_at = scheduled_at
    subject = @interview_scheduled_at.nil? ? "#{@candidate_name} Profile has been deleted" : "Interview Cancelled for #{@candidate_name} scheduled on #{@interview_scheduled_at}"
    mail :to => @user.email, :from => NO_REPLY_EMAIL, :subject => subject
  end

  def interview_schedule_mail(interview, user=nil, attachment=true)
    @user, @follower = user.nil? ? [interview.user, false] : [user, true]
    @candidate = interview.candidate
    @interview = interview
    @interviewer = interview.user
    if attachment
      attachments[@candidate.resume_file_name] = open(@candidate.resume.url) { |f| f.read }
      attachments["calendar_invite.ics"] = {:mime_type => 'text/calendar', :content => open("/tmp/invite_#{interview.candidate.name}_#{interview.user.name}_#{interview.updated_at.to_i}.ics") { |f| f.read } }
    end
    mail :to => @user.email, :cc => interview.print_interviewer_emailids, :from => NO_REPLY_EMAIL, :subject => "Interview Scheduled for #{@candidate.name}"
  end

  def interview_reschedule_mail(interview, changes, other_interviewers, user=nil, attachment=true)
    @other_interviewers = other_interviewers
    @user, @follower = user.nil? ? [interview.user, false] : [user, true]
    @candidate = interview.candidate
    @interview = interview
    @interviewer = interview.user
    @changes = changes
    if attachment
      attachments[@candidate.resume_file_name] = open(@candidate.resume.url) { |f| f.read }
      attachments["calendar_invite.ics"] = {:mime_type => 'text/calendar', :content => open("/tmp/invite_#{interview.candidate.name}_#{interview.user.name}_#{interview.updated_at.to_i}.ics") { |f| f.read } }
    end
    mail :to => @user.email, :cc => interview.print_interviewer_emailids, :from => NO_REPLY_EMAIL, :subject => "#{interview.interview_type} Interview Rescheduled for #{@candidate.name}"
  end

   def interview_cancel_mail(user_id, candidate_name, old_changes, old_interviewers, user=nil)
    @interviewer = User.find(user_id)
    @user, @follower = user.nil? ? [@interviewer, false] : [user, true]
    @candidate_name = candidate_name
    @changes = old_changes
    @old_interviewers = old_interviewers
    mail :to => @user.email, :cc => old_interviewers.joins(:user).select("users.email").collect(&:email).join(', '), :from => NO_REPLY_EMAIL, :subject => "Interview Cancelled for #{@candidate_name} scheduled on #{@changes[:int_schedule]}"
  end


  def interview_feedback_mail(comment, user=nil)
    @user, @follower = user.nil? ? [comment.interview.user, false ] : [user, true]
    @comment_user = comment.user
    @candidate_name = comment.candidate.name
    @interview = comment.interview
    @comment = comment
    @changes = {:int_type => @interview.interview_type, :int_schedule => @interview.formated_scheduled_at}    
    @interviewer = comment.interview.user
    @scheduled_at = comment.interview.formated_scheduled_at
    subject = comment.status == 'Cancelled' ? "Interview Cancelled for #{@candidate_name} scheduled on #{@scheduled_at}" : "Interview Feedback for #{@candidate_name}"
    mail :to => @user.email, :cc => @interview.print_interviewer_emailids, :from => @comment.user.email, :subject => subject
  end

  def new_message(message)
    @message = message
    attachments[message.resume.original_filename] = message.resume.read
    mail(:to => CAREER_FORM_EMAIL, :from => message.email, :subject => "[New Candidate] #{message.subject}")
  end

  def interview_request_mail(request, user=nil)
    interview = request.interview
    @user, @follower = user.nil? ? [interview.user, false] : [user, true]
    @candidate = interview.candidate
    @interview = interview
    @request = request
    @interviewer = interview.user
    mail :to => interview.print_interviewer_emailids, :from => NO_REPLY_EMAIL, :subject => "Request On Interview Scheduled for #{@candidate.name}"
  end 
end
