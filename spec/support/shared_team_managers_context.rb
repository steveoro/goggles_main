# frozen_string_literal: true

RSpec.shared_context('current_user is a team manager on last FIN season ID') do
  let(:last_season_id) do
    # Consider last season *including* results (NOTE: cfr. app/controllers/application_controller.rb:278)
    GogglesDb::Season.joins(meetings: :meeting_individual_results)
                     .last_season_by_type(GogglesDb::SeasonType.mas_fin).id
  end

  let(:meeting_with_results) do
    GogglesDb::Meeting.includes(:meeting_individual_results).joins(:meeting_individual_results)
                      .where(season_id: last_season_id)
                      .by_date(:desc).first(25)
                      .sample
  end

  let(:managed_team) { meeting_with_results.meeting_individual_results.sample.team }

  let(:associated_mirs) do
    GogglesDb::MeetingIndividualResult.includes(meeting: :season).joins(meeting: :season)
                                      .where(team_id: managed_team.id, 'meetings.season_id': last_season_id)
  end

  let(:team_affiliation) do
    GogglesDb::TeamAffiliation.where(team_id: managed_team.id, season_id: last_season_id).first ||
      FactoryBot.create(:team_affiliation, season: GogglesDb::Season.find(last_season_id))
  end

  let(:managed_aff) do
    GogglesDb::ManagedAffiliation.where(team_affiliation_id: team_affiliation.id).first ||
      FactoryBot.create(:managed_affiliation, team_affiliation:)
  end

  let(:current_user) do
    user = managed_aff.manager
    user.confirmed_at = Time.zone.now if user.confirmed_at.blank?
    user.password = 'Password123!'
    user.save!
    user
  end

  before do
    expect(last_season_id).to be_positive
    expect(meeting_with_results).to be_a(GogglesDb::Meeting).and be_valid
    expect(managed_team).to be_a(GogglesDb::Team).and be_valid
    expect(associated_mirs.count).to be_positive
    expect(team_affiliation).to be_a(GogglesDb::TeamAffiliation).and be_valid
    expect(managed_aff).to be_a(GogglesDb::ManagedAffiliation).and be_valid
    expect(associated_mirs).to be_present
    expect(current_user).to be_a(GogglesDb::User).and be_valid
    expect(current_user).to eq(managed_aff.manager)
  end
end
