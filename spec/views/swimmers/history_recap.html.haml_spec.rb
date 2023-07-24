# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'swimmers/history_recap.html.haml' do
  # Test basic/required content:
  context 'when rendering with data,' do
    subject { Nokogiri::HTML.fragment(rendered) }

    let(:fixture_row) { GogglesDb::Swimmer.first(150).sample }
    let(:event_type_list) do
      events = GogglesDb::EventType.all_eventable.map do |event_type|
        count = GogglesDb::MeetingIndividualResult.includes(:event_type)
                                                  .where(swimmer_id: fixture_row.id, 'event_types.id': event_type.id)
                                                  .count
        next if count.zero?

        count25 = GogglesDb::MeetingIndividualResult.includes(:event_type, :pool_type)
                                                    .where(
                                                      swimmer_id: fixture_row.id,
                                                      'event_types.id': event_type.id,
                                                      'pool_types.id': GogglesDb::PoolType::MT_25_ID
                                                    ).count
        {
          id: event_type.id,
          label: event_type.long_label, # I18n
          count25:,
          count50: count - count25,
          count:
        }
      end
      events.compact!
      events
    end
    let(:event_total) { event_type_list.sum { |e| e[:count] } }

    let(:chart_data25) do
      event_type_list.map do |hsh|
        percent = (hsh[:count25] * 100 / event_total).round(2)
        {
          key: hsh[:label],
          value: [percent, 1.0].max,
          count: hsh[:count25],
          typeLabel: GogglesDb::PoolType.mt_25.label
        }
      end
    end
    let(:chart_data50) do
      event_type_list.map do |hsh|
        percent = (hsh[:count50] * 100 / event_total).round(2)
        {
          key: hsh[:label],
          value: [percent, 1.0].max,
          count: hsh[:count50],
          typeLabel: GogglesDb::PoolType.mt_50.label
        }
      end
    end

    before do
      expect(fixture_row).to be_a(GogglesDb::Swimmer).and be_valid
      expect(event_type_list).to be_a(Array).and all(be_a(Hash))
      expect(chart_data25).to be_a(Array).and all(be_a(Hash))
      expect(chart_data50).to be_a(Array).and all(be_a(Hash))
      expect(event_total).to be_positive

      assign(:swimmer, fixture_row)
      assign(:event_type_list, event_type_list)
      assign(:event_total, event_total)
      assign(:chart_data25, chart_data25)
      assign(:event25_total, chart_data25.sum { |e| e[:count] })
      assign(:chart_data50, chart_data50)
      assign(:event50_total, chart_data50.sum { |e| e[:count] })
      render
    end

    it 'shows the history recap section title with a link to go back to the swimmer radiography (a.k.a. \'swimmer dashboard\')' do
      node = subject.at_css('section#swimmer-history-recap-title')
      expect(node).to be_present
      expect(node.at_css('h4 a#back-to-parent')).to be_present
      expect(node.at_css('h4 a#back-to-parent').attributes['href'].value).to eq(swimmer_show_path(fixture_row))
    end

    it 'includes the swimmer complete name inside the history recap section' do
      node = subject.at_css('section#swimmer-history-recap #swimmer-name')
      expect(node).to be_present
      expect(node.text).to eq(fixture_row.complete_name)
    end

    it 'renders the recap chart' do
      container = subject.at_css('section#swimmer-history-recap #swimmer-recap-chart')
      expect(container).to be_present
      expect(container.attributes['data-controller'].value).to eq('chart')
      canvas = container.at_css('canvas#recap-chart')
      expect(canvas.attributes['data-chart-target'].value).to eq('chart')
    end

    it 'renders the recap table' do
      table = subject.at_css('section#swimmer-history-recap table')
      expect(table).to be_present
    end

    it 'renders a table row for each event type list entry' do
      table_rows = subject.css('section#swimmer-history-recap table tbody tr.event-types')
      expect(table_rows).to be_present
      expect(table_rows.count).to eq(event_type_list.count)
    end

    context 'for each rendered table row,' do
      let(:table_rows) { subject.css('section#swimmer-history-recap table tbody tr.event-types') }

      it 'shows a link to go to the history details for that event type' do
        table_rows.css('td.history-link').each_with_index do |node, idx|
          expect(node).to be_present
          expect(node.at_css('a')).to be_present
          expect(node.at_css('a').text).to include(event_type_list[idx][:label])
          expect(node.at_css('a').attributes['href'].value).to eq(
            swimmer_history_path(fixture_row, event_type_list[idx][:id])
          )
        end
      end

      it 'shows that event type count for 25 mt pools' do
        table_rows.css('td.count-25').each_with_index do |node, idx|
          expect(node).to be_present
          expect(node.text.strip).to include(event_type_list[idx][:count25].to_s)
        end
      end

      it 'shows that event type count for 50 mt pools' do
        table_rows.css('td.count-50').each_with_index do |node, idx|
          expect(node).to be_present
          expect(node.text.strip).to include(event_type_list[idx][:count50].to_s)
        end
      end

      it 'shows that event type overall count' do
        table_rows.css('td.count').each_with_index do |node, idx|
          expect(node).to be_present
          expect(node.text.strip).to include(event_type_list[idx][:count].to_s)
        end
      end

      it 'shows that event type overall percentage with 2 digits precision' do
        table_rows.css('td.percentage').each_with_index do |node, idx|
          expect(node).to be_present
          expect(node.text.strip).to include(
            format('%0.2f', event_type_list[idx][:count].to_f / event_total * 100.0)
          )
        end
      end
    end

    it 'renders a table row for the overall totals' do
      tot_row = subject.css('section#swimmer-history-recap table tbody tr#overall-totals')
      expect(tot_row).to be_present
      expect(tot_row.at_css('td.grand-total').text.strip).to include(event_total.to_s)
    end
  end
end
