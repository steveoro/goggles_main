# frozen_string_literal: true

# = ApplicationRecord
#
# Common parent model
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
