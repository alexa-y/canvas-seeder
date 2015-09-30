class Batch < ActiveRecord::Base
  belongs_to :canvas_configuration
  serialize :params, Hash
  serialize :output, Hash
end
