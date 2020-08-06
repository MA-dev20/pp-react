class TaskMediaController < ApplicationController
  before_action :set_task_medium, only: [:update, :delete]
  before_action :set_user
  def create
    @task_medium = @company.task_media.new(task_medium_params)
    @task_medium.user = @user
    if @task_medium.save
      render json: {id: @task_medium.id}
    else
      flash[:alert] = "Konnte Media nicht speichern!"
      render json: {error: true}
    end
  end
  def update
    @task_medium.update(task_medium_params)
    render json: {title: @task_medium.title}
  end

  def delete
    @task_medium_id = @task_medium.id
    if @task_medium.tasks.count == 0
      @task_medium.destroy
      render json: {id: @task_medium_id}
    else
      render json: {error: 'Content ist noch einer Task zugeordnet!'}
    end
  end
  private
    def set_user
      if user_signed_in? && company_logged_in?
        @user = current_user
        @company = current_company
      elsif user_signed_in?
        redirect_to dash_choose_company_path
      else
        redirect_to root_path
      end
    end
    def task_medium_params
      params.require(:task_medium).permit(:title, :audio, :video, :pdf, :image, :media_type)
    end
    def set_task_medium
      @task_medium = TaskMedium.find(params[:task_medium_id])
    end
end
