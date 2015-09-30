module Seeder
  class Seeder
    include Models

    def initialize(batch)
      @batch = batch
      @config = batch.canvas_configuration
      @batch.params = default_params if @batch.params.empty?
      @params = @batch.params
      @courses = []
      @teachers = []
      @students = []
    end

    def process!
      process
      save_objects
      write_output_to_batch
    end

    def process
      rounds(:number_of_teachers) do
        teacher = User.new @params[:account_id]
        teacher.populate
        @teachers << teacher
      end
      rounds(:number_of_students) do
        student = User.new @params[:account_id]
        student.populate
        @students << student
      end
      rounds(:number_of_courses) do |index|
        course = Course.new @params[:account_id], @params[:term_id]
        course.populate
        @courses << course
      end
      @courses.each do |course|
        rounds(:number_of_sections) do
          section = Section.new
          section.populate course.name
          @teachers.each do |teacher|
            section.enrollments << Enrollment.new(teacher, 'TeacherEnrollment')
          end
          @students.each do |student|
            section.enrollments << Enrollment.new(student, 'StudentEnrollment')
          end
          course.sections << section
        end
      end
    end

    def save_objects
      (@teachers + @students).each do |user|
        user.save! api_client
      end
      @courses.each do |course|
        course.save! api_client
        course.sections.each do |section|
          section.save! api_client, course.id
          section.enrollments.each do |enrollment|
            enrollment.save! api_client, section.id
          end
        end
      end
    end

    def write_output_to_batch
      @batch.output[:teachers] = @teachers.map { |t| t.as_json }
      @batch.output[:students] = @students.map { |s| s.as_json }
      @batch.output[:courses] = @courses.map { |c| c.as_json }
      @batch.save!
    end

    def api_client
      @api_client ||= Bearcat::Client.new(prefix: @config.domain, token: @config.access_token)
    end

    def rounds(type)
      raise 'This method must be called with a block' unless block_given?
      num = @params[type]
      num = num.to_a.sample if num.is_a?(Range)
      num.times do |index|
        yield index
      end
    end

    def default_params
      {
        account_id: 'self',
        term_id: nil,
        number_of_courses: 2,
        number_of_sections: 2,
        number_of_teachers: 1,
        number_of_students: 5,
        number_of_assignments: (5..10),
        points_possible: (5..20),
        types_of_assignments: %i(online_text_entry discussion_topic),
        number_of_submissions: 1
      }
    end
  end
end
