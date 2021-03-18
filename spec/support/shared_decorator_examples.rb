# frozen_string_literal: true

require GogglesDb::Engine.root.join('spec', 'support', 'shared_method_existance_examples')

# REQUIRES/ASSUMES:
# - subject set to the decorated object
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
