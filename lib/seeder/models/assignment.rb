module Seeder::Models
  class Assignment
    TYPES_OF_ASSIGNMENTS = %i(online_text_entry)
    attr_accessor :id, :name, :description, :grading_type, :submission_type, :points_possible, :submissions

    def initialize(submission_type, points_possible)
      self.submission_type = submission_type
      self.points_possible = points_possible
      self.grading_type = %w(pass_fail percent letter_grade points).sample
      self.submissions = []
    end

    def populate
      self.name = self.description = Forgery::Education.sentence_from_literature[0, 255]
    end

    def save!(client, course_id)
      resp = client.create_assignment(course_id, { assignment: { name: name, submission_types: [submission_type], points_possible: points_possible,
        grading_type: grading_type, description: description, published: true } })
      self.id = resp['id']
      Rails.logger.info("Created assignment #{name} in course #{course_id}")
    end
  end
end
