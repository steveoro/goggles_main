# frozen_string_literal: true

Given('I have a pre-computed Goggle Cup for my managed team in {string} for an enrolled swimmer') do |year|
  team = FactoryBot.create(:team)
  team_affiliation = FactoryBot.create(:team_affiliation, team: team)
  FactoryBot.create(:managed_affiliation, manager: @current_user, team_affiliation: team_affiliation)
  @managed_team = team

  swimmer = @matching_swimmer || FactoryBot.create(:swimmer)
  @enrolled_swimmer = swimmer

  @goggle_cup = FactoryBot.create(
    :goggle_cup,
    team: team,
    season_year: year.to_i,
    description: "Goggle Cup Browse Test #{Time.current.to_i}",
    swimmers_ids: swimmer.id.to_s,
    ranking_data: goggle_cup_ranking_json(swimmer, team)
  )
end

When('I select {string} as the championship year and my managed team') do |year|
  page.execute_script(
    <<~JS
      document.getElementById('season_year').value = '#{year}';
      document.getElementById('season_year').dispatchEvent(new Event('change'));
      document.getElementById('team_id').value = '#{@managed_team.id}';
      document.getElementById('team_id').dispatchEvent(new Event('change'));
    JS
  )
end

Then('I should see the cup title button') do
  expect(page).to have_link(@goggle_cup.description)
end

When('I click on the cup title') do
  click_link(@goggle_cup.description)
end

Then('I should see the swimmer name in the computed ranking') do
  expect(page).to have_text(@enrolled_swimmer.complete_name)
end

Then('I should see the base timings toggle for the swimmer') do
  expect(page).to have_css("a[href='#base-timings-#{@enrolled_swimmer.id}']")
end

def goggle_cup_ranking_json(swimmer, team)
  {
    description: @goggle_cup&.description || 'Test Cup',
    season_year: @goggle_cup&.season_year || 2025,
    max_points: 1000,
    team_id: team.id,
    end_date: '2026-07-31',
    swimmer_ids: [swimmer.id],
    no_duplicated_events: false,
    data: {
      base_timings: { swimmer.id.to_s => [base_timing_row(team)] },
      scores: { swimmer.id.to_s => [score_row(team)] }
    }
  }.to_json
end

def base_timing_row(team)
  {
    'event_type_code' => '50SL', 'pool_type_code' => '25',
    'season_header_year' => '2022', 'total_hundredths' => 3100,
    'meeting_date' => '2022-03-10', 'meeting_name' => 'Base Meeting',
    'meeting_id' => 10, 'meeting_individual_result_id' => 100,
    'team_id' => team.id, 'team_name' => team.name
  }
end

def score_row(team)
  {
    'event_type_code' => '50SL', 'pool_type_code' => '25',
    'season_header_year' => '2025', 'total_hundredths' => 3000,
    'meeting_date' => '2025-01-15', 'meeting_name' => 'Test Meeting',
    'meeting_id' => 42, 'meeting_individual_result_id' => 99,
    'team_id' => team.id, 'team_name' => team.name,
    'old_total_hundredths' => 3200, 'old_meeting_date' => '2024-01-10',
    'old_meeting_name' => 'Old Meeting', 'old_meeting_id' => 30,
    'old_meeting_individual_result_id' => 88,
    'row_score' => 1066.67
  }
end
