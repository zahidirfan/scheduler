class ApplicationController < ActionController::Base
  protect_from_forgery
  #check_authorization
  include UserInfo

  rescue_from CanCan::AccessDenied do |exception|
    if !current_user.nil? && current_user.type.to_s == "Interviewer"
      redirect_to interviews_url, :notice => exception.message
    else
      redirect_to root_url, :notice => exception.message
    end
  end

  helper_method :check_user_privilege, :current_user, :check_admin_or_hr, :load_candidate
  before_filter :set_user

  protected

  # Sets the current user into a named Thread location so that it can be accessed
  # by models and observers
  def set_user
    UserInfo.current_user = current_user
  end

  private

  def check_admin_or_hr(t)
    return ["Administrator", "Hr"].include?(t) ? true : false
  end

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
