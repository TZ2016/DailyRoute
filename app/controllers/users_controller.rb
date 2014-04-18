class UsersController < ApplicationController
  before_action :signed_in_user,
                only: [:show, :edit, :update, :destroy, :remove_all_routes]
  before_action :correct_user,   only: [:show, :edit, :update, :remove_all_routes]

  # def index
  #   @users = User.paginate(page: params[:page])
  # end

  def show
    @routes = current_user.routes
  end

  def new
    @user = User.new
  end

  def create
    puts user_params
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "You are logged in!"
      # redirect_to @user
      render :json => {errCode: 1} # FIXME
    else
      # render 'new' # FIXME 
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

  def remove_all_routes
    @current_user.routes.destroy_all
    redirect_to @current_user
  end

  private

    def user_params
      params.permit(:email, :password,
                    :password_confirmation)
      # params.require(:user).permit(:email, :password,
      #                              :password_confirmation)
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

end
