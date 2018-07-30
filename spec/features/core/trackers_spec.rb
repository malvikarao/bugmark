require 'rails_helper'

describe "Trackers", USE_VCR do

  include_context 'Integration Environment'

  before(:each) { hydrate(tracker1) }

  it "renders index" do
    visit "/core/trackers"
    expect(page).to_not be_nil
  end

  it "renders show" do
    visit "/core/trackers/#{tracker1.uuid}"
    expect(page).to_not be_nil
  end

  # it "clicks thru to show" do
  #   visit "/core/trackers"
  #   click_on "rep.#{tracker1.id}"
  #   expect(page).to_not be_nil
  # end

  it "click thru to bug index" do
    hydrate(issue1)
    visit "/core/trackers"
    find('.buglink').click
    expect(page).to_not be_nil
  end

  it "creates an OBF", USE_VCR do
    login_as(usr1, :scope => :user)
    hydrate(issue1)
    expect(Offer::Buy::Fixed.count).to eq(0)
    expect(Issue.count).to eq(1)

    visit "/core/trackers"
    click_on "fixed"
    click_on "Create"

    expect(Offer::Buy::Fixed.count).to eq(1)
  end

  it "creates an OBU", USE_VCR do
    login_as(usr1, :scope => :user)
    hydrate(issue1)
    expect(Offer::Buy::Unfixed.count).to eq(0)
    expect(Issue.count).to eq(1)

    visit "/core/trackers"
    click_on "unfixed"
    click_on "Create"

    expect(Offer::Buy::Unfixed.count).to eq(1)
  end
end
