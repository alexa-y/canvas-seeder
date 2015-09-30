module Seeder::Models
  class Submission
    attr_accessor :user, :submission_type, :submission_data, :score

    def initialize(user, submission_type)
      self.user = user
      self.submission_type = submission_type
    end

    def populate
      case submission_type.to_sym
      when :online_text_entry
        self.submission_data = Forgery::Education.sentence_from_literature
      end
    end

    def save!(client, course_id, assignment_id)
      resp = client.course_submission(course_id, assignment_id, { as_user_id: user.id, submission: { submission_type: submission_type, body: submission_data } })
      Rails.logger.info("Submitted to assignment #{assignment_id} in course #{course_id} as #{user.name}")
    end

    def grade!(client, course_id, assignment_id, score)
      self.score = score
      resp = client.grade_course_submission(course_id, assignment_id, user.id, { submission: { posted_grade: score } })
      Rails.logger.info("Graded submission for #{user.name} with score of #{score}")
    end
  end
end
