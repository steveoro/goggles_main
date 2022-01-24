# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WizardForm::ChronoSummaryComponent, type: :component do
  # REQUIRES/ASSUMES;
  # - subject: the rendered component
  shared_examples_for('ChronoSummaryComponent minimal default rendering') do
    it 'renders the chrono-summary container' do
      expect(subject.css('#chrono-summary')).to be_present
    end

    it 'renders the summary label for the selected swimmer and sets its controller configuration' do
      node = subject.css("#chrono-summary dt label[for='summary_swimmer']")
      expect(node).to be_present
      expect(node.attr('data-chrono-new-summary-target')).to be_present
      expect(node.attr('data-chrono-new-summary-target').value).to eq('swimmer')
    end

    it 'renders the summary label for the selected event and sets its controller configuration' do
      node = subject.css("#chrono-summary dt label[for='summary_event']")
      expect(node).to be_present
      expect(node.attr('data-chrono-new-summary-target')).to be_present
      expect(node.attr('data-chrono-new-summary-target').value).to eq('event')
    end

    it 'renders the summary label for the selected meeting or workshop and sets its controller configuration' do
      node = subject.css("#chrono-summary dt label[for='summary_title']")
      expect(node).to be_present
      expect(node.attr('data-chrono-new-summary-target')).to be_present
      expect(node.attr('data-chrono-new-summary-target').value).to eq('title')
    end

    it 'renders the summary label for the selected pool and sets its controller configuration' do
      node = subject.css("#chrono-summary dd label[for='summary_pool']")
      expect(node).to be_present
      expect(node.attr('data-chrono-new-summary-target')).to be_present
      expect(node.attr('data-chrono-new-summary-target').value).to eq('pool')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'without any parameters (default),' do
    subject { render_inline(described_class.new) }

    it 'renders the "required fields ready" notice' do
      expect(subject.css('#required-ready')).to be_present
    end

    it 'renders the "required fields missing" notice' do
      expect(subject.css('#required-missing')).to be_present
    end

    it_behaves_like('ChronoSummaryComponent minimal default rendering')
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when skipping the validation notice section,' do
    subject { render_inline(described_class.new(skip_notice: true)) }

    it 'does not render the "required fields ready" notice' do
      expect(subject.css('#required-ready')).not_to be_present
    end

    it 'does not render the "required fields missing" notice' do
      expect(subject.css('#required-missing')).not_to be_present
    end

    it_behaves_like('ChronoSummaryComponent minimal default rendering')
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when specifying the default values for the labels,' do
    subject do
      render_inline(
        described_class.new(
          swimmer: fixture_swimmer_label,
          event: fixture_event_label,
          title: fixture_title_label,
          pool: fixture_pool_label
        )
      )
    end

    let(:fixture_swimmer_label) { FFaker::Name.name }
    let(:fixture_event_label) { "#{Time.zone.today} - #{FFaker::Lorem.words(2).join(' ')}" }
    let(:fixture_title_label) { "#{FFaker::BaconIpsum.words(3).join(' ').titleize} Meeting" }
    let(:fixture_pool_label) { "#{FFaker::Address.city} pool" }

    it 'renders the "required fields ready" notice' do
      expect(subject.css('#required-ready')).to be_present
    end

    it 'renders the "required fields missing" notice' do
      expect(subject.css('#required-missing')).to be_present
    end

    it_behaves_like('ChronoSummaryComponent minimal default rendering')

    it 'renders the selected swimmer label value' do
      node = subject.css("#chrono-summary dt label[for='summary_swimmer']")
      expect(node.text).to eq(fixture_swimmer_label)
    end

    it 'renders the selected event label value' do
      node = subject.css("#chrono-summary dt label[for='summary_event']")
      expect(node.text).to eq(fixture_event_label)
    end

    it 'renders the selected title label value' do
      node = subject.css("#chrono-summary dt label[for='summary_title']")
      expect(node.text).to eq(fixture_title_label)
    end

    it 'renders the selected pool label value' do
      node = subject.css("#chrono-summary dd label[for='summary_pool']")
      expect(node.text).to eq(fixture_pool_label)
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
