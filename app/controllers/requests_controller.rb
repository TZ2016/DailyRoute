class RequestsController < ApplicationController
  def new
    @request = Request.new
  end

  def create
    @request = Request.new(request_params)

    if @request.save
      puts 'haha'
    else
      puts 'ohno'
    end
  end

  private

  def request_params
    params.require(:request).permit!
  end

end
