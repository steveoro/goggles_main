# frozen_string_literal: true

require GogglesDb::Engine.root.join('spec', 'support', 'shared_method_existance_examples')

# == Result (solved? & entity) ==

# REQUIRES/ASSUMES:
# - subject: must be already set as the solver class instance
shared_examples_for 'unsolved Solver strategy (#solved? & #entity)' do
  describe '#solved?' do
    it 'is false' do
      expect(subject.solved?).to be false
    end
  end

  describe '#entity' do
    it 'is nil' do
      expect(subject.entity).to be nil
    end
  end
end

# REQUIRES/ASSUMES:
# - subject: must be already set
# - 'exp_entity': expected #entity.class
shared_examples_for 'solved Solver strategy (#solved? & #entity)' do |exp_entity|
  describe '#solved?' do
    it 'is true' do
      expect(subject.solved?).to be true
    end
  end

  describe '#entity' do
    it 'is the expected entity instance' do
      expect(subject.entity).to be_a(exp_entity)
      expect(subject.entity.id).to be_positive
    end
  end
end
#-- ---------------------------------------------------------------------------
#++

# == Bindings (associations) ==

# REQUIRES/ASSUMES:
# - subject: must be already set
# => Doesn't care if it's before or after #solve!, the result should be the same (no bindings defined)
shared_examples_for 'unsolved or solved Solver strategy (NO bindings)' do
  describe '#all_bindings_solved?' do
    it 'is true' do
      expect(subject.all_bindings_solved?).to be true
    end
  end

  describe '#bindings_solved' do
    it 'is an Hash' do
      expect(subject.bindings_solved).to be_an(Hash)
    end

    it 'is empty' do
      expect(subject.bindings_solved).to be_empty
    end
  end

  describe '#bindings_left' do
    it 'is an Hash' do
      expect(subject.bindings_left).to be_an(Hash)
    end

    it 'is empty' do
      expect(subject.bindings_left).to be_empty
    end
  end
end

# REQUIRES/ASSUMES:
# - subject: must be already set
shared_examples_for 'unsolved Solver strategy (bindings)' do
  describe '#all_bindings_solved?' do
    it 'is false' do
      expect(subject.all_bindings_solved?).to be false
    end
  end
  # bindings_solved could be empty or not, depending if it was partially solved or totally unsolved,
  # so we cannot assert anything useful on it

  describe '#bindings_left' do
    it 'is an Hash' do
      expect(subject.bindings_left).to be_an(Hash)
    end

    it 'is not empty' do
      expect(subject.bindings_left).not_to be_empty
    end
  end
end

# REQUIRES/ASSUMES:
# - subject: must be already set
shared_examples_for 'solved Solver strategy (bindings)' do
  describe '#all_bindings_solved?' do
    it 'is true' do
      expect(subject.all_bindings_solved?).to be true
    end
  end

  describe '#bindings_solved' do
    it 'is an Hash' do
      expect(subject.bindings_solved).to be_an(Hash)
    end

    it 'is not empty' do
      expect(subject.bindings_solved).not_to be_empty
    end
  end

  describe '#bindings_left' do
    it 'is an Hash' do
      expect(subject.bindings_left).to be_an(Hash)
    end

    it 'is empty' do
      expect(subject.bindings_left).to be_empty
    end
  end
end
#-- ---------------------------------------------------------------------------
#++

# == Composite behaviours ==

# REQUIRES/ASSUMES:
# - subject: must be already set as the solver class instance
shared_examples_for 'Solver::BaseStrategy common methods defaults' do
  it_behaves_like(
    'responding to a list of methods',
    %i[entity req bindings
       all_bindings_solved? bindings_solved bindings_left solved?
       solve! error_messages solve_issues]
  )
  it_behaves_like('unsolved Solver strategy (#solved? & #entity)')
end

# REDEFINES:
# - subject
# REQUIRES/ASSUMES:
# - 'target_name': un-namespaced target entity name (i.e.: 'PoolType', without 'GogglesDb::')
# - 'expected_solver': expected solver class (i.e.: Solver::PoolType)
#
# => Typical case: any lookup or leaf entity, without associated bindings, no creation (unique id & code values)
shared_examples_for 'Solver strategy, NO bindings, finder ONLY, before #solve!' do |target_name, expected_solver|
  subject { Solver::Factory.for(target_name, { fake: 'request' }) }

  it "is a #{expected_solver} instance" do
    expect(subject).to be_a(expected_solver)
  end

  describe '#error_messages' do
    it 'is nil' do
      expect(subject.error_messages).to be nil
    end
  end

  describe '#solve_issues' do
    it 'is an empty Hash' do
      expect(subject.solve_issues).to be_an(Hash).and be_empty
    end
  end

  it_behaves_like('Solver::BaseStrategy common methods defaults')
  it_behaves_like('responding to a list of methods', %i[finder_strategy])
  it_behaves_like('unsolved or solved Solver strategy (NO bindings)')
