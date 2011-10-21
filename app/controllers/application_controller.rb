class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :user_roles_hash, :authenticate_admin

  private

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
    
end
