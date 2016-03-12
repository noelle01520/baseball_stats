require 'spec_helper'

RSpec.describe "index page", :type => :request do
  it "displays the correct default year" do
    visit '/'

    within 'h1' do
      page.should have_content "Hitting stats - 1998"
    end
  end
end