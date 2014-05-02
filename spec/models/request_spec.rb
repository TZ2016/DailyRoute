require 'spec_helper'

describe Request do

  before do
    @user    = User.create(email: "test@test.com", password: "password", password_confirmation: "password")
    @request = Request.new(user_id: @user.id, mode: "driving", num_groups: 0)
  end

  subject { @request }

  it { should be_valid }

  it { should respond_to(:user) }
  it { should respond_to(:user_id) }
  it { should respond_to(:constraints) }
  it { should respond_to(:num_groups) }
  it { should respond_to(:mode) }


  describe "when user_id is not present" do
    before { @request.user_id = nil }
    it { should_not be_valid }
  end

  #####################MODE############

  describe "mode is driving" do
    before { @request.mode = "driving" }
    it { should be_valid }
  end

  describe "mode is walking" do
    before { @request.mode = "walking" }
    it { should be_valid }
  end

  describe "mode is transit" do
    before { @request.mode = "transit" }
    it { should be_valid }
  end

  describe "mode is bicycling" do
    before { @request.mode = "bicycling" }
    it { should be_valid }
  end

  describe "mode is not included" do
    before { @request.mode = "bilibili" }
    it { should_not be_valid }
  end

  describe "mode not present" do
    before { @request.mode = "" }
    it { should_not be_valid }
  end

  describe "mode is in uppercase" do
    before { @request.mode = "Bicycling" }
    it { should be_valid }
  end

  ############NUM GROUPS#############

  describe "num_groups is zero" do
    before { @request.num_groups = 0 }
    it { should be_valid }
  end

  describe "num_groups is zero in string" do
    before { @request.num_groups = '0' }
    it { should be_valid }
  end

  describe "num_groups is huge" do
    before { @request.num_groups = 100 }
    it { should be_valid }
  end

  describe "num_groups is not integer" do
    before { @request.num_groups = 0.5 }
    it { should_not be_valid }
  end

  describe "num_groups is negative" do
    before { @request.num_groups = -1 }
    it { should_not be_valid }
  end

  describe "num_groups is not present" do
    before { @request.num_groups = nil }
    it { should_not be_valid }
  end


  ############ASSOCIATION#############

  # describe "constraints associations" do
  #
  #   before { @request.save }
  #   let!(:older_step) do
  #     Step.create(route_id:  @request.id, name: "step1", geocode: "88.88, 99.99",
  #                 departure: 2.hour.ago, arrival: 3.hour.ago)
  #   end
  #   let!(:newer_step) do
  #     Step.create(route_id:  @request.id, name: "step2", geocode: "88.88, 99.99",
  #                 departure: 1.hour.ago, arrival: 1.minute.ago)
  #   end
  #
  #   it "should have the right steps in the right order" do
  #     expect(@request.steps.to_a).to eq [older_step, newer_step]
  #   end
  #
  #   it "should destroy associated steps" do
  #     steps = @request.steps.to_a
  #     @request.destroy
  #     expect(steps).not_to be_empty
  #     steps.each do |step|
  #       expect(Step.where(id: step.id)).to be_empty
  #     end
  #   end
  #
  # end

  after(:each) do
    User.find_by_email('test@test.com').destroy
  end
end