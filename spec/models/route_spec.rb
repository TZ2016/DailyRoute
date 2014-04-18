require 'spec_helper'

describe Route do
	
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
	it {should respond_to(:steps)}
	it {should respond_to(:user)}
	it {should respond_to(:name)}
	it {should respond_to(:mode)}


	describe "when user_id is not present" do
		before { @route.user_id = nil }
		it { should_not be_valid }
	end

	#####################MODE############

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

	############ASSOCIATION#############

	describe "steps associations" do

		before { @route.save }
		let!(:older_step) do
			Step.create(route_id: @route.id, name: "step1", geocode: "88.88, 99.99",
						departure: 2.hour.ago, arrival: 3.hour.ago)
		end
		let!(:newer_step) do
			Step.create(route_id: @route.id, name: "step2", geocode: "88.88, 99.99",
						departure: 1.hour.ago, arrival: 1.minute.ago)
		end

		it "should have the right steps in the right order" do
			expect(@route.steps.to_a).to eq [newer_step, older_step]
		end

		it "should destroy associated steps" do
			steps = @route.steps.to_a
			@route.destroy
			expect(steps).not_to be_empty
			steps.each do |step|
				expect(Step.where(id: step.id)).to be_empty
			end
		end
	
	end

	after(:each) do
  		User.destroy_all
		Route.destroy_all
		Step.destroy_all
	end
end