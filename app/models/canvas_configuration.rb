class CanvasConfiguration < ActiveRecord::Base
  has_many :batches, dependent: :destroy
  validates_presence_of :name, :domain, :access_token

  def name_with_domain
    "#{name} - #{domain}"
  end
end
