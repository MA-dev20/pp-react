class TaskMediaController < ApplicationController
  before_action :set_task_medium
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
    def task_medium_params
      params.require(:task_medium).permit(:title)
    end
    def set_task_medium
      @task_medium = TaskMedium.find(params[:task_medium_id])
    end
end
