class StaticPageController < ApplicationController

  def root
    flash[:warning] = 'Beta version: You must log in before creating any route!'
    flash[:info] = 'Tip: The first location on your list is considered as the start, and the last the end.
                    You must specify Depart After for the start, and Arrive Before for the end.'
    redirect_to :main
  end

	def main
	end

	def about
	end

	def tutorial
  end

  def form_test
  end

end
