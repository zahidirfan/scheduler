class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :feedback_status_hash, :check_user_privilege, :check_user_privilege, :user_roles_hash, :current_user
  
  private

  def check_user_privilege
    unless current_user.type == "Hr"
      redirect_to interviews_path, :notice => "You don't have enough privileges to access this section."
    end
  end
  
  def authenticate_admin
    return if current_user.admin?
    redirect_to root_url, :notice => "This section needs administrator Privileges"
  end
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def user_roles_hash
    {"Business Manager" => "Bm", "Human Resource" => "Hr", "Interviewer" => "Interviewer", "Project Lead" => "Pl", "Administrator" => "Administrator"}
  end
  
  def feedback_status_hash
    {"Proceed to Next Round" => "1", "Put on Hold" => "2", "Rejected" => "3"}
  end
    
end
