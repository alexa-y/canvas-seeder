class Batch < ActiveRecord::Base
  belongs_to :canvas_configuration
  serialize :params, Hash
  serialize :output, Hash

  before_create do
    self.state ||= 'queued'
    self.progress ||= 0
  end

  before_save do
    self.progress = 100 if self.state == 'completed'
  end

  def retry
    self.state = 'queued'
    self.output = {}
    save!
    Seeder::Seeder.new(self).delay.process!
  end
end
