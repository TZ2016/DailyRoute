class StaticPageController < ApplicationController
	
	def main
		@pagehelper_active = "Main"
	end

	def about
		@pagehelper_active = "About"
	end

	def tutorial
		@pagehelper_active = "Tutorial"
	end

	def resetAll
		User.destroy_all
		Route.destroy_all
		Step.destroy_all
		render :json => { errCode: 1 }
	end

end
