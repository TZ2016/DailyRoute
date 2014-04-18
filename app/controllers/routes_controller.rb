class RoutesController < ApplicationController

  before_action :signed_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  def create

  	result = solve(route_params)
    # result = check_route(route_params)
    if result[:errCode] == 1
      @routes = []
      build_routes(result[:routes])
      flash[:success] = "Route created!"
      puts "==================================="
      render :json => result
      # render "show"
    else
      flash[:error] = "errcode is not 1"
      render :json => result
      # redirect_to root_url #FIXME
      # render "static_pages/main"
    end
  end
  
  def show
  end

  def destroy
    @route.destroy
    redirect_to root_url
  end

  private

    def route_params
      params.require(:route).permit!
      # puts "===="
      # puts params.require(:route).permit!
    end
  
    def check_route(input)
      rtn = {}
      rtn[:errCode] = 1
      step = {name: "step", geocode: "88.88, 99.99", departure: DateTime.new, arrival: DateTime.new}
      route = {steps: [step, step], name: "route", mode: "waLking"}
      rtn[:routes] = [route, route]
      return rtn
    end

    def correct_user
      @route = current_user.routes.find_by(id: params[:id])
      redirect_to root_url if @route.nil?
    end

    def build_routes(routes_list)
    	puts "build routes"
    	puts routes_list
    	routes_list.each do |r|
    		route = current_user.routes.build(name: r[:name], mode: r[:mode])
    		puts route.errors.full_messages unless route.save
    		@routes << route

    		r[:steps].each do |s|
    			step = route.steps.build(name: s[:name], geocode: s[:geocode],
    					     arrival: s[:arrival], departure: s[:departure])
    			step.save
    		end
    	end
    end
end
