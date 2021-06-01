# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solver::Factory, type: :strategy do
  it 'responds to self.for' do
    expect(described_class).to respond_to(:for)
  end

  describe 'self.for' do
    context 'for an invalid parameter,' do
      [0, nil, 'NonExistingTarget'].each do |target_argument|
        subject { described_class.for(target_argument, {}) }
        it 'raises an ArgumentError' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end

    context 'for a valid parameter,' do
      [
        ['CategoryType', Solver::CategoryType],
        ['City', Solver::City],

        ['DisqualificationCodeType', Solver::LookupEntity],
        ['EditionType', Solver::LookupEntity],
        ['EventType', Solver::LookupEntity],
        ['GenderType', Solver::LookupEntity],
        ['PoolType', Solver::LookupEntity],
        ['SeasonType', Solver::LookupEntity],
        ['TimingType', Solver::LookupEntity],

        ['Season', Solver::Season],
        ['Swimmer', Solver::Swimmer],
        ['SwimmingPool', Solver::SwimmingPool],
        ['Team', Solver::Team],
        ['UserLap', Solver::UserLap],
        ['UserResult', Solver::UserResult],
        ['UserWorkshop', Solver::UserWorkshop]
        # TODO
      ].each do |args|
        it "returns the expected strategy class instance (#{args.first})" do
          expect(described_class.for(args.first, {})).to be_a(args.last)
        end
      end
    end
  end
end
