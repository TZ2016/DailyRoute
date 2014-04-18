require 'spec_helper'

describe "Static pages" do

  subject { page }

  describe "Home page" do
    before { visit root_path }

    it "should have title" do
      page.source.should have_selector("title", text: "Daily Route")
    end

    it { should have_content('Daily Route') }
    it { should have_link('Daily Route') }
    it { should have_content('Main') }
    it { should_not have_link('Main') }

    it { should have_content('About') }
    it { should have_link('About') }
    it { should have_content('Tutorial') }
    it { should have_link('Tutorial') }

    describe "for not signed-in users" do
      before do
        sign_out
        visit root_path
      end

      it { should have_button("LogIn") }
      it { should have_button("SignUp") }
      it { should_not have_button("LogOut") }
      it { should have_field("email-field") }
      it { should have_field("password-field") }
    end

    describe "for signed-in users" do
      let!(:user) do
        User.create(email: "test@dailyroute.com", password: "password", password_confirmation: "password")
      end
      before do
        sign_in user
        visit root_path
      end

      # it { should have_button("LogOut")}
      # it { should_not have_button("SignUp") }
      # it { should_not have_button("LogIn") }

    end
  end

  describe "About page" do
    before { visit about_path }

    it { should have_content('About') }
    it { should have_link('About') }
  end

  describe "Tutorial page" do
    before { visit tutorial_path }

    it { should have_content('Tutorial') }
    it { should have_link('Tutorial') }
  end

end