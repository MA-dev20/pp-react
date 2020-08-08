class BackofficeController < ApplicationController
  before_action :check_user, :check_company
  before_action :set_company
  layout 'backoffice'

  def index
  end

  def companies
	@companies = Company.where(activated: true)
	@unactivated_companies = Company.where(activated: false)

	@company = Company.find(params[:company_id]) if params[:company_id]
  if @company
    @teams = @company.teams.all
    @team = Team.find_by(id: params[:team]) if params[:team]
    if @team && !params[:edit_team]
      @users = @team.users.order('fname')
      @users.order('lname') if @users
    else
      @users = @company.users.order('fname')
      @users.order('lname') if @users
    end
  end
  @user = @company.users.find_by(id: params[:edit_user]) if params[:edit_user]
  end

  def company
    @teams = @company.teams.order(:name)
    @team = Team.find_by(id: params[:team]) if params[:team]
    @users = @team.users.order("lname") if @team
    @users = @company.users.order("lname") if !@users
    @user = @company.users.find_by(id: params[:edit_user]) if params[:edit_user]
    @company_user = @company.company_users.find_by(user_id: params[:edit_user]) if params[:edit_user]

    @pitches = @company.pitches.order(:title)
    @pitch = Pitch.find_by(id: params[:pitch]) if params[:pitch]
    @task_order = @pitch.task_orders.order(:order) if @pitch
    @tasks = @company.tasks.order(:title)

    @task = Task.find_by(id: params[:content]) if params[:content]
    @medium = @task.task_medium if @task
    @media = @company.task_media.order(:media_type) if !@medium

    if params[:abilities] == 'user'
      @user_abilities = @company.user_abilities.find_by(role: 'user')
      @user_abilities = UserAbility.find_by(name: 'Standard', role: 'user') if !@user_abilities
      @user_abilities = UserAbility.create(name: 'Standard', role: 'user') if !@user_abilities
    end
    if params[:abilities] == 'admin'
      @user_abilities = @company.user_abilities.find_by(role: 'admin')
      @user_abilities = UserAbility.find_by(name: 'Standard', role: 'admin') if !@user_abilities
      @user_abilities = UserAbility.create(name: 'Standard', role: 'admin') if !@user_abilities
    end
    if params[:abilities] == 'root'
      @user_abilities = @company.user_abilities.find_by(role: 'root')
      @user_abilities = UserAbility.find_by(name: 'Standard', role: 'root') if !@user_abilities
      @user_abilities = UserAbility.create(name: 'Standard', role: 'root') if !@user_abilities
    end
  end

  def company_content
    @folders = @company.content_folders.where(content_folder: nil)
    @files = @company.task_media.where(content_folder: nil).where.not(media_type: "pdf_image")
    @lists = []
    @company.catchword_lists.where(content_folder: nil).where.not(name: 'task_list').each do |cl|
      entry = {type: 'catchword', id: cl.id, name: cl.name, author: cl.user, count: cl.catchwords.count}
      @lists << entry
    end
    @company.objection_lists.where(content_folder: nil).where.not(name: 'task_list').each do |ol|
      entry = {type: 'objection', id: ol.id, name: ol.name, user_name: ol.user.fname[0] + '. ' + ol.user.lname}
      @lists << entry
    end
    if params[:folder_id]
      @folder = ContentFolder.find(params[:folder_id])
      @folders = @folder.content_folders
      @files = @folder.task_media.where.not(media_type: "pdf_image")
      @lists = []
      @folder.catchword_lists.where.not(name: 'task_list').each do |cl|
        entry = {type: 'catchwords', name: cl.name, author: cl.user, count: cl.catchwords.count}
        @lists << entry
      end
      @folder.objection_lists.where.not(name: 'task_list').each do |ol|
        entry = {type: 'objections', name: ol.name, user_name: ol.user.fname[0] + '. ' + ol.user.lname}
        @lists << entry
      end
    end

    if params[:audio]
      @content = TaskMedium.find(params[:audio])
    elsif params[:image]
      @content = TaskMedium.find(params[:image])
    elsif params[:pdf]
      @content = TaskMedium.find(params[:pdf])
    elsif params[:video]
      @content = TaskMedium.find(params[:video])
    elsif params[:catchword]
      @liste = CatchwordList.find(params[:catchword])
    elsif params[:objection]
      @liste = ObjectionList.find(params[:objection])
    end
  end

  def company_teams
    @teams = @company.teams
    @users = @company.users
    if params[:team]
      @team = Team.find(params[:team])
      @users = @team.users
    end
  end

  def search_content
    if params[:search] && params[:search] != ''
      @files = []
      @company.task_media.search(params[:search]).each do |file|
        if file.media_type == 'video' && file.video?
          @file = {id: file.id, type: "video", thumb: file.video.thumb.url, title: file.title, duration: (file.duration / 60).to_s + ':' + (file.duration % 60).to_s, author: file.user.fname[0] + '. ' + file.user.lname}
          @files << @file
        elsif file.media_type == 'image' && file.image?
          @file = {id: file.id, type: "image", thumb: file.image.url, title: file.title, author: file.user.fname[0] + '. ' + file.user.lname}
          @files << @file
        elsif file.media_type == 'audio' && file.audio?
          @file = {id: file.id, type: "audio", title: file.title, duration: (file.duration / 60).to_s + ':' + (file.duration % 60).to_s, author: file.user.fname[0] + '. ' + file.user.lname}
          @files << @file
        end
      end
      @folders = []
      @company.content_folders.search(params[:search]).each do |folder|
        @folder = {id: folder.id, title: folder.name, author: folder.user.fname[0] + '. ' + folder.user.lname }
        @folders << @folder
      end
      @lists = []
      @company.catchword_lists.where.not(name: 'task_list').search(params[:search]).each do |cl|
        @lists << {id: cl.id, name: cl.name, entries: cl.catchwords.count, type: 'catchword', user_name: (cl.user.fname[0] + '. ' + cl.user.lname)}
      end
      @company.objection_lists.where.not(name: 'task_list').search(params[:search]).each do |ol|
        @lists << {id: ol.id, name: ol.name, entries: ol.objections.count, type: 'objection', user_name: (ol.user.fname[0] + '. ' + ol.user.lname)}
      end
    else
      @folders = []
      @files = []
      @lists = []
      @company.content_folders.where(content_folder: nil).each do |folder|
        @folder = {id: folder.id, title: folder.name, author: folder.user.fname[0] + '. ' + folder.user.lname }
        @folders << @folder
      end
      @company.task_media.where(content_folder: nil).each do |file|
        if file.media_type == 'video' && file.video?
          @file = {id: file.id, type: "video", thumb: file.video.thumb.url, title: file.title, duration: (file.duration / 60).to_s + ':' + (file.duration % 60).to_s, author: file.user.fname[0] + '. ' + file.user.lname}
          @files << @file
        elsif file.media_type == 'image' && file.image?
          @file = {id: file.id, type: "image", thumb: file.image.url, title: file.title, author: file.user.fname[0] + '. ' + file.user.lname}
          @files << @file
        elsif file.media_type == 'audio' && file.audio?
          @file = {id: file.id, type: "audio", title: file.title, duration: (file.duration / 60).to_s + ':' + (file.duration % 60).to_s, author: file.user.fname[0] + '. ' + file.user.lname}
          @files << @file
        end
      end
      @company.catchword_lists.where(content_folder: nil).where.not(name: 'task_list').each do |cl|
        entry = {type: 'catchwords', name: cl.name, author: cl.user, count: cl.catchwords.count}
        @lists << entry
      end
      @company.objection_lists.where(content_folder: nil).where.not(name: 'task_list').each do |ol|
        entry = {type: 'objections', name: ol.name, user_name: ol.user.fname[0] + '. ' + ol.user.lname}
        @lists << entry
      end
    end
    render json: {folders: @folders, files: @files, lists: @lists}
  end


  def abilities
    if params[:type] && params[:abilities]
      @user_abilities = UserAbility.find_by(name: params[:type] + '_abilities', role: params[:abilities])
      @user_abilities = UserAbility.create(name: params[:type] + '_abilities', role: params[:abilities]) if !@user_abilities
    end
  end

  private
	def set_company
	  @company = Company.find(params[:company_id]) if params[:company_id]
	end
    def check_company
      if company_logged_in?
        @root_company = current_company
      else
        redirect_to dash_choose_company_path
      end
    end
    def check_user
	  if user_signed_in?
		@root = current_user
		if @root.bo_role != 'root'
		  flash[:alert] = 'Dir fehlen die Berechtigungen für diese Seite!'
		  redirect_to dashboard_path
		end
	  else
		flash[:alert] = 'Logge dich ein um dein Dashboard zu sehen!'
		redirect_to root_path
	  end
	end
end