end

# REDEFINES:
# - subject
# REQUIRES/ASSUMES:
# - 'target_name': un-namespaced target entity name (i.e.: 'CategoryType', without 'GogglesDb::')
# - 'expected_solver': expected solver class (i.e.: Solver::CategoryType)
#
# => Typical case: any "complex" leaf entity with associated bindings, no creation
shared_examples_for 'Solver strategy, bindings, finder ONLY, before #solve!' do |target_name, expected_solver|
  subject { Solver::Factory.for(target_name, { fake: 'request' }) }

  it "is a #{expected_solver} instance" do
    expect(subject).to be_a(expected_solver)
  end

  describe '#error_messages' do
    it 'is nil' do
      expect(subject.error_messages).to be nil
    end
  end

  describe '#solve_issues' do
    it 'is an empty Hash' do
      expect(subject.solve_issues).to be_an(Hash).and be_empty
    end
  end

  it_behaves_like('Solver::BaseStrategy common methods defaults')
  it_behaves_like('responding to a list of methods', %i[finder_strategy])
  it_behaves_like('unsolved Solver strategy (bindings)')
end

# REDEFINES:
# - subject
# REQUIRES/ASSUMES:
# - 'target_name': un-namespaced target entity name (i.e.: 'Swimmer', without 'GogglesDb::')
# - 'expected_solver': expected solver class
#
# => Typical case: any complex entity with associated bindings, with creation enabled
shared_examples_for 'Solver strategy, bindings, finder & creator, before #solve!' do |target_name, expected_solver|
  subject { Solver::Factory.for(target_name, { fake: 'request' }) }

  it "is a #{expected_solver} instance" do
    expect(subject).to be_a(expected_solver)
  end

  describe '#error_messages' do
    it 'is nil' do
      expect(subject.error_messages).to be nil
    end
  end

  describe '#solve_issues' do
    it 'is an empty Hash' do
      expect(subject.solve_issues).to be_an(Hash).and be_empty
    end
  end

  it_behaves_like('Solver::BaseStrategy common methods defaults')
  it_behaves_like('responding to a list of methods', %i[finder_strategy creator_strategy])
  it_behaves_like('unsolved Solver strategy (bindings)')
end
#-- ---------------------------------------------------------------------------
#++

# REDEFINES:
# - subject
# REQUIRES/ASSUMES:
# - 'fixture_req': scoped request for the target entity, must be already set
# - 'target_name': un-namespaced target entity name (i.e.: 'GenderType', without 'GogglesDb::')
shared_examples_for 'Solver strategy, NO bindings, UNSOLVABLE req, after #solve!' do |target_name|
  subject do
    solver = Solver::Factory.for(target_name, fixture_req)
    solver.solve!
    solver
  end

  describe '#error_messages' do
    it 'is either nil or present' do
      # (^^ it depends wether the domain has missing data or wrong bindings, but we can't tell from here)
      expect(subject.error_messages.nil? || subject.error_messages.present?).to be true
    end
  end

  describe '#solve_issues' do
    it 'is an empty Hash' do
      expect(subject.solve_issues).to be_an(Hash).and be_empty
    end
  end

  it_behaves_like('unsolved or solved Solver strategy (NO bindings)')
  it_behaves_like('unsolved Solver strategy (#solved? & #entity)')
end

# REDEFINES:
# - subject
# REQUIRES/ASSUMES:
# - 'fixture_req': scoped request for the target entity, must be already set
# - 'target_name': un-namespaced target entity name (i.e.: 'GenderType', without 'GogglesDb::')
shared_examples_for 'Solver strategy, bindings, UNSOLVABLE req, after #solve!' do |target_name|
  subject do
    solver = Solver::Factory.for(target_name, fixture_req)
    solver.solve!
    solver
  end

  describe '#error_messages' do
    it 'is either nil or present' do
      expect(subject.error_messages.nil? || subject.error_messages.present?).to be true
    end
  end

  describe '#solve_issues' do
    it 'is a non-empty Hash' do
      expect(subject.solve_issues).to be_an(Hash).and be_present
    end
  end

  it_behaves_like('unsolved Solver strategy (bindings)')
  it_behaves_like('unsolved Solver strategy (#solved? & #entity)')
end

