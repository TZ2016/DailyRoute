class StaticPageController < ApplicationController

  def root
    flash[:info]    = 'Tip: The first location on your list is considered as the start, and the last the end.'
    flash[:warning] = 'You must specify Depart After for the start, and Arrive Before for the end.'
    redirect_to :main
  end

  def main
  end

  def about
  end

  def tutorial
  end

end
