class UsersController < ApplicationController
  before_action :signed_in_user,
                only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def saved_routes
    solve(Route.last.id)
  end

  def new
    @user = User.new
  end

  def create
    puts user_params
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      # flash[:success] = "Welcome to the Sample App!"
      # redirect_to @user
      render :json => {errCode: 1}
    else
      # render 'new'
      puts @user.errors.messages
      render :json => {errCode: -1, reasons: @user.errors.full_messages}
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_url
  end

  private

    def user_params
      params.permit(:email, :password,
                    :password_confirmation)
      # params.require(:user).permit(:email, :password,
      #                              :password_confirmation)
    end

    # Before filters

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

end
