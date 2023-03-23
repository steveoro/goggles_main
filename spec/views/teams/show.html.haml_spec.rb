# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'teams/show.html.haml', type: :view do
  let(:fixture_row) { GogglesDb::Team.first(80).sample }
  let(:stats_row) { GogglesDb::TeamStat.new(fixture_row) }

  # REQUIRES:
  # - rendered: the result returned after the render call
  shared_examples_for('valid rendered team/show headers') do
    it 'shows the name' do
      node = Nokogiri::HTML.fragment(rendered).at_css('td#full-name')
      expect(node).to be_present
      expect(node.text.strip).to include(fixture_row.name).or include(fixture_row.editable_name)
    end

    it 'shows the address' do
      node = Nokogiri::HTML.fragment(rendered).at_css('td#address')
      expect(node).to be_present
      expect(node.text.strip).to include(fixture_row.address.to_s)
      expect(node.text.strip).to include(fixture_row.city&.name) if fixture_row.city
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
  #-- -------------------------------------------------------------------------
  #++

  # REQUIRES:
  # - rendered: the result returned after the render call
  # - stats_row: the prepared GogglesDb::TeamStat collection from the fixture row
  # ASSUMES:
  # - stats_row.results.count > 0 (needs a fixture team with at least some meeting results)
  shared_examples_for('federation stats partial') do
    it 'includes the team stats table' do
      node = Nokogiri::HTML.fragment(rendered).at_css('section#team-stats table')
      expect(node).to be_present
    end

    context 'for each returned stat member,' do
      it 'shows the federation name' do
        names = Nokogiri::HTML.fragment(rendered).css('section#team-stats table b.federation-name').map(&:text)
        expect(names).to match_array(stats_row.results.map { |r| r['federation_name'] })
      end

      it 'shows the affiliation count' do
        values = Nokogiri::HTML.fragment(rendered).css('section#team-stats table b.affiliations-count').map(&:text)
        expect(values).to match_array(stats_row.results.map { |r| r['affiliations_count'].to_s })
      end

      it 'shows the meeting count' do
        values = Nokogiri::HTML.fragment(rendered).css('section#team-stats table b.meetings-count').map(&:text)
        expect(values).to match_array(stats_row.results.map { |r| r['meetings_count'].to_s })
      end

      it 'shows the update date' do
        values = Nokogiri::HTML.fragment(rendered).css('section#team-stats table .max-updated-at').map(&:text)
        expect(values).to match_array(stats_row.results.map { |r| r['max_updated_at'].to_s })
      end

      it 'shows the first meeting show link (if a first meeting was found within the stats)' do
        # Max 2 results are possible (min 0), depending on the random team fixture selected:
        if stats_row.results.first['first_meeting'].present?
          node_html = Nokogiri::HTML.fragment(rendered).css('section#team-stats table .first-meeting a')[0].to_html
          expect(node_html).to eq(view.meeting_show_link(stats_row.results[0]['first_meeting']))
        end
        if stats_row.results.count > 1 && stats_row.results[1]['first_meeting'].present?
          node_html = Nokogiri::HTML.fragment(rendered).css('section#team-stats table .first-meeting a')[1].to_html
          expect(node_html).to eq(view.meeting_show_link(stats_row.results[1]['first_meeting']))
        end
      end

      it 'shows the last meeting show link (if a last meeting was found within the stats)' do
        # Max 2 results are possible (min 0), depending on the random team fixture selected:
        if stats_row.results.first['last_meeting'].present?
          node_html = Nokogiri::HTML.fragment(rendered).css('section#team-stats table .last-meeting a')[0].to_html
          expect(node_html).to eq(view.meeting_show_link(stats_row.results[0]['last_meeting']))
        end
        if stats_row.results.count > 1 && stats_row.results[1]['last_meeting'].present?
          node_html = Nokogiri::HTML.fragment(rendered).css('section#team-stats table .last-meeting a')[1].to_html
          expect(node_html).to eq(view.meeting_show_link(stats_row.results[1]['last_meeting']))
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Test basic/required content:
  context 'when rendering with valid data,' do
    before do
      expect(fixture_row).to be_a(GogglesDb::Team).and be_valid
      expect(stats_row).to be_a(GogglesDb::TeamStat).and be_present

      assign(:team, fixture_row)
      assign(:stats, stats_row)
      render
    end

    it_behaves_like('valid rendered team/show headers')
    it_behaves_like('federation stats partial')

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
      expect(stats_row).to be_a(GogglesDb::TeamStat).and be_present
      expect(current_user).to be_a(GogglesDb::User).and be_valid
      FactoryBot.create(:admin_grant, user: current_user, entity: 'Team')
      expect(GogglesDb::GrantChecker.crud?(current_user, 'Team')).to be true
      sign_in(current_user)
      allow(view).to receive(:current_user).and_return(current_user)

      assign(:team, fixture_row)
      assign(:stats, stats_row)
      render
    end

    it_behaves_like('valid rendered team/show headers')
    it_behaves_like('federation stats partial')

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
