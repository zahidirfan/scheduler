class HomeController < ApplicationController
  before_filter :authenticate

  def index
    if current_user.type.to_s == "Interviewer"
      redirect_to interviews_url, :notice => flash[:notice]
    else
      redirect_to candidates_url, :notice => flash[:notice]
    end
  end
end
