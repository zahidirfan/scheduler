class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      session[:last_seen] = Time.now
      redirect_to root_url, :notice => translate('quo_vadis.flash.sign_in.after')
    else
      flash.now.alert = translate('quo_vadis.flash.sign_in.failed')
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to sign_in_url, :notice => translate('quo_vadis.flash.sign_out')
  end

  def forgotten
    if request.get?
      render 'sessions/forgotten'
    elsif request.post?
      if params[:username].present? &&
        (user = QuoVadis.model_class.where(:username => params[:username]).first)
        if user.email.present?
          user.generate_token
          QuoVadis::Notifier.change_password(user).deliver
          redirect_to sign_in_url, :notice => translate('quo_vadis.flash.forgotten.sent_email')
        else
          flash.now[:alert] = translate('quo_vadis.flash.forgotten.no_email')
          render 'sessions/forgotten'
        end
      else
        flash.now[:alert] = translate('quo_vadis.flash.forgotten.unknown')
        render 'sessions/forgotten'
      end
    end
  end


end
