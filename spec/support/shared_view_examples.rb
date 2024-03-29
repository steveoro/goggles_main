# frozen_string_literal: true

# REQUIRES/ASSUMES:
# - parsed_node...: the Nokogiri::HTML::DocumentFragment object from the rendered view
shared_examples_for('common datagrid partial with pagination') do
  it 'includes the pagination at the top' do
    expect(parsed_node.at_css('section#data-grid .row#datagrid-top-row #pagination-top')).to be_present
  end

  it 'includes the datagrid total in the top row' do
    expect(parsed_node.at_css('section#data-grid .row#datagrid-top-row #datagrid-total')).to be_present
  end

  it 'includes the datagrid table' do
    expect(parsed_node.at_css('section#data-grid table')).to be_present
  end

  it 'includes the pagination at the bottom' do
    expect(parsed_node.at_css('section#data-grid #pagination-bottom')).to be_present
  end
end

# REQUIRES/ASSUMES:
# - parsed_node...: the Nokogiri::HTML::DocumentFragment object from the rendered view
shared_examples_for 'MeetingGrid or UserWorkshopGrid datagrid partial with filtering and pagination' do
  it_behaves_like('common datagrid partial with pagination')

  it 'includes the datagrid section with the filtering form' do
    expect(parsed_node.at_css('section#data-grid form')).to be_present
  end

  it 'includes the datagrid filtering show button in the top row' do
    expect(parsed_node.at_css('section#data-grid .row#datagrid-top-row #filter-show-btn button')).to be_present
  end
end
#-- ---------------------------------------------------------------------------
#++

# REQUIRES/ASSUMES:
# - parsed_node...: the Nokogiri::HTML::DocumentFragment object from the rendered view
shared_examples_for 'AbstractMeeting rendered /index view' do
  it 'includes the link to go back to the dashboard' do
    expect(parsed_node.at_css('a#back-to-parent')).to be_present
    expect(parsed_node.at_css('a#back-to-parent').attributes['href'].value).to eq(home_dashboard_path)
  end

  it_behaves_like('MeetingGrid or UserWorkshopGrid datagrid partial with filtering and pagination')
end
#-- ---------------------------------------------------------------------------
#++

# REQUIRES/ASSUMES:
# - parsed_node....: the Nokogiri::HTML::DocumentFragment object from the rendered view
# - current_user...: the current_user instance variable
shared_examples_for '/home/dashboard rendered view' do
  it 'includes the dashboard buttons section' do
    expect(parsed_node.at_css('section#dashboard-btns')).to be_present
  end

  it "includes the 'my past meetings' link" do
    expect(parsed_node.at_css('#dashboard-btns a#btn-my-past-meetings')).to be_present
    expect(parsed_node.at_css('#dashboard-btns a#btn-my-past-meetings').attributes['href'].value).to eq(meetings_path)
  end

  it "includes the 'my future meetings' link" do
    expect(parsed_node.at_css('#dashboard-btns a#btn-my-future-meetings')).to be_present
    expect(parsed_node.at_css('#dashboard-btns a#btn-my-future-meetings').attributes['href'].value).to eq(calendars_starred_path)
  end

  it "includes the 'my workshops' link" do
    expect(parsed_node.at_css('#dashboard-btns a#btn-my-workshops')).to be_present
    expect(parsed_node.at_css('#dashboard-btns a#btn-my-workshops').attributes['href'].value).to eq(user_workshops_path)
  end
end
#-- ---------------------------------------------------------------------------
#++

