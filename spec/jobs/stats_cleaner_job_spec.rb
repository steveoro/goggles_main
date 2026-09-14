# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatsCleanerJob do
  it "enqueues the job on the 'issues' queue" do
    expect { described_class.perform_later }.to have_enqueued_job.on_queue('issues')
  end

  describe '#perform' do
    let!(:old_daily_use) { FactoryBot.create(:api_daily_use, day: 40.days.ago.to_date) }
    let!(:recent_daily_use) { FactoryBot.create(:api_daily_use, day: Time.zone.today) }
    let!(:old_agent_use) do
      FactoryBot.create(:api_daily_use_agent, user_agent: 'StatsCleaner/Old', day: 40.days.ago.to_date)
    end
    let!(:recent_agent_use) do
      FactoryBot.create(:api_daily_use_agent, user_agent: 'StatsCleaner/Recent', day: Time.zone.today)
    end

    it 'deletes old API usage rows and keeps recent rows' do
      described_class.perform_now

      expect(GogglesDb::APIDailyUse.exists?(old_daily_use.id)).to be false
      expect(GogglesDb::APIDailyUse.exists?(recent_daily_use.id)).to be true
      expect(GogglesDb::APIDailyUseAgent.exists?(old_agent_use.id)).to be false
      expect(GogglesDb::APIDailyUseAgent.exists?(recent_agent_use.id)).to be true
    end

    it 'respects a custom retention period' do
      old_daily_use.update!(day: 10.days.ago.to_date)
      recent_daily_use.update!(day: 3.days.ago.to_date)
      old_agent_use.update!(day: 10.days.ago.to_date)
      recent_agent_use.update!(day: 3.days.ago.to_date)

      described_class.perform_now(7)

      expect(GogglesDb::APIDailyUse.exists?(old_daily_use.id)).to be false
      expect(GogglesDb::APIDailyUse.exists?(recent_daily_use.id)).to be true
      expect(GogglesDb::APIDailyUseAgent.exists?(old_agent_use.id)).to be false
      expect(GogglesDb::APIDailyUseAgent.exists?(recent_agent_use.id)).to be true
    end
  end
end
