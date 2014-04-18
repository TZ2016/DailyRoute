class TestsController < ApplicationController

	#########route

	# return the name of all routes of the user
	def routes_of_user
		if check_user
			rtn = []
			current_user.routes do |r|
				rtn << r.name
			end
			render :json => { errCode: 1, routes: rtn }
		else
			render :json => { errCode: -1 }
		end
	end

	def remove_all_routes_of
		if check_user
			current_user.routes.destroy_all
			render :json => { errCode: 1 }
		else
			render :json => { errCode: -1 }
		end
	end

	def add_route_to
		if check_user
			route = current_user.routes.build(name: params[:route][:name], mode: params[:route][:mode])
			if route.save
				render :json => { errCode: 1 }
			else
				render :json => { errCode: -1, reason: "not saved" }
			end
		else
			render :json => { errCode: -1 }
		end
	end

	############reset

	def resetAll
		User.destroy_all
		Route.destroy_all
		Step.destroy_all
		render :json => { errCode: 1 }
	end

	def resetUser
		User.destroy_all
		render :json => { errCode: 1 }
	end

	def resetRoute
		Route.destroy_all
		render :json => { errCode: 1 }
	end

	def resetStep
		Step.destroy_all
		render :json => { errCode: 1 }
	end

	private 

		def check_user
			user = User.find_by(email: params[:session][:email].downcase)
			if user && user.authenticate(params[:session][:password])
			  sign_in user
			  return true
			else
			  return false
			end
		end

end
