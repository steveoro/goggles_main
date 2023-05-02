# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Title::TeamShowLinkComponent, type: :component do
  let(:fixture_row) { GogglesDb::Team.first(100).sample }

  before { expect(fixture_row).to be_a(GogglesDb::Team).and be_valid }

  context 'with a valid GogglesDb::Team parameter,' do
    subject { render_inline(described_class.new(team: fixture_row)) }

    it 'renders the #link_to_full_name for the team radiography page' do
      expect(subject.at('a')).to be_present
      decorated = TeamDecorator.decorate(fixture_row)
      expect(subject.at('a').text).to eq(decorated.text_label)
      expect(subject.to_html).to include(decorated.link_to_full_name)
    end

    it 'renders the tooltip that explains the go-to-dashboard behavior of the link' do
      expect(subject.at('i.fa.fa-info-circle')).to be_present
      expect(subject.at('i.fa.fa-info-circle').attributes['title'].value).to eq(I18n.t('teams.go_to_dashboard'))
      expect(subject.at('i.fa.fa-info-circle').attributes['data'].value).to eq('tooltip')
      expect(subject.at('i.fa.fa-info-circle').attributes['onclick'].value).to eq("$(this).tooltip('toggle')")
    end
  end

  context 'with a valid GogglesDb::Team parameter + custom action link options,' do
    subject { render_inline(described_class.new(team: fixture_row, action_link_method: :link_to_results, link_extra_params: extra_params)) }

    let(:custom_action) { :link_to_results }
    let(:extra_params) { (rand * 10_000).to_i }
    let(:link_extra_params) { :link_to_results }

    it 'renders the #link_to_results for the meeting/team_result page (which includes the meeting ID as extra params)' do
      expect(subject.at('a')).to be_present
      decorated = TeamDecorator.decorate(fixture_row)
      expect(subject.at('a').text).to eq(decorated.text_label)
      expect(subject.to_html).to include(decorated.send(custom_action, extra_params))
    end

    it 'renders the tooltip that explains the go-to-dashboard behavior of the link' do
      expect(subject.at('i.fa.fa-info-circle')).to be_present
      expect(subject.at('i.fa.fa-info-circle').attributes['title'].value).to eq(I18n.t('meetings.tooltip.link.team_results'))
      expect(subject.at('i.fa.fa-info-circle').attributes['data'].value).to eq('tooltip')
      expect(subject.at('i.fa.fa-info-circle').attributes['onclick'].value).to eq("$(this).tooltip('toggle')")
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(team: nil)).to_html }

    it_behaves_like('any subject that renders nothing')
  end
end
