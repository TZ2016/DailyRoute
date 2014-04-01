class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      sign_in user
      # redirect_back_or user
      render :json => {errCode: 1, user: current_user.email}
    else
      # flash.now[:error] = 'Invalid email/password combination'
      render :json => {errCode: -1}
    end
  end

  # def current_user
  # 	render :json => {status: signed_in?, user: current_user.email}
  # end

  def destroy
    sign_out
    # redirect_to root_url
  end
end