# REDEFINES:
# - subject
# REQUIRES/ASSUMES:
# - 'fixture_req': scoped request for the target entity, must be already set
# - 'target_name': un-namespaced target entity name (i.e.: 'GenderType', without 'GogglesDb::')
# - 'exp_entity': expected #entity.class
# - 'default_id_value': default ID value for the target entity in case the solver is unsolvable
shared_examples_for 'Solver strategy, NO bindings, UNSOLVABLE req but with DEFAULT VALUE, after #solve!' do |target_name, exp_entity, default_id_value|
  subject do
    solver = Solver::Factory.for(target_name, fixture_req, default_id_value)
    solver.solve!
    solver
  end

  it_behaves_like('unsolved or solved Solver strategy (NO bindings)')
  it_behaves_like('solved Solver strategy (#solved? & #entity)', exp_entity)

  describe '#error_messages' do
    it 'is empty' do
      expect(subject.error_messages).to be_empty
    end
  end

  describe '#solve_issues' do
    it 'is an empty Hash' do
      expect(subject.solve_issues).to be_an(Hash).and be_empty
    end
  end

  describe '#entity' do
    it 'has the expected ID' do
      expect(subject.entity.id).to eq(default_id_value)
    end
  end
end

# REDEFINES:
# - subject
# REQUIRES/ASSUMES:
# - 'fixture_req': scoped request for the target entity, must be already set
# - 'expected_id': expected #entity.id, must be already set; use +nil+ or +false+ to disable the check if the ID is unknown
# - 'target_name': un-namespaced target entity name (i.e.: 'GenderType', without 'GogglesDb::')
# - 'exp_entity': expected #entity.class
shared_examples_for 'Solver strategy, NO bindings, solvable req, after #solve!' do |target_name, exp_entity|
  subject do
    solver = Solver::Factory.for(target_name, fixture_req)
    solver.solve!
    solver
  end

  it_behaves_like('unsolved or solved Solver strategy (NO bindings)')
  it_behaves_like('solved Solver strategy (#solved? & #entity)', exp_entity)

  describe '#error_messages' do
    it 'is empty' do
      expect(subject.error_messages).to be_empty
    end
  end

  describe '#solve_issues' do
    it 'is an empty Hash' do
      expect(subject.solve_issues).to be_an(Hash).and be_empty
    end
  end

  describe '#entity' do
    it 'has the expected ID' do
      expect(subject.entity.id).to eq(expected_id) if expected_id
    end
  end
end

# REQUIRES/ASSUMES:
# - subject: must be already set (so that we can test it also outside of this shared example)
# - 'fixture_req': scoped request for the target entity, must be already set
# - 'expected_id': expected #entity.id, must be already set; use +nil+ or +false+ to disable the check if the ID is unknown
# - 'target_name': un-namespaced target entity name (i.e.: 'GenderType', without 'GogglesDb::')
# - 'exp_entity': expected #entity.class
shared_examples_for 'Solver strategy, bindings, solvable req, after #solve!' do |exp_entity|
  it_behaves_like('solved Solver strategy (bindings)')
  it_behaves_like('solved Solver strategy (#solved? & #entity)', exp_entity)

  describe '#error_messages' do
    it 'is empty' do
      expect(subject.error_messages).to be_empty
    end
  end

  describe '#solve_issues' do
    it 'is an empty Hash' do
      expect(subject.solve_issues).to be_an(Hash).and be_empty
    end
  end

  describe '#entity' do
    it 'has expected ID' do
      expect(subject.entity.id).to eq(expected_id) if expected_id
    end
  end
end

# REQUIRES/ASSUMES:
# - subject: must be already set (so that we can test it also outside of this shared example)
# - 'fixture_req': scoped request for the target entity, must be already set
# - 'expected_id': expected #entity.id, must be already set; use +nil+ or +false+ to disable the check if the ID is unknown
# - 'target_name': un-namespaced target entity name (i.e.: 'GenderType', without 'GogglesDb::')
# - 'exp_entity': expected #entity.class
shared_examples_for 'Solver strategy, OPTIONAL bindings, solvable req, after #solve!' do |exp_entity|
  # (Don't care if all the bindings have been resolved, since some of these are supposed to be optional in this case)
  it_behaves_like('solved Solver strategy (#solved? & #entity)', exp_entity)

  describe '#error_messages' do
    it 'is empty' do
      expect(subject.error_messages).to be_empty
    end
  end

  describe '#solve_issues' do
    # 'Can't be too specific in this case (could be present or empty):
    it 'is an Hash' do
      expect(subject.solve_issues).to be_an(Hash)
    end
  end

  describe '#entity' do
    it 'has expected ID' do
      expect(subject.entity.id).to eq(expected_id) if expected_id
    end
  end
end
#-- ---------------------------------------------------------------------------
#++
