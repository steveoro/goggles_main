# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Laps::EditModalComponent, type: :component do
  include Rails.application.routes.url_helpers

  # Select an abstract lap for the parent result, so that we're sure we have existing
  # lap rows (although not required, makes the test more complete)
  let(:parent_result) do
    lap = [
      GogglesDb::Lap.last(500).sample,
      GogglesDb::UserLap.last(500).sample
    ].sample
    lap.parent_result
  end

  before do
    expect(parent_result).to be_an(GogglesDb::AbstractResult).and be_valid
    expect(parent_result.laps.count).to be_positive
  end

  context 'when specifying a valid parent result' do
    subject { render_inline(described_class.new(parent_result: parent_result)) }

    let(:rendered_modal) { subject.at_css('#lap-edit-modal.modal.fade') }

    it 'renders the modal container as initially hidden' do
      expect(rendered_modal).to be_present
    end

    it 'includes the modal title with the event & gender labels' do
      title_container = rendered_modal.at('h5#lap-edit-modal-title.modal-title')
      expect(title_container).to be_present
      expect(title_container.text).to include(I18n.t('laps.modal.form.title'))
      expect(title_container.text).to include(parent_result.event_type.label)
      expect(title_container.text).to include(parent_result.gender_type.label)
    end

    it 'includes the alert msg container' do
      expect(rendered_modal.at('small#lap-modal-alert-text')).to be_present
    end

    it 'renders the modal header row' do
      expect(rendered_modal.at('tr#lap-table-header')).to be_present
    end

    describe 'within the modal header row,' do
      let(:header_row) { rendered_modal.at('tr#lap-table-header') }

      it 'renders the swimmer complete name' do
        expect(header_row.at('h6').text).to include(parent_result.swimmer.complete_name)
      end

      it 'renders the link to add a new row with a step distance of 25 meters (including default values for show_team & show_category)' do
        rendered_button = header_row.at("a#lap-new25-#{parent_result.id}")
        expect(rendered_button).to be_present
        target_href = laps_path(
          result_id: parent_result.id, result_class: parent_result.class.name.split('::').last,
          show_category: false, show_team: true, step: 25
        )
        expect(rendered_button['href']).to include(target_href.to_s)
      end

      it 'renders the link to add a new row with a step distance of 50 meters (including default values for show_team & show_category)' do
        rendered_button = header_row.at("a#lap-new50-#{parent_result.id}")
        expect(rendered_button).to be_present
        target_href = laps_path(
          result_id: parent_result.id, result_class: parent_result.class.name.split('::').last,
          show_category: false, show_team: true, step: 50
        )
        expect(rendered_button['href']).to include(target_href.to_s)
      end
    end

    it 'renders the body of the table' do
      expect(rendered_modal.at('tbody#laps-table-body')).to be_present
    end

    describe 'within the modal table body,' do
      let(:table_body) { rendered_modal.at('tbody#laps-table-body') }

      it 'renders a lap edit form (with its required hidden fields) for each lap associated to the result' do
        parent_result.laps.each_with_index do |_lap, index|
          form_table = table_body.at("form#frm-lap-row-#{index + 1}")
          expect(form_table).to be_present
          # The form must map to a proper parent result for the edited lap:
          expect(form_table.at("input#result_id_#{index}")).to be_present
          expect(form_table.at("input#result_id_#{index}").attr('value')).to eq(parent_result.id.to_s)
          expect(form_table.at("input#result_class_#{index}")).to be_present
          expect(form_table.at("input#result_class_#{index}").attr('value')).to eq(parent_result.class.name.split('::').last)
        end
      end

      it 'allows editing the lap length (in meters) of each lap' do
        parent_result.laps.each_with_index do |lap, index|
          form_table = table_body.at("form#frm-lap-row-#{index + 1}")
          expect(form_table.at("input#length_in_meters_#{index}")).to be_present
          expect(form_table.at("input#length_in_meters_#{index}").attr('value')).to eq(lap.length_in_meters.to_s)
        end
      end

      it 'allows editing the timing minutes (from the start) of each lap' do
        parent_result.laps.each_with_index do |lap, index|
          form_table = table_body.at("form#frm-lap-row-#{index + 1}")
          expect(form_table.at("input#minutes_from_start_#{index}")).to be_present
          expect(form_table.at("input#minutes_from_start_#{index}").attr('value')).to eq(lap.minutes_from_start.to_s)
        end
      end

      it 'allows editing the timing seconds (from the start) of each lap' do
        parent_result.laps.each_with_index do |lap, index|
          form_table = table_body.at("form#frm-lap-row-#{index + 1}")
          expect(form_table.at("input#seconds_from_start_#{index}")).to be_present
          expect(form_table.at("input#seconds_from_start_#{index}").attr('value')).to eq(lap.seconds_from_start.to_s)
        end
      end

      it 'allows editing the hundredths timing (from the start) of each lap' do
        parent_result.laps.each_with_index do |lap, index|
          form_table = table_body.at("form#frm-lap-row-#{index + 1}")
          expect(form_table.at("input#hundredths_from_start_#{index}")).to be_present
          expect(form_table.at("input#hundredths_from_start_#{index}").attr('value')).to eq(lap.hundredths_from_start.to_s)
        end
      end

      it 'renders dedicated save & delete buttons (if the lap is serialized) for each lap' do
        parent_result.laps.each_with_index do |lap, index|
          form_table = table_body.at("form#frm-lap-row-#{index + 1}")
          expect(form_table.at("#lap-save-row-#{index}")).to be_present
          expect(form_table.at("#lap-delete-row-#{index}")).to be_present if lap.id.to_i.positive?
        end
      end

      describe 'renders a closing table row that' do
        let(:final_row) { table_body.at('tr#laps-result-row') }

        before { expect(final_row).to be_present }

        it 'shows the total length in meters (read-only)' do
          expect(final_row.at('input#tot_length')).to be_present
          expect(final_row.at('input#tot_length').attr('value')).to eq(parent_result.event_type.length_in_meters.to_s)
          expect(final_row.at('input#tot_length').attr('disabled')).to eq('disabled')
        end

        it 'shows the total minutes for the parent result (read-only)' do
          expect(final_row.at('input#tot_minutes')).to be_present
          expect(final_row.at('input#tot_minutes').attr('value')).to eq(parent_result.minutes.to_s)
          expect(final_row.at('input#tot_minutes').attr('disabled')).to eq('disabled')
        end

        it 'shows the total seconds for the parent result (read-only)' do
          expect(final_row.at('input#tot_seconds')).to be_present
          expect(final_row.at('input#tot_seconds').attr('value')).to eq(parent_result.seconds.to_s)
          expect(final_row.at('input#tot_seconds').attr('disabled')).to eq('disabled')
        end

        it 'shows the total hundredths for the parent result (read-only)' do
          expect(final_row.at('input#tot_hundredths')).to be_present
          expect(final_row.at('input#tot_hundredths').attr('value')).to eq(parent_result.hundredths.to_s)
          expect(final_row.at('input#tot_hundredths').attr('disabled')).to eq('disabled')
        end

        it 'has a span where the final delta timing can be rendered once available' do
          expect(final_row.at('td span#result-row-delta')).to be_present
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when specifying an invalid parent result,' do
    subject do
      render_inline(
        described_class.new(parent_result: ['not-a-parent-result', nil, GogglesDb::User.first(10).sample].sample)
      ).to_html
    end

    it_behaves_like('any subject that renders nothing')
  end
  #-- -------------------------------------------------------------------------
  #++
end
