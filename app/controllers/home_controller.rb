class HomeController < ApplicationController
  before_filter :authenticate

  def index
      redirect_to interviews_url, :notice => flash[:notice]
  end
end
