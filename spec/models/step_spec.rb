require 'spec_helper'

describe Step do
	
	before do
		User.destroy_all
		Route.destroy_all
		Step.destroy_all
		@user = User.create(email: "test@test.com", password: "password", password_confirmation: "password")
		@route = Route.create(user_id: @user.id, name: "test_route", mode: "driving")
		@step = Step.new(route_id: @route.id, name: "test_step", geocode: "88.88, 88.88", departure: 1.hour.ago, arrival: 1.day.ago)
	end

	subject{@step}

	it {should be_valid}

	it {should respond_to(:route_id)}
	it {should respond_to(:name)}
	it {should respond_to(:route)}
	it {should respond_to(:geocode)}
	it {should respond_to(:departure)}
	it {should respond_to(:arrival)}

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

	describe "departure is blank" do
		before {@step.departure = nil}
		it {should_not be_valid}
	end

	describe "arrival is blank" do
		before {@step.arrival = nil}
		it {should_not be_valid}
	end

	###################

	describe "when geocode is of correct format" do 
		it "should be valid" do
			geocodes = ["0.0, 0.0", "223.12,234.234"]
			geocodes.each do |valid_geocode|
				@step.geocode = valid_geocode
				expect(@step).to be_valid
			end
		end
	end

	describe "when geocode is of incorrect format" do 
		it "should be invalid" do
			geocodes = ["1", "2, 3", "2.23, 54", " 324.234,234.234", "24.,234.234"]
			geocodes.each do |invalid_geocode|
				@step.geocode = invalid_geocode
				expect(@step).not_to be_valid
			end
		end
	end

	after(:each) do
		User.destroy_all
		Route.destroy_all
		Step.destroy_all
	end
end
