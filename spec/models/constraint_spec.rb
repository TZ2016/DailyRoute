require 'spec_helper'

describe Constraint do

  before do
    @user       = User.create(email: "test@test.com", password: "password", password_confirmation: "password")
    @request    = Request.create(user_id: @user.id, mode: "driving", num_groups: 0)
    @constraint = Constraint.new(request_id: @request.id, name: 'test_constraint', search_text: 'daily route', geocode: '1.0, -1.0', arrive_after: 1.hour.ago, arrive_before: 1.hour.ago, depart_after: 1.hour.ago, depart_before: 1.hour.ago, min_duration: '100', max_duration: '100', priority: 0, group: 0)
  end

  subject { @constraint }

  it { should be_valid }

  it { should respond_to(:request) }
  it { should respond_to(:request_id) }
  it { should respond_to(:name) }
  it { should respond_to(:search_text) }
  it { should respond_to(:geocode) }
  it { should respond_to(:arrive_before) }
  it { should respond_to(:arrive_after) }
  it { should respond_to(:depart_before) }
  it { should respond_to(:depart_after) }
  it { should respond_to(:min_duration) }
  it { should respond_to(:max_duration) }
  it { should respond_to(:priority) }
  it { should respond_to(:group) }

  describe "request_id not exist" do
    before { @constraint.request_id = nil }
    it { should_not be_valid }
  end

  describe "name not exist" do
    before { @constraint.name = nil }
    it { should_not be_valid }
  end

  describe "search_text not exist" do
    before { @constraint.search_text = nil }
    it { should_not be_valid }
  end


  describe "geocode not exist" do
    before { @constraint.geocode = nil }
    it { should_not be_valid }
  end

  describe "departure is blank" do
    before { @constraint.depart_after = nil }
    it { should_not be_valid }
  end

  describe "departure is blank" do
    before { @constraint.depart_before = nil }
    it { should_not be_valid }
  end

  describe "arrival is blank" do
    before { @constraint.arrive_after = nil }
    it { should_not be_valid }
  end

  describe "arrival is blank" do
    before { @constraint.arrive_before = nil }
    it { should_not be_valid }
  end

  describe "priority is blank" do
    before { @constraint.priority = nil }
    it { should_not be_valid }
  end

  describe "group is blank" do
    before { @constraint.group = nil }
    it { should_not be_valid }
  end

  ###################GEOCODE

  describe "when geocode is of correct format" do
    it "should be valid" do
      geocodes = ["0.0, 0.0", "223.12,234.234"]
      geocodes.each do |valid_geocode|
        @constraint.geocode = valid_geocode
        expect(@constraint).to be_valid
      end
    end
  end

  describe "when geocode is of incorrect format" do
    it "should be invalid" do
      geocodes = ["1", "2, 3", "2.23, 54", " 324.234,234.234", "24.,234.234"]
      geocodes.each do |invalid_geocode|
        @constraint.geocode = invalid_geocode
        expect(@constraint).not_to be_valid
      end
    end
  end

  ############GROUP#############

  describe "group is zero" do
    before { @constraint.group = 0 }
    it { should be_valid }
  end

  describe "group is zero in string" do
    before { @constraint.group = '0' }
    it { should be_valid }
  end

  describe "group is huge" do
    before { @constraint.group = 100 }
    it { should be_valid }
  end

  describe "group is not integer" do
    before { @constraint.group = 0.5 }
    it { should_not be_valid }
  end

  describe "group is negative" do
    before { @constraint.group = -1 }
    it { should_not be_valid }
  end

  ############PRIORITY#############

  describe "priority is zero" do
    before { @constraint.priority = 0 }
    it { should be_valid }
  end

  describe "priority is zero in string" do
    before { @constraint.priority = '0' }
    it { should be_valid }
  end

  describe "priority is huge" do
    before { @constraint.priority = 100 }
    it { should_not be_valid }
  end

  describe "priority is not integer" do
    before { @constraint.priority = 0.5 }
    it { should_not be_valid }
  end

  describe "priority is negative" do
    before { @constraint.priority = -1 }
    it { should_not be_valid }
  end


  after(:each) do
    # User.find_by_email('test@test.com').destroy
  end
end
