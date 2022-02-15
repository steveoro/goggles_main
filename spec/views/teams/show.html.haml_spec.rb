# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'teams/show.html.haml', type: :view do
  let(:fixture_row) { GogglesDb::Team.first(50).sample }

  # REQUIRES:
  # - rendered: the result returned after the render call
  shared_examples_for('valid rendered team/show headers') do
    it 'shows the name' do
      node = Nokogiri::HTML.fragment(rendered).at_css('td#full-name')
      expect(node).to be_present
      expect(node.text).to include(fixture_row.name).or include(fixture_row.editable_name)
    end

    it 'shows the address' do
      node = Nokogiri::HTML.fragment(rendered).at_css('td#address')
      expect(node).to be_present
      expect(node.text).to include(fixture_row.address.to_s)
      expect(node.text).to include(fixture_row.city&.name) if fixture_row.city
    end

    it 'shows the home_page_url' do
      node = Nokogiri::HTML.fragment(rendered).at_css('td#homepage')
      expect(node).to be_present
    end

    it 'shows the team dashboard buttons section' do
      node = Nokogiri::HTML.fragment(rendered).at_css('section#team-buttons')
      expect(node).to be_present
      expect(node.at_css('a#btn-swimmers')).to be_present
      expect(node.at_css('a#btn-meetings')).to be_present
      expect(node.at_css('a#btn-workshops')).to be_present
    end

    it 'shows the team stats section' do
      node = Nokogiri::HTML.fragment(rendered).at_css('section#team-stats')
      expect(node).to be_present
    end
  end

  # Test basic/required content:
  context 'when rendering with data,' do
    before do
      expect(fixture_row).to be_a(GogglesDb::Team).and be_valid
      assign(:team, fixture_row)
      render
    end

    it_behaves_like('valid rendered team/show headers')

    it 'does NOT shows the various sensitive contact information' do
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#contact-name')).not_to be_present
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#phone-mobile')).not_to be_present
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#phone-number')).not_to be_present
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#fax-number')).not_to be_present
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#e-mail')).not_to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when rendering with valid data and a valid user logged-in with CRUD grants,' do
    subject(:parsed_node) { Nokogiri::HTML.fragment(rendered) }

    let(:current_user) { GogglesDb::User.first(50).sample }

    before do
      expect(fixture_row).to be_a(GogglesDb::Team).and be_valid
      expect(current_user).to be_a(GogglesDb::User).and be_valid
      FactoryBot.create(:admin_grant, user: current_user, entity: 'Team')
      expect(GogglesDb::GrantChecker.crud?(current_user, 'Team')).to be true
      sign_in(current_user)
      allow(view).to receive(:current_user).and_return(current_user)
      assign(:team, fixture_row)
      render
    end

    it_behaves_like('valid rendered team/show headers')

    it 'shows some various (sensitive) contact information' do
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#contact-name')).to be_present
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#phone-mobile')).to be_present
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#phone-number')).to be_present
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#fax-number')).to be_present
      expect(Nokogiri::HTML.fragment(rendered).at_css('td#e-mail')).to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
