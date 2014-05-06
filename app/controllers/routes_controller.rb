class RoutesController < ApplicationController

  before_action :signed_in_user, only: [:destroy]
  before_action :correct_route, only: [:destroy]


  # create a list of routes from a single request
  def create
    @routes   = []
    result    = solve(route_params)
    @result   = result
    if result[:errCode] == 1
      if build_routes(result[:routes])
        flash.now[:success] = 'Route created!'
        respond_to do |format|
          format.js
          format.html { render 'show_list' } #FIXME
          format.json { render :json => result }
        end
      else
        flash.now[:error] = 'Route generated but encounter errors while saving'
        respond_to do |format|
          format.html { redirect_to root_url } #FIXME
          format.json { render :json => { errCode: -100 } }
        end
      end
    else
      flash.now[:error] = 'route is not generated, reason to be specified'
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

  # return javascript to expand the accordion
  def draw
    @route = Route.find(params[:id])
    gon.route = @route
    gon.mode = @route.mode
    respond_to do |format|
      format.js
    end
  end

  # render the view to edit a route
  def edit
  end

  # to update a route
  def update
  end

  # to remove a route
  def destroy
    flash[:success] = 'Route:' + @route.name + '(id=' + @route.id.to_s + ') is deleted.'
    @route.destroy
    respond_to do |format|
      format.html { redirect_to current_user }
      format.js #FIXME
    end
  end

  private

  def route_params
    params.require(:route).permit! #FIXME
  end

  def correct_route
    @route = current_user.routes.find_by(id: params[:id])
    redirect_to root_url if @route.nil?
  end

  def build_routes(routes_list)
    user_id = signed_in? ? current_user.id : 0
    routes_list.each do |r|
      route_params = { :name             => r[:name],
                       :mode             => r[:mode],
                       :user_id          => user_id,
                       :steps_attributes => [] }
      r[:steps].each do |s|
        route_params[:steps_attributes] << { :name      => s[:name],
                                             :geocode   => s[:geocode],
                                             :arrival   => s[:arrival],
                                             :departure => s[:departure] }
      end
      @routes << Route.new(route_params) # nested attributes
    end
    @routes.each do |r|
      return false unless r.save
    end
    true
  end

end
