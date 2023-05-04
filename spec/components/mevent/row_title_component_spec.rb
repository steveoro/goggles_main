# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mevent::RowTitleComponent, type: :component do
  shared_examples_for('Mevent::RowTitleComponent properly rendering the title row') do
    it 'shows the meeting event label' do
      expect(subject.css('h4')).to be_present
      expect(subject.css('h4').text).to include(fixture_row.event_type.long_label.to_s)
    end

    it 'renders a linkable table row' do
      expect(subject.at_css('tr')).to be_present
      expect(subject.at_css('tr')[:id]).to eq("mevent-#{fixture_row.id}")
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with a valid MeetingEvent parameter,' do
    subject { render_inline(described_class.new(event_container: fixture_row)) }

    let(:fixture_row) { GogglesDb::MeetingEvent.first(100).sample }

    before { expect(fixture_row).to be_a(GogglesDb::MeetingEvent).and be_valid }

    it_behaves_like('Mevent::RowTitleComponent properly rendering the title row')

    it 'does not render the \'report missing\' button (type-1b)' do
      expect(subject.at_css('a.btn.issue-type1b-btn')).not_to be_present
    end
  end

  context 'with a valid MeetingEvent parameter and a user that can manage reports,' do
    subject { render_inline(described_class.new(event_container: fixture_row, can_manage: true)) }

    let(:fixture_row) { GogglesDb::MeetingEvent.first(100).sample }

    before { expect(fixture_row).to be_a(GogglesDb::MeetingEvent).and be_valid }

    it_behaves_like('Mevent::RowTitleComponent properly rendering the title row')

    it 'renders the \'report missing\' button (type-1b)' do
      expect(subject.at_css('a.btn.issue-type1b-btn')).to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with a valid UserResult parameter,' do
    subject { render_inline(described_class.new(event_container: fixture_row)) }

    let(:fixture_row) { GogglesDb::UserResult.first(100).sample }

    before { expect(fixture_row).to be_a(GogglesDb::UserResult).and be_valid }

    it_behaves_like('Mevent::RowTitleComponent properly rendering the title row')

    it 'does not render the \'report missing\' button (type-1b)' do
      expect(subject.at_css('a.btn.issue-type1b-btn')).not_to be_present
    end
  end

  context 'with a valid UserResult parameter and a user that can manage reports,' do
    subject { render_inline(described_class.new(event_container: fixture_row, can_manage: true)) }

    let(:fixture_row) { GogglesDb::UserResult.first(100).sample }

    before { expect(fixture_row).to be_a(GogglesDb::UserResult).and be_valid }

    it_behaves_like('Mevent::RowTitleComponent properly rendering the title row')

    it 'renders the \'report missing\' button (type-1b)' do
      expect(subject.at_css('a.btn.issue-type1b-btn')).to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with an invalid parameter,' do
    subject { render_inline(described_class.new(event_container: nil)).to_html }

    it_behaves_like('any subject that renders nothing')
  end
end
