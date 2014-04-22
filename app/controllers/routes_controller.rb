class RoutesController < ApplicationController

  before_action :signed_in_user, only: [:index, :create, :destroy]
  before_action :correct_route,  only: [:destroy]

  # list all routes that belong to the current user
  def index
    @routes = current_user.routes
  end

  # create a list of routes from a single request
  def create
    @routes = []
    @messages = []
  	result = solve(route_params)
    if result[:errCode] == 1 and build_routes(result[:routes])
      flash[:success] = "Route created!"
      respond_to do |format|
        format.html { render "show_list" } #FIXME
        format.json { render :json => result }
      end
    elsif result[:errCode] == 1
      flash[:error] = 'Route generated but encounter errors while saving'
      respond_to do |format|
        format.html { redirect_to root_url } #FIXME
        format.json { render :json => result }
      end
    else
      flash[:error] = "route is not generated, reason to be specified"
      respond_to do |format|
        format.html { redirect_to root_url } #FIXME
        format.json { render :json => result }
      end
    end
  end
  
  # to show a view on a route (depend on @route)
  def show 
  end

  # to show a list of routes (depend on @routes)
  def show_list #FIXME
  end

  # render the view to edit a route
  def edit
  end

  # to update a route
  def update
  end

  # to remove a route
  def destroy
    @route.destroy
    redirect_to routes_path
  end

  private

    def route_params
      params.require(:route).permit! #FIXME
    end
  
    def correct_route
      @route = current_user.routes.find_by(id: params[:id])
      redirect_to root_url if @route.nil?
    end

    def build_routes(routes_list) #FIXME
      begin
      	routes_list.each_with_index do |r, i_r|
      		route = current_user.routes.build(name: r[:name], mode: r[:mode])
      		route.save!
      		@routes << route

          begin
        		r[:steps].each_with_index do |s, i_s|
        			step = route.steps.build(name: s[:name], geocode: s[:geocode],
        					     arrival: s[:arrival], departure: s[:departure])
        			step.save!
            end
          rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => invalid
            puts invalid.record.errors
          end
      	end
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => invalid
        puts invalid.record.errors
      end
    end

end
