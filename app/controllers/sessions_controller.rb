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

  def fb_login
    # params[:fb_login] email, access_token
    user = User.find_by_email(params[:session][:email])
    if user
      if user.fb_token
        sign_in user
        render :js => "window.location = '#{main_path}'"
      else
        if user.password == '1qaz2wsx3edc4rfv' and user.password_confirmation == '123123' 
          sign_in user
        else
           # same email address without fb login
          render :js => "alert('email already exists')"
        end
      end
    else
      user = User.create(email: params[:session][:email], password: '1qaz2wsx3edc4rfv', password_confirmation: '123123')
      sign_in user
      # render :js => "window.location = '#{signup_path}'"
      render :js => "window.location = '#{main_path}'"
    end
  end
end
