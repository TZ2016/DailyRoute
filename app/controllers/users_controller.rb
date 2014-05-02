class UsersController < ApplicationController
  before_action :signed_in_user,
                only: [:show, :edit, :update, :destroy, :remove_all_routes]
  before_action :correct_user, only: [:edit, :update, :remove_all_routes]

  def new
    @user = User.new
  end

  def new_fb
    @user = User.new(user_params)
    render 'new'
  end

  def show
    @routes = current_user.routes.paginate(:page => params[:page], :per_page => 5)
  end

  def create
    @user = User.new(user_params)
    # @user = user_params[:email].empty? ? User.new_guest : User.new(user_params)

    if @user.save
      current_user.move_to(@user) if current_user and current_user.guest?
      sign_in @user
      flash[:success] = "Welcome to Daily Route, " + @user.email + '!'
      respond_to do |format|
        format.html { redirect_to main_path }
        format.json { render :json => { errCode: 1 } }
      end
    else
      respond_to do |format|
        format.html { render 'new' }
        format.json { render :json => { errCode: -1, reasons: @user.errors.full_messages } }
      end
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      respond_to do |format|
        format.html { redirect_to @user }
        format.json { render :json => { errCode: 1 } }
      end
    else
      respond_to do |format|
        format.html { render 'edit' }
        format.json { render :json => { errCode: -1, reasons: @user.errors.full_messages } }
      end
    end
  end

  def remove_all_routes
    flash[:success] = "Your routes are purged!"
    @current_user.routes.destroy_all
    redirect_to current_user
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(:email, :password,
                                 :password_confirmation, :fb_token)
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

end
