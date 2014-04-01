class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      sign_in user
      render :json => {errCode: 1, user: current_user.email}
    else
      render :json => {errCode: -1}
    end
  end

  def destroy
    sign_out
    render :json => {errCode: 1}
  end
end
