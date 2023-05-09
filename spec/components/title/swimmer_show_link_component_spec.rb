# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Title::SwimmerShowLinkComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:fixture_row) { GogglesDb::Swimmer.first(200).sample }

  before { expect(fixture_row).to be_a(GogglesDb::Swimmer).and be_valid }

  context 'with a valid GogglesDb::Swimmer parameter,' do
    subject { render_inline(described_class.new(swimmer: fixture_row)) }

    it 'renders the #link_to_full_name for the swimmer radiography page' do
      expect(subject.at('a')).to be_present
      decorated = SwimmerDecorator.decorate(fixture_row)
      expect(subject.at('a').text).to eq(decorated.text_label)
      expect(subject.at('a').attributes['href'].value).to eq(swimmer_show_path(id: fixture_row.id))
    end

    it 'renders the tooltip that explains the go-to-dashboard behavior of the link' do
      expect(subject.at('i.fa.fa-info-circle')).to be_present
      expect(subject.at('i.fa.fa-info-circle').attributes['title'].value).to eq(I18n.t('swimmers.go_to_dashboard'))
      expect(subject.at('i.fa.fa-info-circle').attributes['data'].value).to eq('tooltip')
      expect(subject.at('i.fa.fa-info-circle').attributes['onclick'].value).to eq("$(this).tooltip('toggle')")
    end
  end

  context 'with a valid GogglesDb::Swimmer parameter + custom action link options,' do
    subject { render_inline(described_class.new(swimmer: fixture_row, action_link_method: :link_to_results, link_extra_params: extra_params)) }

    let(:custom_action) { :link_to_results }
    let(:extra_params) { (rand * 10_000).to_i }
    let(:link_extra_params) { :link_to_results }

    it 'renders the #link_to_results for the meeting/swimmer_result page (which includes the meeting ID as extra params)' do
      expect(subject.at('a')).to be_present
      expect(subject.at('a').text).to eq(fixture_row.complete_name)
      expect(subject.at('a').attributes['href'].value).to eq(meeting_swimmer_results_path(id: extra_params, swimmer_id: fixture_row.id))
    end

    it 'renders the tooltip that explains the go-to-dashboard behavior of the link' do
      expect(subject.at('i.fa.fa-info-circle')).to be_present
      expect(subject.at('i.fa.fa-info-circle').attributes['title'].value).to eq(I18n.t('meetings.tooltip.link.swimmer_results'))
      expect(subject.at('i.fa.fa-info-circle').attributes['data'].value).to eq('tooltip')
      expect(subject.at('i.fa.fa-info-circle').attributes['onclick'].value).to eq("$(this).tooltip('toggle')")
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(swimmer: nil)).to_html }

    it_behaves_like('any subject that renders nothing')
  end
end
