# frozen_string_literal: true

require 'rails_helper'

require GogglesDb::Engine.root.join('spec', 'support', 'shared_method_existance_examples')

RSpec.describe Solver::BaseStrategy, type: :strategy do
  subject { described_class.new(req: {}) }

  it 'is a Solver::BaseStrategy instance' do
    expect(subject).to be_a(described_class)
  end

  it_behaves_like('Solver::BaseStrategy common methods defaults')
  it_behaves_like('unsolved or solved Solver strategy (NO bindings)')
end
