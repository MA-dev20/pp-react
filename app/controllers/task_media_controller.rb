class TaskMediaController < ApplicationController
  def update
    @task_medium = TaskMedium.find(params[:task_medium_id])
    @task_medium.update(task_medium_params)
    render json: {title: @task_medium.title}
  end

  private
    def task_medium_params
      params.require(:task_medium).permit(:title)
    end
end
