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
      if submission_type.to_sym == :online_upload
        Dir.mktmpdir do |dir|
          file_name = "#{user.name}-#{SecureRandom.uuid}.txt"
          file_path = "#{dir}/#{file_name}"
          File.open(file_path, 'w') do |file|
            file.write Forgery::Education.sentence_from_literature
          end
          client.course_file_upload_submission(course_id, assignment_id, user.id, file_path, { name: file_name, as_user_id: user.id })
        end
      elsif submission_type.to_sym == :discussion_topic
        client.post("/api/v1/courses/#{course_id}/discussion_topics/#{assignment_id}/entries", { as_user_id: user.id, message: Forgery::Education.sentence_from_literature })
      else
        resp = client.course_submission(course_id, assignment_id, { as_user_id: user.id, submission: { submission_type: submission_type, body: submission_data } })
      end
      Rails.logger.info("Submitted to assignment #{assignment_id} in course #{course_id} as #{user.name}")
    end

    def grade!(client, course_id, assignment_id, score)
      self.score = score
      resp = client.grade_course_submission(course_id, assignment_id, user.id, { submission: { posted_grade: score } })
      Rails.logger.info("Graded submission for #{user.name} with score of #{score}")
    end
  end
end