# Valid view context but with already closed/expired Meetings: tagging components should all
# be disabled.
RSpec.shared_context('calendar_grid rendered with only expired but valid meeting data') do
  # USES:
  # - parsed_node: the rendered fragment parsed with Nokogiri
  # - grid_domain: the displayed domain for the grid
  # Test basic/required content:
  subject(:parsed_node) { Nokogiri::HTML.fragment(rendered) }

  shared_examples_for('calendars/current.html.haml rendered with only valid but *expired* meeting data') do
    it 'includes the link to go back to the dashboard' do
      expect(parsed_node.at_css('a#back-to-parent')).to be_present
      expect(parsed_node.at_css('a#back-to-parent').attributes['href'].value).to eq(home_dashboard_path)
    end

    it 'renders a *disabled* user-star widget for each row in the grid' do
      expect(parsed_node.at_css('section#data-grid table.table tbody tr')).to be_present
      grid_domain.each do |calendar_row|
        # This should always work, even when the meeting_id is not set:
        expect(parsed_node.css("section#data-grid table.table tbody tr td span#user-star-#{calendar_row.meeting_id}")).to be_present
        # The view component though should always be a disabled non-link node:
        expect(parsed_node.css("section#data-grid table.table tbody tr td i#btn-row-star-#{calendar_row.meeting_id}.disabled")).to be_present
      end
    end

    it_behaves_like('common datagrid partial with pagination')
  end

  let(:current_user) { GogglesDb::User.find([1, 2, 4].sample) }
  let(:fixture_season_id) { [162, 172].sample }
  let(:grid_rows) { 8 }
  let(:grid_domain) do
    GogglesDb::Calendar.includes(
      meeting: [
        :swimming_pools,
        { meeting_sessions: [:swimming_pool, { meeting_events: :event_type }] }
      ]
    )
                       .where(season_id: fixture_season_id).distinct
                       .order(scheduled_date: :desc)
                       .first(grid_rows)
  end

  before do
    expect(current_user).to be_a(GogglesDb::User).and be_valid
    expect(current_user.swimmer).to be_a(GogglesDb::Swimmer).and be_valid
    sign_in(current_user)
    expect(grid_domain.count).to be_positive
    allow(view).to receive_messages(user_signed_in?: true, current_user:)
  end
end
#-- ---------------------------------------------------------------------------
#++

# Similar to the previous one, but with still "open" Meetings, so the tagging components
# should be enabled too.
RSpec.shared_context('calendar_grid rendered with valid & not expired meeting data') do
  # USES:
  # - parsed_node: the rendered fragment parsed with Nokogiri
  # - grid_domain: the displayed domain for the grid
  # Test basic/required content:
  subject(:parsed_node) { Nokogiri::HTML.fragment(rendered) }

  shared_examples_for('calendars/current.html.haml rendered with still valid (not expired) meeting data') do
    it 'includes the link to go back to the dashboard' do
      expect(parsed_node.at_css('a#back-to-parent')).to be_present
      expect(parsed_node.at_css('a#back-to-parent').attributes['href'].value).to eq(home_dashboard_path)
    end

    it 'renders an enabled user-star widget for each row in the grid' do
      expect(parsed_node.at_css('section#data-grid table.table tbody tr')).to be_present
      grid_domain.each do |calendar_row|
        # This should always work, even when the meeting_id is not set:
        expect(parsed_node.css("section#data-grid table.table tbody tr td span#user-star-#{calendar_row.meeting_id}")).to be_present
        # The view component should always be an enabled link:
        expect(parsed_node.css("section#data-grid table.table tbody tr td a#btn-row-star-#{calendar_row.meeting_id}")).to be_present
      end
    end

    it_behaves_like('common datagrid partial with pagination')
  end

  let(:current_user) { GogglesDb::User.find([1, 2, 4].sample) }
  let(:fixture_season_id) { GogglesDb::Season.last.id }
  let(:grid_rows) { 8 }
  let(:grid_domain) do
    meetings = FactoryBot.create_list(:meeting, 3, season_id: fixture_season_id, header_date: Time.zone.today + 1.month)
    FactoryBot.create(:calendar, meeting: meetings.first)
    FactoryBot.create(:calendar, meeting: meetings.second)
    FactoryBot.create(:calendar, meeting: meetings.third)

    GogglesDb::Calendar.includes(
      meeting: [
        :swimming_pools,
        { meeting_sessions: [:swimming_pool, { meeting_events: :event_type }] }
      ]
    )
                       .where(season_id: fixture_season_id).distinct
                       .order(scheduled_date: :desc)
                       .first(grid_rows)
  end

  before do
    expect(current_user).to be_a(GogglesDb::User).and be_valid
    expect(current_user.swimmer).to be_a(GogglesDb::Swimmer).and be_valid
    sign_in(current_user)
    expect(grid_domain.count).to be >= 3
    allow(view).to receive_messages(user_signed_in?: true, current_user:)
  end
end
#-- ---------------------------------------------------------------------------
#++
