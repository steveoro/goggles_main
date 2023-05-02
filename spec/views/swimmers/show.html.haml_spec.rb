# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'swimmers/show.html.haml' do
  let(:fixture_row) { GogglesDb::Swimmer.first(150).sample }
  let(:stats_row) { GogglesDb::SwimmerStat.new(fixture_row) }

  # Test basic/required content:
  context 'when rendering with data,' do
    subject { Nokogiri::HTML.fragment(rendered) }

    before do
      expect(fixture_row).to be_a(GogglesDb::Swimmer).and be_valid
      expect(stats_row).to be_a(GogglesDb::SwimmerStat).and be_present

      assign(:swimmer, fixture_row)
      assign(:stats, stats_row)
      render
    end

    it 'shows the swimmer full name' do
      node = subject.at_css('td#full-name')
      expect(node).to be_present
      expect(node.text).to include(fixture_row.first_name)
      expect(node.text).to include(fixture_row.last_name)
    end

    it 'shows the year of birth' do
      node = subject.at_css('td#year-of-birth')
      expect(node).to be_present
      expect(node.text).to include(fixture_row.year_of_birth.to_s)
    end

    it 'shows the current category code' do
      expect(subject.at_css('td#curr-cat-code')).to be_present
    end

    it 'shows the last category code' do
      expect(subject.at_css('td#last-cat-code')).to be_present
    end

    it 'shows the links to the affiliated teams' do
      expect(subject.at_css('td#team-links')).to be_present
    end

    it 'includes the setion for the swimmer action buttons' do
      expect(subject.at_css('section#swimmer-buttons')).to be_present
      stats_btn = subject.at_css('section#swimmer-buttons a#btn-stats')
      expect(stats_btn).to be_present
      expect(stats_btn.attributes['href'].value).to eq(swimmer_history_recap_path(fixture_row))
    end

    it 'shows the swimmer stats button' do
      btn = subject.at_css('section#swimmer-buttons a#btn-stats')
      expect(btn).to be_present
      expect(btn.attributes['href'].value).to eq(swimmer_history_recap_path(fixture_row))
    end

    it 'shows the swimmer meetings button' do
      btn = subject.at_css('section#swimmer-buttons a#btn-meetings')
      expect(btn).to be_present
      expect(btn.attributes['href'].value).to eq(meetings_for_swimmer_path(fixture_row))
    end

    it 'shows the swimmer workshops button' do
      btn = subject.at_css('section#swimmer-buttons a#btn-workshops')
      expect(btn).to be_present
      expect(btn.attributes['href'].value).to eq(user_workshops_for_swimmer_path(fixture_row))
    end

    context 'when the swimmer has any result stats,' do
      let(:section) { subject.at_css('section#swimmer-stats') }

      it 'renders the swimmer stats section' do
        return true if stats_row.result.blank?

        expect(section).to be_present
      end

      it 'shows the meeting count' do
        return true if stats_row.result.blank?

        expect(section.at_css('td#meetings-count')).to be_present
        expect(section.at_css('td#meetings-count').text.strip).to eq(stats_row.result['meetings_count'].to_s)
      end

      it 'shows the link to the first meeting (when available)' do
        return true if stats_row.result.blank? || stats_row.result&.fetch('first_meeting', nil).blank?

        expect(section.at_css('td#first-meeting')).to be_present
        expect(section.at_css('td#first-meeting a').to_html.strip).to eq(
          view.meeting_show_link(stats_row.result['first_meeting'])
        )
      end

      it 'shows the link to the last meeting (when available)' do
        return true if stats_row.result.blank? || stats_row.result&.fetch('last_meeting', nil).blank?

        expect(section.at_css('td#last-meeting')).to be_present
        expect(section.at_css('td#last-meeting a').to_html.strip).to eq(
          view.meeting_show_link(stats_row.result['last_meeting'])
        )
      end

      it 'shows the total individual events attended' do
        return true if stats_row.result.blank?

        expect(section.at_css('td#individual-count')).to be_present
        expect(section.at_css('td#individual-count').text.strip).to eq(stats_row.result['individual_count'].to_s)
      end

      it 'shows the total distance swam in meters for all the individual events' do
        return true if stats_row.result.blank?

        expect(section.at_css('td#individual-meters')).to be_present
        expect(section.at_css('td#individual-meters').text.strip).to eq(stats_row.result['individual_meters'].to_s)
      end

      it 'shows the total time swam for all the individual events' do
        return true if stats_row.result.blank?

        expect(section.at_css('td#individual-timing')).to be_present
        expect(section.at_css('td#individual-timing').text.strip).to include(
          Timing.new(
            hundredths: stats_row.result['individual_hundredths'],
            seconds: stats_row.result['individual_seconds'],
            minutes: stats_row.result['individual_minutes']
          ).to_s
        )
      end

      it 'shows the total disqualify count when positive or a message about the lack of any DSQ result' do
        return true if stats_row.result.blank?

        expect(section.at_css('td#individual-dsq-count')).to be_present
        if stats_row.result['individual_disqualified_count'].to_i.positive?
          expect(section.at_css('td#individual-dsq-count').text.strip).to eq(stats_row.result['individual_disqualified_count'].to_s)
        else
          expect(section.at_css('td#individual-dsq-count').text.strip).to include(I18n.t('swimmers.radiography.no_disqualifications'))
        end
      end

      it 'shows the max scored points (when available)' do
        return true if stats_row.result.blank? || stats_row.result&.fetch('max_fin_points', nil).blank?

        expect(section.at_css('td#max-points')).to be_present
        expect(section.at_css('td#max-points').text.strip).to eq(stats_row.result['max_fin_points']['standard_points'].to_s)
      end

      it 'shows the min scored points (when available)' do
        return true if stats_row.result.blank? || stats_row.result&.fetch('min_fin_points', nil).blank?

        expect(section.at_css('td#min-points')).to be_present
        expect(section.at_css('td#min-points').text.strip).to eq(stats_row.result['min_fin_points']['standard_points'].to_s)
      end

      it 'shows the total scored points' do
        return true if stats_row.result.blank?

        expect(section.at_css('td#tot-points')).to be_present
        expect(section.at_css('td#tot-points').text.strip).to eq(stats_row.result['total_fin_points'].to_s)
      end

      it 'shows the total IronMaster competitions attended' do
        return true if stats_row.result.blank?

        expect(section.at_css('td#ironmasters')).to be_present
        expect(section.at_css('td#ironmasters').text.strip).to eq(stats_row.result['irons_count'].to_s)
      end

      it 'shows the total relay events attended' do
        return true if stats_row.result.blank?

        expect(section.at_css('td#relay-count')).to be_present
        expect(section.at_css('td#relay-count').text.strip).to eq(stats_row.result['relays_count'].to_s)
      end

      it 'shows the total distance swam in meters for all the relay events' do
        return true if stats_row.result.blank?

        expect(section.at_css('td#relay-meters')).to be_present
        expect(section.at_css('td#relay-meters').text.strip).to eq(stats_row.result['relay_meters'].to_s)
      end

      it 'shows the total time swam for all the relay events' do
        return true if stats_row.result.blank?

        expect(section.at_css('td#relay-timing')).to be_present
        expect(section.at_css('td#relay-timing').text.strip).to include(
          Timing.new(
            hundredths: stats_row.result['relay_hundredths'],
            seconds: stats_row.result['relay_seconds'],
            minutes: stats_row.result['relay_minutes']
          ).to_s
        )
      end

      it 'shows the total relay disqualify count' do
        return true if stats_row.result.blank?

        expect(section.at_css('td#relay-dsq-count')).to be_present
        expect(section.at_css('td#relay-dsq-count').text.strip).to eq(stats_row.result['relay_disqualified_count'].to_s)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
