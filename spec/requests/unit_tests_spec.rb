require 'spec_helper'

describe User do

	before do
		@user = User.new(username: "user0", password: "password")
	end

	subject { @user }

	it { should respond_to(:username) }
	it { should respond_to(:password) }
	it { should respond_to(:counter)  }
	it { should be_valid }

	describe "when username is legal and password is empty" do
		before { @user.password = "" }
		it { should be_valid }
	end

	describe "when username and password are maximally long" do
		before do
			@user.username = "u" * 128
			@user.password = "p" * 128
		end

		it { should be_valid }		
	end	

	describe "when username is not present" do
		before { @user.username = "" }
		it { should_not be_valid }
	end

	describe "when username is too long" do
		before { @user.username = "a" * 129 }
		it { should_not be_valid }
	end

	describe "when password is too long" do
		before do
			@user.username = "user0"
			@user.password = "p" * 129
		end

		it { should_not be_valid }
	end

	describe "when username is not unique" do
		before do
			user_with_same_name = @user.dup
			user_with_same_name.save
		end

		it { should_not be_valid }
	end

	after(:each) do
  		User.delete_all
	end

end
