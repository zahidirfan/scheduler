class HomeController < ApplicationController
  before_filter :authenticate
  
  def index
    if ["Interviewer", "Bm"].include?(current_user.type.to_s)
      redirect_to interviews_url, :notice => flash[:notice]
    else
      redirect_to candidates_url
    end
  end
  
end
