module Seeder::Models
  class Course
    COURSE_CODE_PATTERN = /^([A-Z]{3,4} \d{3,4}).*$/

    attr_accessor :account_id, :term_id, :sections, :assignments, :name, :course_code, :sis_id, :id

    def initialize(account_id, term_id)
      self.account_id = account_id
      self.term_id = term_id
      @sections = []
      @assignments = []
    end

    def populate
      self.name = Forgery::Education.course_title
      self.course_code = name.match(COURSE_CODE_PATTERN)[1] rescue nil
      self.sis_id = "sis_#{course_code.gsub(/ /, '_')}_#{SecureRandom.random_number(1000)}" rescue nil
    end

    def save!(client)
      resp = client.create_course(account_id, { course: { name: name, course_code: course_code, term_id: term_id, sis_course_id: sis_id } })
      self.id = resp['id']
      Rails.logger.info("Created course #{name}")
    end
  end
end
