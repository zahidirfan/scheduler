class CareerController < ApplicationController
  layout :false
  def new
    @candidate = Candidate.new
    @message = Message.new
  end

  def create
    @message = Message.new(params[:message])
    if @message.valid?
      Notifier.new_message(@message).deliver
      redirect_to(career_path, :notice => "Message was successfully sent.")
    else
      flash.now.alert = "Please fill all the fields."
      render :new
    end
  end
end
