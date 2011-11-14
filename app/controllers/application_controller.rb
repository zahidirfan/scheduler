class ApplicationController < ActionController::Base
  protect_from_forgery
  #check_authorization
  include CommonAppMethods

  rescue_from CanCan::AccessDenied do |exception|
    if current_user.type.to_s == "Interviewer"
      redirect_to interviews_url, :notice => exception.message
    else
      redirect_to root_url, :notice => exception.message
    end
  end

  helper_method :hiring_status_hash, :feedback_status_hash, :check_user_privilege, :user_roles_hash, :current_user, :check_admin_or_hr, :load_candidate

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

  def load_candidate
    key = params[:controller].to_s.singularize.to_sym
    c = params.key?(key) ? params[key][:candidate_id] : params[:candidate_id]
    @candidate = Candidate.find(c)
  end

end
