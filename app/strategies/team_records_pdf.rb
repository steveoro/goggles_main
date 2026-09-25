# frozen_string_literal: true

require 'prawn'
require 'prawn/table'
Prawn::Fonts::AFM.hide_m17n_warning = true

# = TeamRecordsPdf
#
# Renders the "team records" matrix as a landscape PDF, one chapter per
# pool-type x gender-type combination (4 chapters).
#
# Tables are rendered with events as rows and categories as columns; when a
# grid has too many categories to fit the page width, the axes are swapped
# (categories as rows, events as columns) so the table never splits
# horizontally — vertical splits across pages are allowed.
#
class TeamRecordsPdf
  MIME_TYPE = 'application/pdf'

  # Maximum number of category columns before the grid is rendered transposed.
  MAX_CATEGORY_COLUMNS = 14

  # Repeated page chrome: the app favicon image (PNG equivalent of favicon.ico),
  # the deployment host for the right-aligned header URL and the label
  # for the left-aligned footer text.
  LOGO_PATH = Rails.root.join('app/assets/images/radiography.png')
  SERVER_URL = "https://#{ApplicationMailer::HOSTNAME}".freeze
  PAGE_HEADER_HEIGHT = 16
  PAGE_FOOTER_Y = -22

  POOL_GENDER_PAIRS = [
    [GogglesDb::PoolType::MT_25_ID, GogglesDb::GenderType::FEMALE_ID, 'pool_25', 'female'],
    [GogglesDb::PoolType::MT_25_ID, GogglesDb::GenderType::MALE_ID,   'pool_25', 'male'],
    [GogglesDb::PoolType::MT_50_ID, GogglesDb::GenderType::FEMALE_ID, 'pool_50', 'female'],
    [GogglesDb::PoolType::MT_50_ID, GogglesDb::GenderType::MALE_ID,   'pool_50', 'male']
  ].freeze

  def initialize(team:, records:, season_year: nil)
    @team = team
    @records = records || []
    @season_year = season_year
  end

  def render
    Prawn::Document.new(page_layout: :landscape, margin: [50, 25, 42, 25]) do |pdf|
      pdf.font_size 9
      render_page_header(pdf)
      render_header(pdf)
      POOL_GENDER_PAIRS.each_with_index do |(pool_id, gender_id, pool_label, gender_label), index|
        render_chapter(pdf, pool_id, gender_id, "#{I18n.t("teams.records.#{pool_label}")}, " \
                                                "#{I18n.t("teams.records.#{gender_label}")}", index)
      end
      render_page_footer(pdf)
    end.render
  end

  def filename
    season_part = @season_year ? "-#{@season_year}" : ''
    "team-records-#{(@team&.editable_name || @team&.name).to_s.parameterize}#{season_part}.pdf"
  end

  def mime_type
    MIME_TYPE
  end

  private

  # Repeated on every page: Goggles logo + label in the top margin (left),
  # and the grey-ish server URL right-aligned in the same margin.
  def render_page_header(pdf)
    pdf.repeat(:all) do
      pdf.bounding_box([pdf.bounds.left, pdf.bounds.top + PAGE_HEADER_HEIGHT + 8],
                       width: pdf.bounds.width, height: PAGE_HEADER_HEIGHT) do
        pdf.image(LOGO_PATH, at: [0, PAGE_HEADER_HEIGHT], height: 14)
        pdf.draw_text('Goggles', at: [20, 4], size: 9, style: :bold)
        pdf.text_box(SERVER_URL, at: [pdf.bounds.width - 180, PAGE_HEADER_HEIGHT],
                                 width: 180, height: PAGE_HEADER_HEIGHT,
                                 align: :right, size: 7, color: '888888')
      end
    end
  end

  # Footer: 'Generated on <timestamp>' left-aligned and 'page/total' right-aligned,
  # stamped on every page in the bottom margin.
  def render_page_footer(pdf)
    generated_at = Time.current.strftime('%Y-%m-%d %H:%M')
    pdf.number_pages("#{I18n.t('teams.records.generated_on')} #{generated_at}",
                     at: [pdf.bounds.left, PAGE_FOOTER_Y],
                     align: :left, size: 7, color: '888888')
    pdf.number_pages('<page> / <total>', at: [pdf.bounds.right - 60, PAGE_FOOTER_Y],
                                         align: :right, size: 7, color: '888888')
  end

  def render_header(pdf)
    pdf.text(I18n.t('teams.records.title'), size: 16, style: :bold, align: :center)
    pdf.move_down 4
    pdf.text(@team.editable_name || @team.name.to_s, size: 12, align: :center)
    return unless @season_year

    pdf.move_down 2
    pdf.text("#{I18n.t('teams.records.select_year')}: #{@season_year}/#{@season_year + 1}",
             size: 11, style: :bold, align: :center)
  end

  def render_chapter(pdf, pool_id, gender_id, chapter_title, index)
    pdf.move_down 12 if index.zero?
    pdf.start_new_page if index.positive?
    pdf.text(chapter_title, size: 13, style: :bold)
    pdf.move_down 6

    grid_rows = @records.select { |r| r.pool_type_id == pool_id && r.gender_type_id == gender_id }
    if grid_rows.empty?
      pdf.text(I18n.t('teams.records.no_records'), style: :italic)
      return
    end
    pdf.table(table_data_for(grid_rows), header: true, row_colors: %w[F0F0F0 FFFFFF],
                                         width: pdf.bounds.width,
                                         cell_style: { size: cell_size_for(grid_rows), padding: [2, 3] }) do |table|
      table.row(0).font_style = :bold
      table.column(0).align = :left
    end
  end

  # Supported individual event types, in display order.
  def supported_events
    @supported_events ||= GogglesDb::EventType
                          .where(id: GogglesDb::BestTeamResultsForSeason::SUPPORTED_EVENT_TYPE_IDS)
                          .order(:style_order)
  end

  # Distinct category codes used in the grid, sorted by minimum age_begin then code.
  def category_codes_for(grid_rows)
    grid_rows.group_by { |r| r.category_type.code }
             .sort_by { |code, rows| [rows.map { |r| r.category_type.age_begin || 999 }.min, code] }
             .map(&:first)
  end

  # Best row per (row axis x column axis) cell.
  def cells_for(grid_rows)
    grid_rows.group_by { |r| [r.event_type_id, r.category_type.code] }
             .transform_values { |rows| rows.min_by(&:total_hundredths) }
  end

  def cell_text(record)
    record ? "#{record.to_timing}\n#{record.swimmer_name}" : ''
  end

  def cell_size_for(grid_rows)
    category_codes_for(grid_rows).length > 10 ? 6 : 8
  end

  def table_data_for(grid_rows)
    category_codes = category_codes_for(grid_rows)
    cells = cells_for(grid_rows)

    # Swap the axes when too many categories: the table can then grow
    # vertically (allowed) instead of exceeding the page width.
    if category_codes.length > MAX_CATEGORY_COLUMNS
      return [transposed_header] + category_codes.map do |code|
        [code] + supported_events.map { |event_type| cell_text(cells[[event_type.id, code]]) }
      end
    end

    [[I18n.t('teams.records.event')] + category_codes] + supported_events.map do |event_type|
      [event_type.long_label] + category_codes.map { |code| cell_text(cells[[event_type.id, code]]) }
    end
  end

  def transposed_header
    [I18n.t('teams.records.category')] + supported_events.map(&:label)
  end
end
