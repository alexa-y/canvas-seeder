module Seeder::Models
  class Section
    attr_accessor :id, :name, :sis_id, :enrollments

    def initialize
      self.enrollments = []
    end

    def populate(name = Forgery::Education.course_title)
      section_number = SecureRandom.random_number(1000)
      self.name = "#{name} #{section_number}"
      match = name.match(Seeder::Models::Course::COURSE_CODE_PATTERN)
      self.sis_id = "sis_section_#{match[1].gsub(/ /, '_')}_#{section_number}" rescue nil
    end

    def save!(client, course_id)
      resp = client.create_section(course_id, { course_section: { name: name, sis_section_id: sis_id } })
      self.id = resp['id']
      Rails.logger.info("Created section #{name}")
    end
  end
end
