class TaskMediaController < ApplicationController
  before_action :set_task_medium, only: [:update, :delete]
  before_action :set_user
  def create
    @task_medium = @company.task_media.new(task_medium_params)
    @task_medium.user = @user
    if @task_medium.save
      if @task_medium.media_type == 'pdf'
        path = @task_medium.pdf.current_path.split('/'+@task_medium.pdf.identifier)[0]
    	  images = Docsplit.extract_images( @task_medium.pdf.current_path, :output => path)
    	  Dir.chdir(path)
    	  Dir.glob("*.png").each do |img|
      		task_medium = TaskMedium.create(company: @task_medium.company, user: @task_medium.user, image: File.open(img), media_type: 'image', is_pdf: true, task_medium: @task_medium)
      		File.delete(img)
        end
      end
      render json: {id: @task_medium.id}
    else
      flash[:alert] = "Konnte Media nicht speichern!"
      render json: {error: true}
    end
  end

  def create_global
    @task_medium = @user.task_media.new(task_medium_params)
    @task_medium.available_for = 'global'
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
      params.require(:task_medium).permit(:title, :audio, :video, :pdf, :image, :media_type, :content_folder_id)
    end
    def set_task_medium
      @task_medium = TaskMedium.find(params[:task_medium_id])
    end
end
