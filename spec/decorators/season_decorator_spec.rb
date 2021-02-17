# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SeasonDecorator do
  describe '#last_season_by_type' do
    [
      GogglesDb::SeasonType::MAS_FIN_ID, GogglesDb::SeasonType::MAS_CSI_ID,
      GogglesDb::SeasonType::MAS_LEN_ID, GogglesDb::SeasonType::MAS_FINA_ID
    ].each do |season_type_id|
      context "for a valid SeasonType (ID #{season_type_id}) for which exists at least a Season," do
        subject do
          # Any season will do, since this is a more generic helper:
          SeasonDecorator
            .new(GogglesDb::Season.limit(10).sample)
            .last_season_by_type(season_type_id)
        end

        it 'returns a valid instance of Season' do
          expect(subject).to be_a(GogglesDb::Season).and be_valid
        end
      end
    end
  end
end
