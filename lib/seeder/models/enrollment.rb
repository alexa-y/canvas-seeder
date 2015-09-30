module Seeder::Models
  class Enrollment
    attr_accessor :user, :type

    def initialize(user, type)
      self.user = user
      self.type = type
    end

    def save!(client, section_id)
      resp = client.enroll_in_section(section_id, { enrollment: { user_id: user.id, type: type, enrollment_state: 'active' } })
      Rails.logger.info("Created enrollment for #{user.name} in section #{section_id}")
    end
  end
end
