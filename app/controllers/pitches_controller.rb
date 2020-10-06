class PitchesController < ApplicationController
  before_action :set_user, only: [:copy_pitch, :create_task, :update_task, :delete_media, :delete_list, :delete_words, :delete_task, :copy_task, :customize, :create_task_media, :create_task_media_content, :create_task_list, :create_ratings]
  before_action :set_user_ajax, except: [:copy_pitch, :create_task, :update_task, :delete_media, :delete_list, :delete_words, :delete_task, :copy_task, :customize, :create_task_media, :create_task_media_content, :create_task_list, :create_ratings]
  #GET pitches/:pitch_id/tasks/:task_id/setTaskOrder/:order
  def set_task_order
		@pitch = Pitch.where(id: params[:pitch_id]).includes(:task_orders).first
	  @admin = current_user
	  @company = current_company
	  @cw_lists = @company.catchword_lists.accessible_by(current_ability).where.not(name: 'task_list')
	  @ol_list = @company.objection_lists.accessible_by(current_ability).where.not(name: 'task_list')
	  @task_order = TaskOrder.find(params[:task_id])
	  @order = params[:order].to_i
	  @task_orders = @pitch.task_orders.select{|to| to.id != params[:task_id]}
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
  	@task = Task.find(@task_order.task_id)
  	@task_type = @task.task_type
  	respond_to do |format|
  		format.js { render 'dashboard/set_task_order'}
  	end
  end

  def create_task
	  @pitch = Pitch.find(params[:pitch_id])
  	@task = @pitch.tasks.create(company: @pitch.company, user: @pitch.user)
	  redirect_to dashboard_edit_pitch_path(@pitch, task_id: @task.id, selected_card_order_id: params[:selected_card_order_id])
  end

  def update_pitch
	  @pitch = Pitch.find(params[:id])
	  if @pitch.update(title: params[:pitch][:title], description: params[:pitch][:description], user_id: params[:pitch][:user_id])
		  redirect_to dashboard_pitches_path
	  end
  end

  def delete_pitch
    @pitch = Pitch.find(params[:id])
  	@pitch.task_orders.destroy_all
  	if Game.find_by(pitch_id: params[:id])
  		Game.where(pitch_id: params[:id]).update(pitch_id: nil)
  	end
  	@pitch.destroy
  	if params[:url].present?
  		render json: { url: params[:url] }
  	elsif params[:url] == ''
  		render json: { url: dashboard_pitches_path }
  	else
  		redirect_to dashboard_pitches_path
  	end
  end

  def update_task
  	@pitch = Pitch.find(params[:pitch_id])
  	@task = Task.find(params[:task_id])
  	@task.update(task_params)
  	redirect_to dashboard_edit_pitch_path(@pitch, task_id: @task.id)
  end

  def select_task
  	@pitch = Pitch.find(params[:pitch_id])
  	@task = Task.find(params[:task_id])
  	@admin = current_user
  	@cw_lists = @company.catchword_lists.accessible_by(current_ability).where.not(name: 'task_list')
  	@ol_list = @admin.objection_lists.accessible_by(current_ability).where.not(name: 'task_list')
  	respond_to do |format|
  		format.js { render 'dashboard/select_task'}
  	end
  end

  def delete_media
  	@pitch = Pitch.find(params[:pitch_id])
  	@task = Task.find(params[:task_id])
  	unless params[:type].present?
  		if @task.catchword_list_id.present?
  			@task.update(catchword_list_id: nil, task_medium_id: nil)
  		end
  	end
  	@task.update(task_medium_id: nil)
  	if params[:type].present?
  		redirect_to dashboard_edit_pitch_path(@pitch, task_id: @task.id)
  	end
  end

  def delete_list
    @pitch = Pitch.find(params[:pitch_id])
    @task = Task.find(params[:task_id])
    if params[:type] == 'objection'
      @list = ObjectionList.find(params[:list_id])
      @list.objections.each do |entry|
        ObjectionListObjection.find_by(objection: entry, objection_list: @task.objection_list).destroy if ObjectionListObjection.find_by(objection: entry, objection_list: @task.objection_list)
      end
  	else
      @list = CatchwordList.find(params[:list_id])
      @list.catchwords.each do |entry|
        CatchwordListCatchword.find_by(catchword: entry, catchword_list: @task.catchword_list).destroy if CatchwordListCatchword.find_by(catchword: entry, catchword_list: @task.catchword_list)
      end
  	end
  	redirect_to dashboard_edit_pitch_path(@pitch, task_id: @task.id)
  end

  def delete_words
  	@pitch = Pitch.find(params[:pitch_id])
  	@task = Task.find(params[:task_id])
  	if params[:type] == 'objection'
      @entry = @task.objection_list.objections.find_by(id: params[:word_id])
      if @entry
        if @entry.objection_lists.count > 1
          @list = ObjectionListObjection.find_by(objection: @entry, objection_list: @task.objection_list).destroy
        else
          @entry.destroy
        end
      end
  	else
      @entry = @task.catchword_list.catchwords.find_by(id: params[:word_id])
      if @entry
        if @entry.catchword_lists.count > 1
          CatchwordListCatchword.find_by(catchword_list: @task.catchword_list, catchword: @entry).destroy
        elsif GameTurn.where(catchword: @entry).count > 0
          CatchwordListCatchword.find_by(catchword_list: @task.catchword_list, catchword: @entry).destroy
        else
          @entry.destroy
        end
        if @task.catchword_list.catchwords.count == 0
          @task.update(valide: false);
        end
      end
  	end
  	redirect_to dashboard_edit_pitch_path(@pitch, task_id: @task.id)
  end

  def copy_task
  	@task = Task.find(params[:task_id])
  	@pitch = Pitch.find(params[:pitch_id])
  	@new_task = @pitch.tasks.create(company: @pitch.company, user: @pitch.user)
    if @task.catchword_list
      @text = CatchwordList.create(@task.catchword_list.attributes.except('id', "created_at", 'updated_at'))
      @task.catchword_list.catchwords.each do |word|
        @text.catchwords << word
      end
    end
    if @task.objection_list
      @react = ObjectionList.create(@task.objection_list.attributes.except('id', "created_at", 'updated_at'))
      @task.objection_list.objections.each do |text|
        @react.objections << text
      end
    end
    @new_task.catchword_list = @text if @text
    @new_task.objection_list = @react if @react
    if @new_task.save
      @new_task.update(@task.attributes.except("id", "created_at", "updated_at", "catchword_list_id", "objection_list_id"))
    end
  	redirect_to dashboard_edit_pitch_path(@pitch, task_id: @new_task.id, selected_task_id: @task.id, type: params[:type], selected_card_order_id: params[:selected_card_order_id])
  end

  def copy_pitch
  	@pitch = Pitch.find(params[:id])
  	@pitch_clone = @pitch.deep_clone
    @pitch_clone.user = @admin
  	@pitch_clone.save
    @pitch.task_orders.each do |to|
      @task_clone = to.task.deep_clone
      @task_clone.user = @admin
      if to.task.catchword_list
        @list = to.task.catchword_list.deep_clone include: :catchwords
        @list.save
        @task_clone.catchword_list = @list
      end
      if to.task.objection_list
        @list = to.task.objection_list.deep_clone include: :objections
        @list.save
        @task_clone.objection_list = @list
      end
      @task_clone.save
      @pitch_clone.task_orders.create(task: @task_clone, order: to.order)
    end
  	@pitch.deep_clone do |original, kopy|
  		@pitch_clone.update(image: original.image)
  	end
  	redirect_to dashboard_pitches_path
  end

  def delete_task
  	@pitch = Pitch.find(params[:pitch_id])
  	@task = Task.find(params[:task_id])
  	@task_order = TaskOrder.find_by(pitch: @pitch, task: @task)
  	@task_order.destroy
  	@task_orders = @pitch.task_orders.all.order(:order)
    if @task.task_orders.count == 0 && !GameTurn.find_by(task: @task)
      @task.destroy
    end
  	i = 1
  	@task_orders.each do |to|
  	  to.update(order: i)
  	  i = i + 1
  	end
  	redirect_to dashboard_edit_pitch_path(@pitch)
  end

  def delete_task_card
  	@pitch = Pitch.find(params[:pitch_id])
  	@task = Task.find(params[:selected_task_id])
  	@task_order = TaskOrder.find_by(pitch: @pitch, task: @task)
  	@task_order.destroy
    if @task.task_orders.count == 0 && !GameTurn.find_by(task: @task)
      @task.destroy
    end
  	@task_orders = @pitch.task_orders.all.order(:order)
  	@task = @pitch.tasks.first

  	i = 1
  	@task_orders.each do |to|
  	  to.update(order: i)
  	  i = i + 1
  	end
  	@admin = current_user
    @company = @pitch.company
  	@cw_lists = @company.catchword_lists.accessible_by(current_ability)
  	@ol_list = @company.objection_lists.accessible_by(current_ability)
  	@folders = @company.content_folders.accessible_by(current_ability).where(content_folder: nil)
  	@files = @company.task_media.accessible_by(current_ability).where(content_folder: nil)
  	if (@pitch.tasks.count == 0)
  		render json: { url: dashboard_edit_pitch_path(@pitch), count: @pitch.tasks.count }
  	else
      render json: {task: "success"}
  	end
  end

  def customize
  	@pitch = Pitch.find(params[:pitch_id])
  	@game = Game.find(params[:game_id])
  	if @pitch.update(pitch_params)
  		game_login @game
  		redirect_to gd_join_path(@game)
  	else
  		flash[:alert] = 'Konnte game nicht speichern!'
  		redirect_to dashboard_pitches_path(game_id: @game.id, pitch_id: @pitch.id)
  	end
  end

  def create_pitch_media
	  @pitch = Pitch.find(params[:id])
	  @pitch.update(pitch_params)
  end

  def destroy_pitch_media
  	@pitch = Pitch.find(params[:id])
  	@pitch.remove_image!
  	@pitch.save
  end

  def create_task_media
	  @pitch = Pitch.find(params[:pitch_id])
    @company = @pitch.company
    @user = @pitch.user
	  @task_medium = TaskMedium.create(company: @pitch.company, user: @pitch.user)
      @task_medium.update(media_params)
	  if params[:task_id].present?
		  @task = Task.find(params[:task_id])
		  @task.update(task_medium_id: @task_medium.id, catchword_list: nil, task_type: media_params[:media_type])
	  end
	  if @task_medium.media_type == 'audio'
		  redirect_to dashboard_edit_pitch_path(@pitch, task_id: @task.id)
	  elsif @task_medium.media_type == 'video'
	    if params[:videoLink].present?
		    url = params[:videoLink]
		    if params[:videoLink].include?('youtube.com')
  			  id = ''
  			  url = url.gsub(/(>|<)/i,'').split(/(vi\/|v=|\/v\/|youtu\.be\/|\/embed\/)/)
  			  if url[2] != nil
  				  id = url[2].split(/[^0-9a-z_\-]/i)
  				  id = id[0];
  			  else
  				  id = url;
  			  end
  			  @task_medium.update(video_url_id: id, video_url_type: 'youtube', video_img: params[:videoLinkImage], video_title: params[:videoLinkTitle])
		    else
  			  id = url.split('/').last
  			  @task_medium.update(video_url_id: id, video_url_type: 'vimeo', video_img: params[:videoLinkImage], video_title: params[:videoLinkTitle])
		    end
	    else
  	  	min = @task_medium.duration / 60
  	  	sec = @task_medium.duration % 60
  	  	sec = '0' + sec.to_s if sec < 10
	    end
	    redirect_to dashboard_edit_pitch_path(@pitch, task_id: @task.id)
	  elsif @task_medium.media_type == 'image'
	    redirect_to dashboard_edit_pitch_path(@pitch, task_id: @task.id)
	  elsif @task_medium.media_type == 'pdf'
  	  path = @task_medium.pdf.current_path.split('/'+ @task_medium.pdf.identifier)[0]
      @task_pdf = @company.task_pdfs.create(user: @user, name: @task_medium.pdf.identifier)
  	  images = Docsplit.extract_images( @task_medium.pdf.current_path, :output => path)
	  Dir.chdir(path)
	  images_array = []
    if @task_medium.pdf.identifier.split('.').last == 'PDF'
      file_name = @task_medium.pdf.identifier.split('.PDF')
    else
	   file_name = @task_medium.pdf.identifier.split('.pdf')
    end
	  Dir.glob("*.png").length.times { |count| images_array << "#{file_name[0]}_#{count+1}.png"}
	  images_array.each do |img|
    		task_medium = TaskMedium.create(company: @pitch.company, user: @pitch.user, image: File.open(img), media_type: 'image', is_pdf: true, task_pdf: @task_pdf)
    		File.delete(img)
    		task = @pitch.tasks.create(company: @pitch.company, user: @pitch.user, task_type: "slide", task_medium: task_medium, valide: true)
  	  end
  	  @task = @pitch.tasks.last
      @task_medium.destroy
  	  redirect_to dashboard_edit_pitch_path(@pitch, task_id: @task.id)
    end
  end

  def create_task_media_content
  	@pitch = Pitch.find(params[:pitch_id])
  	if params[:task_id].present?
  		@task = @pitch.tasks.find(params[:task_id])
  		if params[:task_medium_id].present?
  			@task.task_medium.update(media_params)
  		else
  			@task_medium = TaskMedium.create(company: @pitch.company, user: @pitch.user)
        		@task_medium.update(media_params)
  			@task.update(task_medium: @task_medium)
  		end
  		if @task.pdf_type == 'video'
  			if params[:videoLink].present?
  				url = params[:videoLink]
  				if params[:videoLink].include?('youtube.com')
  					id = ''
  					url = url.gsub(/(>|<)/i,'').split(/(vi\/|v=|\/v\/|youtu\.be\/|\/embed\/)/)
  					if url[2] != nil
  						id = url[2].split(/[^0-9a-z_\-]/i)
  						id = id[0];
  					else
  						id = url;
  					end
  					@task.task_medium.update(video_url_id: id, video_url_type: 'youtube', video_img: params[:videoLinkImage], video_title: params[:videoLinkTitle])
  				else
  					id = url.split('/').last
  					@task.task_medium.update(video_url_id: id, video_url_type: 'vimeo', video_img: params[:videoLinkImage], video_title: params[:videoLinkTitle])
  				end
  			end
  		end
  	else
      @task_medium = TaskMedium.create(company: @pitch.company, user: @pitch.user)
  		@task_medium.update(media_params)
  		pdf_type = params[:pdf_type] || 'image'
  		@task = @pitch.tasks.create(company: @pitch.company, user: @pitch.user, task_type: "slide", task_medium: @task_medium, valide: true, pdf_type: pdf_type)
  	end
  	if params[:selected_card_order].present?
  		task_orders = TaskOrder.all.where("task_orders.pitch_id = ? and task_orders.order > ?", @pitch.id, params[:selected_card_order]).order(:order)
  		if task_orders.present?
  			set_order_id = task_orders.first.order
  			order = set_order_id + 1
  			task_orders.each do |task_order|
  				task_order.update(order: order)
  				order += 1
  			end
  			task_orders.find_by(task_id: @task.id).update(order: set_order_id)
  		end
  	end
  	redirect_to dashboard_edit_pitch_path(@pitch, task_id: @task.id)
  end

  def task_list_options
  	@task = Task.find(params[:task_id])
  	@pitch = @task.pitches.first
  	@company = current_company
  	@entry = nil
  	objections = []
  	catchwords = []
  	if params[:type] == 'objection'
  		if @task.objection_list
  			@list = @task.objection_list
  		else
  			@list = ObjectionList.create(company: @task.company, user: @task.user, name: 'task_list')
  			@task.update(objection_list_id: @list.id)
  		end

  		if params[:list_id].present?
  			@ol = ObjectionList.find(params[:list_id])
  			objections << @ol.objections
  			@ol.objections.each do |entry|
  				if @list.objections.find_by(name: entry.name).nil?
  					@list.objections << entry
  				end
  			end
  		elsif (params["word"].present? && params["word"] != '')
  			@list_name = params["word"]
  			@entry = @company.objections.find_by(name: @list_name)
  			@entry = @company.objections.create(company: @task.company, user: @task.user, name: @list_name) if @entry.nil?
  			@list.objections << @entry if @list.objections.find_by(name: @list_name).nil?
  		end
  	else
  		if @task.catchword_list
  			@list = @task.catchword_list
  		else
  			@list = CatchwordList.create(company: @task.company, user: @task.user, name: "task_list")
  			@task.update(catchword_list_id: @list.id)
  		end

  		if params[:list_id].present?
  			@cw = CatchwordList.find(params[:list_id])
  			catchwords << @cw.catchwords
  			@cw.catchwords.each do |entry|
  				if @list.catchwords.find_by(name: entry.name).nil?
  					@list.catchwords << entry
  				end
  			end
  		elsif (params["word"].present? && params["word"] != '')
  			@list_name = params["word"]
  			@entry = @company.catchwords.find_by(name: @list_name)
  			@entry = @company.catchwords.create(company: @task.company, user: @task.user, name: @list_name) if @entry.nil?
  			@list.catchwords << @entry if @list.catchwords.find_by(name: @list_name).nil?
  		end
  		@task.update(task_type: 'catchword', task_medium_id: nil)
      @task.update(valide: true) if @task.title && !@task.valide
  	end
  	render json: { task_id: @task.id, pitch_id: @pitch.id, word: params["word"], word_id: @entry&.id, obj_list: objections.present?, obj_type: params[:type] == 'objection', objections: objections, cw_list: catchwords.present?, catchwords: catchwords }

  end

  def create_task_list
  	@task = Task.find(params[:task_id])
  	@pitch = @task.pitches.first
  	@company = current_company
  	if params[:type] == 'catchword'
  	  if @task.catchword_list
  	    @list = @task.catchword_list
  	  else
  		@list = CatchwordList.create(company: @task.company, user: @task.user, name: "task_list")
  		@task.update(catchword_list_id: @list.id, task_medium: nil)
  	  end
  	  if (params[:list][:name] && params[:list][:name] != '') || (params["list-name"].present? && params["list-name"] != '')
  		@list_name = params[:list][:name] || params["list-name"]
  		@entry = @company.catchwords.find_by(name: @list_name)
  	  	@entry = @company.catchwords.create(company: @task.company, user: @task.user, name: @list_name) if @entry.nil?
  	  	@list.catchwords << @entry if @list.catchwords.find_by(name: @list_name).nil?
  	  elsif params[:list][:list_id]
  		@cw = CatchwordList.find(params[:list][:list_id])
  		@cw.catchwords.each do |entry|
  		  if @list.catchwords.find_by(name: entry.name).nil?
  			@list.catchwords << entry
  		  end
  		end
  	  end
  	  @task.update(task_type: 'catchword')
  	elsif params[:type] == 'objection'
  	  if @task.objection_list
  		@list = @task.objection_list
  	  else
  	    @list = ObjectionList.create(company: @task.company, user: @task.user, name: 'task_list')
  		@task.update(objection_list_id: @list.id)
  	  end
  	  if (params[:list][:name] && params[:list][:name] != '') || (params["list-name"].present? && params["list-name"] != '')
  		@list_name = params[:list][:name] || params["list-name"]
  		@entry = @company.objections.find_by(name: @list_name)
  	  	@entry = @company.objections.create(company: @task.company, user: @task.user, name: @list_name) if @entry.nil?
  	  	@list.objections << @entry if @list.objections.find_by(name: @list_name).nil?
  	  elsif params[:list][:list_id]
  		@ol = ObjectionList.find(params[:list][:list_id])
  		@ol.objections.each do |entry|
  		if @list.objections.find_by(name: entry.name).nil?
  			@list.objections << entry
  		end
  		end
  	  end
  	elsif params[:type] == 'rating'
  	  if @task.rating_list
  		@list = @task.rating_list
  	  else
  		@list = RatingList.create(company: @task.company, user: @task.user, name: "task_list")
  	    @task.update(rating_list_id: @list.id)
  	  end
  	  if params[:list][:name] && params[:list][:name] != ''
  		if @list.rating_criteria.count < 4
  		@entry = RatingCriterium.find_by(name: params[:list][:name])
  		@entry = RatingCriterium.create(company: @task.company, user: @task.user, name: params[:list][:name]) if @entry.nil?
  		@list.rating_criteria << @entry if @list.rating_criteria.find_by(name: params[:list][:name]).nil?
  		end
  	  elsif params[:list][:list_id]
  		@rl = RatingList.find(params[:list][:list_id])
  		@rl.rating_criteriaeach do |entry|
  		@list.rating_criteria << entry if @list.rating_criteria.find_by(name: entry.name).nil?
  		end
  	  end
  	end
  	redirect_to dashboard_edit_pitch_path(@pitch, task_id: @task.id)
  end

  def create_ratings
  	@pitch = Pitch.find(params[:pitch_id])
  	@task = Task.find(params[:task_id])
  	if @task.rating_list
  		@list = @task.rating_list
  	else
  		@list = RatingList.create(company: @task.company, user: @task.user, name: "task_list")
  		@task.update(rating_list_id: @list.id)
  	end

  	# Not allowed same values
  	duplicate_values = false
  	ratings = task_params.to_h.values
  	ratings.each do |rating|
  		if rating.present? && ratings.count(rating) > 1
  			duplicate_values = true
  		end
  	end
  	unless duplicate_values
  		[:rating1, :rating2, :rating3, :rating4].each do |rating|
  			if task_params[rating].present?
  				unless @task[rating].present?
  					@list.rating_criteria.create(company: @task.company, user: @task.user, name: task_params[rating])
  				end
  			elsif @task[rating].present?
  				@list.rating_criteria.find_by(name: @task[rating]).destroy
  			end
  		end
  		@task.update(task_params)
  		index = 0
  		[:rating1, :rating2, :rating3, :rating4].each do |rating|
  			if @task[rating].present?
  				@list.rating_criteria[index].update(name: task_params[rating])
  				index += 1
  			end
  		end
  	end

  	redirect_to dashboard_edit_pitch_path(@pitch, task_id: @task.id)
  end

  private
  	def pitch_params
		params.require(:pitch).permit(:title, :description, :pitch_sound, :show_ratings, :skip_elections, :video_path, :image, :video, :skip_rating_timer, :destroy_image, :destroy_video, :user_id)
	end
    def set_user
      if user_signed_in? && company_logged_in?
        @admin = current_user
        @company = current_company
      elsif user_signed_in?
        redirect_to dash_choose_company_path
        return
      else
        flash[:alert] = 'Bitte logge dich ein um dein Dashboard sehen zu können!'
        redirect_to root_path
        return
      end
    end

    def set_user_ajax
      unless user_signed_in?
        flash[:alert] = 'Bitte logge dich ein um dein Dashboard sehen zu können!'
        render js: "window.location = '#{root_path}'"
      end
    end

    def task_params
	  params.require(:task).permit(:company_id, :department_id, :team_id, :user_id, :task_type, :title, :time, :task_medium_id, :task_slide, :catchwords, :catchword_list_id, :objecitons, :objection_list, :ratings, :rating1, :rating2, :rating3, :rating4, :rating_list)
	end

	def media_params
	  params.require(:task_medium).permit(:audio, :video, :pdf, :image, :media_type, :title)
	end
end
