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

end
