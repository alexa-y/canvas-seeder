module Seeder
  class Seeder

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
      @batch.update state: 'running'
      process
      calculate_progress
      save_objects
      write_output_to_batch
      @batch.update state: 'completed'
    rescue => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace
      @batch.update state: 'failed'
    end

    def process
      rounds(:number_of_teachers) do
        teacher = ::Seeder::Models::User.new @params[:account_id]
        teacher.populate
        @teachers << teacher
      end
      rounds(:number_of_students) do
        student = ::Seeder::Models::User.new @params[:account_id]
        student.populate
        @students << student
      end
      rounds(:number_of_courses) do |index|
        course = ::Seeder::Models::Course.new @params[:account_id], @params[:term_id]
        course.populate
        @courses << course
      end
      @courses.each do |course|
        rounds(:number_of_sections) do
          section = ::Seeder::Models::Section.new
          section.populate course.name
          @teachers.each do |teacher|
            section.enrollments << ::Seeder::Models::Enrollment.new(teacher, 'TeacherEnrollment')
          end
          @students.each do |student|
            section.enrollments << ::Seeder::Models::Enrollment.new(student, 'StudentEnrollment')
          end
          course.sections << section
        end
        rounds(:number_of_assignments) do
          assignment = ::Seeder::Models::Assignment.new pick(:types_of_assignments), pick(:points_possible)
          assignment.populate
          apply_submissions(assignment)
          course.assignments << assignment
        end
      end
    end

    def calculate_progress
      @total_objects = @teachers.length + @students.length
      @total_objects += @courses.length
      @total_objects += @courses.flat_map { |c| c.sections }.length
      @total_objects += @courses.flat_map { |c| c.sections }.flat_map { |s| s.enrollments }.length
      @total_objects += @courses.flat_map { |c| c.assignments }.length
      @total_objects += @courses.flat_map { |c| c.assignments }.flat_map { |a| a.submissions }.length
    end

    def increment_progress
      @current_progress ||= 0
      @current_progress += 1

      @batch.update progress: (@current_progress * 100 / @total_objects)
    end

    def apply_submissions(assignment)
      @students.each do |student|
        if pick(:students_with_submissions).to_i > rand(100)
          submission = ::Seeder::Models::Submission.new student, assignment.submission_type
          submission.populate
          assignment.submissions << submission
        end
      end
    end

    def grade_submission(course, assignment, submission)
      if pick(:grade_submissions).to_i > rand(100)
        score = assignment.grading_type == 'pass_fail' ? %w(complete incomplete).sample : (0..assignment.points_possible).to_a.sample
        submission.grade! api_client, course.id, assignment.id, score
      end
    end

    def save_objects
      (@teachers + @students).each do |user|
        user.save! api_client
        increment_progress
      end
      @courses.each do |course|
        course.save! api_client
        increment_progress
        course.sections.each do |section|
          section.save! api_client, course.id
          increment_progress
          section.enrollments.each do |enrollment|
            enrollment.save! api_client, section.id
            increment_progress
          end
        end
        course.assignments.each do |assignment|
          assignment.save! api_client, course.id
          increment_progress
          assignment.submissions.each do |submission|
            assignment_id = assignment.submission_type.to_sym == :discussion_topic ? assignment.discussion_topic_id : assignment.id
            submission.save! api_client, course.id, assignment_id
            grade_submission(course, assignment, submission)
            increment_progress
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
      num = @params[type]
      num = num.to_a.sample if num.is_a?(Range)
      if block_given?
        num.to_i.times do |index|
          yield index
        end
      else
        num.to_i
      end
    end
    alias_method :count, :rounds

    def pick(type)
      obj = @params[type]
      if obj.is_a?(Range) || obj.is_a?(Array)
        obj.to_a.sample
      else
        obj
      end
    end

    def default_params
      {
        account_id: 'self',
        term_id: nil,
        number_of_courses: 1,
        number_of_sections: 1,
        number_of_teachers: 1,
        number_of_students: 5,
        number_of_assignments: (5..10),
        points_possible: (5..20),
        types_of_assignments: ::Seeder::Models::Assignment::TYPES_OF_ASSIGNMENTS,
        students_with_submissions: 80,
        grade_submissions: 80
      }
    end
  end
end
