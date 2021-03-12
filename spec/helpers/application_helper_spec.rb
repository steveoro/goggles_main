# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#check_mark_icon_for' do
    it 'renders two different values for true and false' do
      expect(helper.check_mark_icon_for(true)).not_to eq(helper.check_mark_icon_for(false))
    end
  end
end
