class RoutesController < ApplicationController
  require "solve"
  include Solver
  before_action :signed_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  def create
    @route = current_user.routes.build(route_params)
    if @route.save
      flash[:success] = "Route created!"
      redirect_to root_url
    else
	  redirect_to root_url #FIXME
      # render "static_pages/main"
    end
  end
  
  def destroy
    @route.destroy
    redirect_to root_url
  end

  private

    def route_params
      params.require(:route).permit!
      puts "===="
      puts params.require(:route).permit!
    end
  
    def correct_user
      @route = current_user.routes.find_by(id: params[:id])
      redirect_to root_url if @route.nil?
    end
end
