class ConfigurationsController < ApplicationController

  before_action only: [:destroy, :show, :edit, :update] do
    @configuration = CanvasConfiguration.find params[:id]
  end

  def index
    @configurations = CanvasConfiguration.all
  end

  def new
    @configuration ||= CanvasConfiguration.new
  end

  def create
    @configuration ||= CanvasConfiguration.new configuration_params
    if @configuration.save
      redirect_to configurations_path
    else
      render 'new'
    end
  end

  def update
    if @configuration.update configuration_params
      redirect_to configurations_path
    else
      render 'edit'
    end
  end

  def destroy
    @configuration.destroy
    redirect_to configurations_path
  end

  private
  def configuration_params
    params.require(:canvas_configuration).permit(:name, :domain, :access_token)
  end
end
