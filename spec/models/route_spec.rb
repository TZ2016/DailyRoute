require 'spec_helper'

describe User do

	
	before do
		User.destroy_all
		Route.destroy_all
		Step.destroy_all
		@user = User.create(email: "test@test.com", password: "password", password_confirmation: "password")
		@route = Route.new(user_id: @user.id, name: "test_route", mode: "driving")
	end

	subject{@route}

	it {should be_valid}
	it {should respond_to(:user_id)}
	it {should respond_to(:name)}
	it {should respond_to(:mode)}

	describe "mode is driving" do
		before { @route.mode = "driving" }
		it {should be_valid}
	end
	
	describe "mode is walking" do
		before { @route.mode = "walking" }
		it {should be_valid}
	end

	describe "mode is transit" do
		before { @route.mode = "transit" }
		it {should be_valid}
	end	

	describe "mode is bicycling" do
		before { @route.mode = "bicycling" }
		it {should be_valid}
	end

	describe "mode is not included" do
		before { @route.mode = "bilibili" }
		it {should_not be_valid}
	end	

	describe "mode not present" do
		before { @route.mode = "" }
		it {should_not be_valid}
	end

	describe "mode is in uppercase" do
		before { @route.mode = "Bicycling" }
		it {should be_valid}
	end

	after(:each) do
  		User.destroy_all
		Route.destroy_all
		Step.destroy_all
	end
end