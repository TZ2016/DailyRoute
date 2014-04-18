require 'spec_helper'

describe Step do
  
	user = User.create(email: "test@test.com", password: "password", password_confirmation: "password")
	route = Route.create(user_id: user.id, name: "test_route", mode: "driving")
	before do
		@step = Step.new(route_id: route.id, name: "test_step", geocode: "88.88, 88.88", departure: DateTime.now, arrival: DateTime.now)
	end

	subject{@route}
	it {should be_valid}

	it {should response_to(route_id)}
	it {should response_to(name)}
	it {should response_to(geocode)}
	it {should response_to(departure)}
	it {should response_to(arrival)}

	describe "route_id not exist" do
		before {@step.route_id = nil}
		it {should_not be_valid}
	end

	describe "name not exist" do
		before {@step.name = nil}
		it {should be_valid}
	end	

	describe "geocode not exist" do
		before {@step.geocode = nil}
		it {should_not be_valid}
	end

	describe "geocode wrong format" do
		before {@step.geocode = "23"}
		it {should_not be_valid}
	end	

	describe "geocode wrong format" do
		before {@step.geocode = "23, 23"}
		it {should_not be_valid}
	end	

	describe "geocode wrong format" do
		before {@step.geocode = "21.13"}
		it {should_not be_valid}
	end	

	describe "arrival not exist" do
		before {@step.arrival = nil}
		it {should_not be_valid}
	end

	describe "departure not exist" do
		before {@step.departure = nil}
		it {should_not be_valid}
	end


	after(:each) do
		User.destroy_all
		Route.destroy_all
		Step.destroy_all
	end
end
