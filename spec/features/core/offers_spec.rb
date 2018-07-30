require 'rails_helper'

describe "Offers" do

  let(:ask) { FB.create(:offer_bf).offer          }
  let(:bid) { FB.create(:offer_bu).offer          }

  it "renders index (empty)" do
    visit "/core/offers"
    expect(page).to_not be_nil
  end

  it "renders index (with element)", USE_VCR do
    hydrate(ask, bid)
    visit "/core/offers"
    expect(page).to_not be_nil #.
  end
end