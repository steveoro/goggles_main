# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'swimmers/history.html.haml', type: :view do
  # Test basic/required content:
  context 'when rendering with data,' do
    subject { Nokogiri::HTML.fragment(rendered) }

    let(:fixture_row) { GogglesDb::Swimmer.first(150).sample }

    let(:event_type) do
      events = GogglesDb::EventType.all_eventable.map do |event_type|
        count = GogglesDb::MeetingIndividualResult.includes(:event_type)
                                                  .where(swimmer_id: fixture_row.id, 'event_types.id': event_type.id)
                                                  .count
        next if count.zero?

        event_type
      end
      events.compact.sample
    end

    let(:fixture_params) { { id: fixture_row.id, event_type_id: event_type.id } }

    let(:grid) do
      HistoryGrid.new({}) do |scope|
        scope.where(
          swimmer_id: fixture_row.id,
          event_types: { id: event_type.id }
        )
      end
    end

    let(:data_hash) do
      grid.assets.map do |mir|
        {
          x: mir.meeting.header_date, y: mir.to_timing, pool_type_id: mir.pool_type.id
        }
      end
    end

    let(:chart_data25) do
      result = data_hash.select { |hsh| hsh[:pool_type_id] == GogglesDb::PoolType::MT_25_ID }
                        .map do |hsh|
        {
          x: hsh[:x].strftime('%Y%m%d').to_i, xLabel: hsh[:x].to_s,
          y: hsh[:y].to_hundredths, yLabel: hsh[:y].to_s,
          poolTypeId: hsh[:pool_type_id]
        }
      end
      result.sort_by! { |hsh| hsh[:x] }
      result
    end

    let(:chart_data50) do
      result = data_hash.select { |hsh| hsh[:pool_type_id] == GogglesDb::PoolType::MT_50_ID }
                        .map do |hsh|
        {
          x: hsh[:x].strftime('%Y%m%d').to_i, xLabel: hsh[:x].to_s,
          y: hsh[:y].to_hundredths, yLabel: hsh[:y].to_s,
          poolTypeId: hsh[:pool_type_id]
        }
      end
      result.sort_by! { |hsh| hsh[:x] }
      result
    end

    before do
      expect(fixture_row).to be_a(GogglesDb::Swimmer).and be_valid
      expect(event_type).to be_a(GogglesDb::EventType).and be_valid
      expect(fixture_params).to be_an(Hash).and be_present
      expect(grid).to be_a(HistoryGrid).and be_present
      expect(data_hash).to be_a(Array).and all(be_a(Hash))
      expect(chart_data25).to be_a(Array).and all(be_a(Hash))
      expect(chart_data50).to be_a(Array).and all(be_a(Hash))

      assign(:swimmer, fixture_row)
      assign(:event_type, event_type)
      assign(:grid_filter_params, {})
      assign(:grid, grid)
      assign(:chart_data25, chart_data25)
      assign(:chart_data50, chart_data50)
      controller.request.path_parameters.merge!(fixture_params)

      render
    end

    it 'shows the history details section title with a link to go back to the swimmer radiography (a.k.a. \'swimmer dashboard\')' do
      node = subject.at_css('section#swimmer-history-title')
      expect(node).to be_present
      expect(node.at_css('h4 a#back-to-parent')).to be_present
      expect(node.at_css('h4 a#back-to-parent').attributes['href'].value).to eq(swimmer_show_path(fixture_row))
    end

    it 'includes the swimmer complete name inside the detail section' do
      node = subject.at_css('section#swimmer-history-detail #swimmer-name')
      expect(node).to be_present
      expect(node.text).to eq(fixture_row.complete_name)
    end

    it 'includes the event type name inside the detail section' do
      node = subject.at_css('section#swimmer-history-detail #event-name')
      expect(node).to be_present
      expect(node.text).to eq(event_type.long_label)
    end

    it 'renders the detailed line graph' do
      container = subject.at_css('section#swimmer-history-detail #swimmer-detail-chart')
      expect(container).to be_present
      expect(container.attributes['data-controller'].value).to eq('chart')
      expect(container.attributes['data-chart-type-value'].value).to eq('line')
      canvas = container.at_css('canvas#detail-chart')
      expect(canvas.attributes['data-chart-target'].value).to eq('chart')
    end

    it 'renders the events detail datagrid section' do
      node = subject.at_css('section#swimmer-history-detail #data-grid')
      expect(node).to be_present
    end

    it 'renders the datagrid filter form' do
      node = subject.at_css('section#swimmer-history-detail #data-grid #filter-panel form')
      expect(node).to be_present
    end

    it 'renders datagrid control row with the filter toggle button, the active filter labels and the datagrid total' do
      node = subject.at_css('section#swimmer-history-detail #data-grid #datagrid-ctrls')
      expect(node).to be_present
      expect(node.at_css('#filter-show-btn')).to be_present
      expect(node.at_css('#filter-labels')).to be_present
      expect(node.at_css('#datagrid-total')).to be_present
    end

    it 'renders the datagrid table' do
      node = subject.at_css('section#swimmer-history-detail #data-grid table')
      expect(node).to be_present
    end
  end
end
