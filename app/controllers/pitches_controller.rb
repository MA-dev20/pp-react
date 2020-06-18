class PitchesController < ApplicationController
  #GET pitches/:pitch_id/tasks/:task_id/setOrder/:order
  def set_order
	@pitch = Pitch.find(params[:pitch_id])
	@task_order = TaskOrder.find(params[:task_id])
	@order = params[:order].to_i
	@task_orders = @pitch.task_orders.where.not(id: params[:task_id])
	if @order <= @task_order.order
		@task_orders.each do |to|
			if to.order >= @order
			  to.update(order: to.order + 1)
			end
		end
    else
		@task_orders.each do |to|
			if to.order <= @order
			  to.update(order: to.order - 1)
			end
		end
	end
	@task_order.update(order: @order)
	i = 1
	@pitch.task_orders.order(:order).each do |to|
		to.update(order: i)
		i = i + 1
	end
	render json: {id: @task_order.task_id}
  end
  def create_task
	@pitch = Pitch.find(params[:pitch_id])
    @task = @pitch.tasks.create(user: @pitch.user)
	redirect_to dashboard_edit_pitch_path(@pitch, task_id: @task.id)
  end

  def update_pitch
	@pitch = Pitch.find(params[:id])
	if @pitch.update(pitch_params)
		redirect_to dashboard_pitches_path
	end

  end
	
  def update_task
	@pitch = Pitch.find(params[:pitch_id])
	@task = Task.find(params[:task_id])
	@task.update(task_params)
	if @task.task_type == 'slide' && @task.task_medium
		@task.update(valide: true)
	elsif @task.title && @task.time && @task.title != ''
	  if @task.catchword_list || @task.task_medium
		@task.update(valide: true)
	  elsif @task.valide
		@task.update(valide: false)
	  end
	elsif @task.valide
	  @task.update(valide: false)
	end
	redirect_to dashboard_edit_pitch_path(@pitch, task_id: @task.id)
  end
	
  def copy_task
	@task = Task.find(params[:task_id])
	@pitch = Pitch.find(params[:pitch_id])
	@new_task = @pitch.tasks.create(user: @pitch.user)
	@new_task.update(@task.attributes.except("id", "created_at", "updated_at"))
	redirect_to dashboard_edit_pitch_path(@pitch, task_id: @new_task.id)
  end
	
  def delete_task
	@pitch = Pitch.find(params[:pitch_id])
	@task = Task.find(params[:task_id])
	@task_order = TaskOrder.find_by(pitch: @pitch, task: @task)
	@task_orders = @pitch.task_orders.all.order(:order)
	if @task.pitches.count == 1 && @task.destroy
	  flash[:info] = "Task gelöscht!"
	elsif @task_order.destroy
	  flash[:info] = 'Task aus Pitch entfernt!'
	else
	  flash[:alert] = 'Konnte Task nicht löschen!'
	  redirect_to dashboard_edit_pitch_path(@pitch)
	  return
	end
	i = 1
	@task_orders.each do |to|
	  to.update(order: i)
	  i = i + 1
	end
	redirect_to dashboard_edit_pitch_path(@pitch)
  end
	
  def create_task_media
	@pitch = Pitch.find(params[:task_id])
	@task_medium = TaskMedium.create(media_params)
	if @task_medium.media_type == 'audio'
	  render json: {id: @task_medium.id, type: @task_medium.media_type, preview: @task_medium.audio.url, title: @task_medium.audio.identifier}
	elsif @task_medium.media_type == 'video'
	  min = @task_medium.duration / 60
	  sec = @task_medium.duration % 60
	  sec = '0' + sec.to_s if sec < 10
	  render json: {id: @task_medium.id, preview: @task_medium.video.url, thumb: @task_medium.video.thumb.url, type: @task_medium.media_type, duration: min.to_s + ':' + sec.to_s}
	elsif @task_medium.media_type == 'image'
	  render json: {id: @task_medium.id, preview: @task_medium.image.url, type: @task_medium.media_type}
	elsif @task_medium.media_type == 'pdf'
	  path = @task_medium.pdf.current_path.split('/'+@task_medium.pdf.identifier)[0]
	  images = Docsplit.extract_images( @task_medium.pdf.current_path, :output => path)
	  Dir.chdir(path)
	  Dir.glob("*.png").each do |img|
		task_medium = TaskMedium.create(image: File.open(img), media_type: 'image')
		File.delete(img)
		task = @pitch.tasks.create(user: @pitch.user, task_type: "slide", task_medium: task_medium, valide: true)
	  end
      render json: {id: @task_medium.id, preview: @task_medium.pdf.url, type: @task_medium.media_type}
    end
  end
	
  def create_task_list
	@task = Task.find(params[:task_id])
	@company = @task.user.company
	if params[:type] == 'catchword'
	  if @task.catchword_list
	    @list = @task.catchword_list
	  else
		@list = CatchwordList.create(name: "task_list")
		@task.update(catchword_list_id: @list.id)		  
	  end
	  if params[:list][:name] && params[:list][:name] != ''
	  	@entry = @company.catchwords.find_by(name: params[:list][:name])
	  	@entry = @company.catchwords.create(name: params[:list][:name]) if @entry.nil?
	  	@list.catchwords << @entry if @list.catchwords.find_by(name: params[:list][:name]).nil?
	  elsif params[:list][:list_id]
		@cw = CatchwordList.find(params[:list][:list_id])
		@cw.catchwords.each do |entry|
		  @list.catchwords << entry if @list.catchwords.find_by(name: entry.name).nil?
		end
	  end
	elsif params[:type] == 'objection'
	  if @task.objection_list
		@list = @task.objection_list
	  else
	    @list = ObjectionList.create(name: 'task_list')
		@task.update(objection_list_id: @list.id)
	  end
	  if params[:list][:name] && params[:list][:name] != ''
	  	@entry = @company.objections.find_by(name: params[:list][:name])
	  	@entry = @company.objections.create(name: params[:list][:name]) if @entry.nil?
	  	@list.objections << @entry if @list.objections.find_by(name: params[:list][:name]).nil?
	  elsif params[:list][:list_id]
		@ol = ObjectionList.find(params[:list][:list_id])
		@ol.objections.each do |entry|
		@list.objections << entry if @list.objections.find_by(name: params[:list][:name]).nil?
		end
	  end
	elsif params[:type] == 'rating'
	  if @task.rating_list
		@list = @task.rating_list
	  else
		@list = RatingList.create(name: "task_list")
	    @task.update(rating_list_id: @list.id)
	  end
	  if params[:list][:name] && params[:list][:name] != ''
		if @list.rating_criteria.count < 4
		@entry = RatingCriterium.find_by(name: params[:list][:name])
		@entry = RatingCriterium.create(name: params[:list][:name]) if @entry.nil?
		@list.rating_criteria << @entry if @list.rating_criteria.find_by(name: params[:list][:name]).nil?
		end
	  elsif params[:list][:list_id]
		@rl = RatingList.find(params[:list][:list_id])
		@rl.rating_criteriaeach do |entry|
		@list.rating_criteria << entry if @list.rating_criteria.find_by(name: entry.name).nil?
		end
	  end
	end
	render json: {id: @list.id}
  end
	
  private
  	def pitch_params
		params.require(:pitch).permit(:title, :description, :pitch_sound, :show_ratings, :skip_elections, :video_path, :image, :video, :destroy_image, :destroy_video, :user_id)
	end

    def task_params
	  params.require(:task).permit(:company_id, :department_id, :team_id, :user_id, :task_type, :title, :time, :task_medium_id, :task_slide, :catchwords, :catchword_list_id, :objecitons, :objection_list, :ratings, :rating_list)
	end

	def media_params
	  params.require(:task_medium).permit(:audio, :video, :pdf, :image, :media_type)
	end
end