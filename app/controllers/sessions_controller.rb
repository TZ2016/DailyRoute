class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      sign_in user
      respond_to do |format|
        format.html { redirect_back_or root_path }
        format.json { render :json => {errCode: 1, user: current_user.email} }
      end
    else
      respond_to do |format|
        flash.now.alert = "test alert"
        flash.now[:error] = 'Invalid email/password combination'
        format.html { render 'new' }
        format.json { render :json => {errCode: -1} }
      end
    end
  end

  def destroy
    sign_out

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { render :json => {errCode: 1} }
    end
  end
end
