# frozen_string_literal: true

# rubocop:disable Rails/Output
class DataFixRemoveNullRankValues < ActiveRecord::Migration[6.0]
  def self.up
    total_fixes = GogglesDb::MeetingRelayResult.where(rank: nil).count

    if total_fixes.positive?
      puts("\r\n--> Found #{total_fixes} MRR rows with null rank: updating them to zero...")
      GogglesDb::MeetingRelayResult.where(rank: nil).update_all(rank: 0)
    else
      puts("\r\n--> No MRR with null ranks found: nothing to fix, all is good.")
    end

    # --- Update DB structure versioning:
    GogglesDb::AppParameter.versioning_row.update(
      GogglesDb::AppParameter::FULL_VERSION_FIELDNAME => GogglesDb::Version::FULL,
      GogglesDb::AppParameter::DB_VERSION_FIELDNAME => GogglesDb::Version::DB
    )
  end

  def self.down
    # (no-op)
  end
  #-- --------------------------------------------------------------------------
  #++
end
# rubocop:enable Rails/Output
