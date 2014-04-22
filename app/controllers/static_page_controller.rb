class StaticPageController < ApplicationController
	
	def main
	end

	def about
	end

	def tutorial
	end

	def resetAll
		User.destroy_all
		Route.destroy_all
		Step.destroy_all
		render :json => { errCode: 1 }
	end

end
