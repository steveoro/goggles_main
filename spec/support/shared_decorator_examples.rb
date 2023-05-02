# frozen_string_literal: true

require GogglesDb::Engine.root.join('spec', 'support', 'shared_method_existance_examples')

# REQUIRES/ASSUMES:
# - subject: the decorated object
shared_examples_for 'a paginated model decorated with' do |decorator_class|
  it "is a model decorated with #{decorator_class}" do
    expect(subject).to be_decorated_with(decorator_class)
  end

  it_behaves_like(
    'responding to a list of methods',
    %i[current_page total_pages limit_value total_count
       offset_value last_page?]
  )
end

# REQUIRES/ASSUMES:
# - subject: the decorated object
# PARAMS:
# - core_decorator_class: a decorator class for the object from the core DB engine
#                         (i.e.: GogglesDb::Team |=> GogglesDb::TeamDecorator)
shared_examples_for '#decorated for a core model with a core decorator' do |core_decorator_class|
  describe '#decorated' do
    let(:result) { subject.decorated }

    it "is an instance of #{core_decorator_class}" do
      expect(result).to be_a(core_decorator_class)
    end

    it 'responds to #display_label' do
      expect(result).to respond_to(:display_label)
    end

    it 'responds to #short_label' do
      expect(result).to respond_to(:short_label)
    end
  end
end
