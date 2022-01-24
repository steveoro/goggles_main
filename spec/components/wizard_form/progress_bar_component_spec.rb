# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WizardForm::ProgressBarComponent, type: :component do
  # REQUIRES/ASSUMES;
  # - subject: the rendered component
  shared_examples_for('ProgressBarComponent minimal default rendering') do
    it 'renders the progress bar container' do
      expect(subject.css('.progressbar .progress#progress')).to be_present
    end

    it 'includes the WizardFormController target setup' do
      expect(subject.css('.progressbar .progress#progress').attr('data-wizard-form-target')).to be_present
      expect(subject.css('.progressbar .progress#progress').attr('data-wizard-form-target').value).to eq('progress')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'without any parameters (default),' do
    subject { render_inline(described_class.new) }

    it_behaves_like('ProgressBarComponent minimal default rendering')

    it 'renders 3 progress steps' do
      expect(subject.css('.progressbar .progress-step').count).to eq(3)
    end

    it 'renders each progress step title & icon as data attribute of its own step' do
      %w[1 2 3].each_with_index do |title, _idx|
        expect(subject.css(".progressbar .progress-step[data-title='#{title}']")).to be_present
        expect(subject.css(".progressbar .progress-step[data-title='#{title}']").attr('data-icon')).to be_present
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with an invalid list of titles,' do
    subject { render_inline(described_class.new(titles: [])).to_html }

    it_behaves_like('any subject that renders nothing')
  end

  context 'with an invalid list of icons,' do
    subject { render_inline(described_class.new(icons: [])).to_html }

    it_behaves_like('any subject that renders nothing')
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when specifying the values for the labels and icons,' do
    subject do
      expect(fixture_titles).to be_an(Array)
      expect(fixture_titles.length).to be_positive
      expect(fixture_icons).to be_an(Array)
      expect(fixture_icons.length).to be_positive

      render_inline(described_class.new(titles: fixture_titles, icons: fixture_icons))
    end

    let(:steps_tot) { [3, 4, 5, 6].sample }
    let(:fixture_titles) { steps_tot.times.map { FFaker::Lorem.word } }
    let(:fixture_icons) { steps_tot.times.map { |i| (i + 1).to_s } }

    it_behaves_like('ProgressBarComponent minimal default rendering')

    it 'renders as many progress steps as the specified titles (or icons)' do
      expect(subject.css('.progressbar .progress-step').count).to eq(steps_tot)
    end

    it 'renders each progress step title & icon as data attribute of its own step' do
      fixture_titles.each_with_index do |title, idx|
        expect(subject.css(".progressbar .progress-step[data-title='#{title}']")).to be_present
        expect(subject.css(".progressbar .progress-step[data-title='#{title}']").attr('data-icon')).to be_present
        expect(
          subject.css(".progressbar .progress-step[data-title='#{title}']").attr('data-icon').value
        ).to eq(fixture_icons[idx])
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
