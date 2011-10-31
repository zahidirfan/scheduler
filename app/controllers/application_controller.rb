class ApplicationController < ActionController::Base
  protect_from_forgery
  #check_authorization
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :notice => exception.message
  end
  
  helper_method :feedback_status_hash, :check_user_privilege, :check_user_privilege, :user_roles_hash, :current_user, :check_admin_or_hr, :load_candidate
  
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
    {"Clear" => "1", "Hold" => "2", "Drop" => "3"}
  end
  
  def check_admin_or_hr(t)
    return ["Administrator", "Hr"].include?(t) ? true : false
  end
  
  def load_candidate
    key = params[:controller].to_s.singularize.to_sym
    c = params.key?(key) ? params[key][:candidate_id] : params[:candidate_id]
    @candidate = Candidate.find(c)
  end
  
end
