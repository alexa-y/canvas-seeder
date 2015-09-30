class BatchesController < ApplicationController

  before_action only: [:show, :batch_params, :output] do
    @batch = Batch.find params[:id]
  end

  def index
    @batches = Batch.all.includes(:canvas_configuration).order(created_at: :desc)
  end

  def batch_params
    render json: @batch.params, status: :ok
  end

  def output
    render json: @batch.output, status: :ok
  end
end
