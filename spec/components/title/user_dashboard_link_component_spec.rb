# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Title::UserDashboardLinkComponent, type: :component do
  context 'with a valid user having an associated swimmer,' do
    subject { render_inline(described_class.new(user: fixture_row)) }

    let(:fixture_row) { GogglesDb::User.includes(:swimmer).joins(:swimmer).first(100).sample }

    before do
      expect(fixture_row).to be_a(GogglesDb::User).and be_valid
      expect(fixture_row.swimmer).to be_a(GogglesDb::Swimmer).and be_valid
    end

    it 'renders the link to current user\'s dashboard page using the display label of the swimmer' do
      expect(subject.at('a')).to be_present
      expect(subject.at('a').text).to eq(fixture_row.swimmer.decorate.display_label)
      expect(subject.at('a').attributes['href'].value).to include('home/dashboard')
    end

    it 'renders the tooltip that explains the go-to-dashboard behavior of the link' do
      expect(subject.at('i.fa.fa-info-circle')).to be_present
      expect(subject.at('i.fa.fa-info-circle').attributes['title'].value).to eq(I18n.t('home.my.go_to_dashboard_tooltip'))
      expect(subject.at('i.fa.fa-info-circle').attributes['data'].value).to eq('tooltip')
      expect(subject.at('i.fa.fa-info-circle').attributes['onclick'].value).to eq("$(this).tooltip('toggle')")
    end
  end

  context 'with a valid user BUT without an associated swimmer,' do
    subject { render_inline(described_class.new(user: fixture_row)) }

    let(:fixture_row) { FactoryBot.create(:user) }

    before do
      expect(fixture_row).to be_a(GogglesDb::User).and be_valid
      expect(fixture_row.swimmer).to be nil
    end

    it 'renders the link to current user\'s dashboard page using the description of the user' do
      expect(subject.at('a')).to be_present
      expect(subject.at('a').text).to eq(fixture_row.description)
      expect(subject.at('a').attributes['href'].value).to include('home/dashboard')
    end

    it 'renders the tooltip that explains the go-to-dashboard behavior of the link' do
      expect(subject.at('i.fa.fa-info-circle')).to be_present
      expect(subject.at('i.fa.fa-info-circle').attributes['title'].value).to eq(I18n.t('home.my.go_to_dashboard_tooltip'))
      expect(subject.at('i.fa.fa-info-circle').attributes['data'].value).to eq('tooltip')
      expect(subject.at('i.fa.fa-info-circle').attributes['onclick'].value).to eq("$(this).tooltip('toggle')")
    end
  end

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(user: nil)).to_html }

    it_behaves_like('any subject that renders nothing')
  end
end
