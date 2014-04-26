class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      sign_in user
      flash[:success] = 'Welcome back, ' + user.email + '!'
      respond_to do |format|
        format.html { redirect_back_or main_path }
        format.json { render :json => { errCode: 1, user: current_user.email } }
      end
    else
      flash.now[:danger] = user.nil? ? 'User does not exist!' : 'Invalid password!'
      respond_to do |format|
        format.html { render 'new' }
        format.json { render :json => { errCode: -1 } }
      end
    end
  end

  def destroy
    sign_out
    flash[:success] = 'You are logged out.'
    respond_to do |format|
      format.html { redirect_to main_path }
      format.json { render :json => { errCode: 1 } }
    end
  end
end
