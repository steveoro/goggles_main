# frozen_string_literal: true

shared_examples_for 'invalid row id GET request' do
  it 'redirects to root_path' do
    expect(response).to redirect_to(root_path)
  end

  it 'sets the flash with a warning message' do
    expect(flash[:warning]).to eq(I18n.t('search_view.errors.invalid_request'))
  end
end
