module UsersHelper
  
  def interview_status_count(s)
    @user.comments.where(:status => s).count
  end
  
end
