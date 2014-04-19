class UsersController < ApplicationController

  before_action :signed_in_user,
                only: [:edit, :update, :destroy, :remove_all_routes]
  before_action :correct_user,   only: [:edit, :update, :remove_all_routes]

  def index
    @users = User.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    puts "=========="
    puts params
    @user = User.new(user_params)
    # @user = params[:user] ? User.new(user_params) : User.new_guest
    
    if @user.save
      # current_user.move_to(@user) if current_user and current_user.guest?
      sign_in @user
      flash[:success] = "You are logged in!"
      respond_to do |format|
        format.html { redirect_to @user }
        format.json { render :json => {errCode: 1} }
      end
    else
      puts "==========create user error========="
      puts params
      puts @user.errors.full_messages
      respond_to do |format|
        format.html { render root_path }
        format.json { render :json => {errCode: -1, reasons: @user.errors.full_messages} }
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
        format.json { render :json => {errCode: 1} }
      end
    else
      respond_to do |format|
        format.html { render 'edit' }
        format.json { render :json => {errCode: -1, reasons: @user.errors.full_messages} }
      end
    end
  end

  def remove_all_routes
    @current_user.routes.destroy_all
    redirect_to routes_path
  end

  # def destroy
  #   User.find(params[:id]).destroy
  #   flash[:success] = "User destroyed."
  #   redirect_to users_url
  # end

  private

    def user_params
      params.require(:user).permit(:email, :password,
                                   :password_confirmation)
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

end
