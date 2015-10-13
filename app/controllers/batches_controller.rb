class BatchesController < ApplicationController

  before_action only: [:show, :view_params, :output, :progress] do
    @batch = Batch.find params[:id]
  end

  def index
    @batches = Batch.all.includes(:canvas_configuration).order(created_at: :desc)
  end

  def view_params
    render json: @batch.params, status: :ok
  end

  def output
    render json: @batch.output, status: :ok
  end

  def progress
    render json: { progress: @batch.progress || 0 }, status: :ok
  end

  def new
    @batch = Batch.new
    @canvas_configurations = CanvasConfiguration.all
  end

  def create
    @batch = Batch.new batch_params
    if @batch.save
      Seeder::Seeder.new(@batch).delay.process!
      redirect_to batch_path(@batch)
    else
      render 'new'
    end
  end

  private
  def batch_params
    params[:batch][:params][:number_of_courses] = (params[:batch][:params].delete(:number_of_courses_min).to_i..params[:batch][:params].delete(:number_of_courses_max).to_i)
    params[:batch][:params][:number_of_sections] = (params[:batch][:params].delete(:number_of_sections_min).to_i..params[:batch][:params].delete(:number_of_sections_max).to_i)
    params[:batch][:params][:number_of_teachers] = (params[:batch][:params].delete(:number_of_teachers_min).to_i..params[:batch][:params].delete(:number_of_teachers_max).to_i)
    params[:batch][:params][:number_of_students] = (params[:batch][:params].delete(:number_of_students_min).to_i..params[:batch][:params].delete(:number_of_students_max).to_i)
    params[:batch][:params][:number_of_assignments] = (params[:batch][:params].delete(:number_of_assignments_min).to_i..params[:batch][:params].delete(:number_of_assignments_max).to_i)
    params[:batch][:params][:points_possible] = (params[:batch][:params].delete(:points_possible_min).to_i..params[:batch][:params].delete(:points_possible_max).to_i)
    params.require(:batch).permit!
  end
end
