class Batch < ActiveRecord::Base
  belongs_to :canvas_configuration
  serialize :params, Hash
  serialize :output, Hash

  before_create do
    self.state ||= 'queued'
  end

  def retry
    self.state = 'queued'
    self.output = {}
    save!
    Seeder::Seeder.new(self).delay.process!
  end
end
