# frozen_string_literal: true

class DataFixSetEmptyBadgeNumbers < ActiveRecord::Migration[6.0]
  def change
    GogglesDb::Badge.where(number: '').update(number: '?')
  end
end
