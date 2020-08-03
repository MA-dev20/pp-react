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

  def catchwords
	CatchwordList.create(name: 'Peters Catchwords') if CatchwordList.find_by(name: 'Peters Catchwords').nil?
	@lists = @company.catchword_lists if @company
	@list = CatchwordList.find(params[:list_id]) if params[:list_id]
	@lists = CatchwordList.where(company_id: nil, game_id: nil) if !@lists
	@list = @lists.first if @lists.count != 0 && !@list
  end
  def objections
	ObjectionList.create(name: 'Peters Objections') if ObjectionList.find_by(name: 'Peters Objections').nil?
	@lists = @company.objection_lists if @company
	@list = ObjectionList.find(params[:list_id]) if params[:list_id]
	@lists = ObjectionList.where(company_id: nil, game_id: nil) if !@lists
	@list = @lists.first if @lists.count != 0 && !@list
  end
  def ratings
	RatingList.create(name: 'Peters Scores') if RatingList.find_by(name: 'Peters Scores').nil?
	@lists = @company.rating_lists if @company
	@list = RatingList.find(params[:list_id]) if params[:list_id]
	@lists = RatingList.where(company_id: nil) if !@lists
	@list = @lists.first if @lists.count != 0 && !@list
  end

  def abilities
    @user_abilities = UserAbility.find_by(name: 'Standard', role: 'user')
    @user_abilities = UserAbility.create(name: 'Standard', role: 'user') if !@user_abilities
    @admin_abilities = UserAbility.find_by(name: 'Standard', role: 'admin')
    @admin_abilities = UserAbility.create(name: 'Standard', role: 'admin', view_team: "user", create_team: 'user', edit_team: 'user', share_team: 'user', view_user: 'team', create_user: 'team', edit_user: 'team', share_user: 'team', view_stats: 'team', view_pitch: 'team', create_pitch: "team", edit_pitch: 'team', share_pitch: 'team', view_task: 'team', create_task: 'team', edit_task: 'team', share_task: 'team', view_media: 'team', create_media: 'team', edit_media: 'team', share_media: "team") if !@admin_abilities
    @root_abilities = UserAbility.find_by(name: 'Standard', role: 'root')
    @root_abilities = UserAbility.create(name: 'Standard', role: 'root', edit_company: true, view_department: 'company', create_department: 'company', edit_department: 'company', view_team: "user", create_team: 'user', edit_team: 'user', share_team: 'user', view_user: 'team', create_user: 'team', edit_user: 'team', share_user: 'team', view_stats: 'team', view_pitch: 'team', create_pitch: "team", edit_pitch: 'team', share_pitch: 'team', view_task: 'team', create_task: 'team', edit_task: 'team', share_task: 'team', view_media: 'team', create_media: 'team', edit_media: 'team', share_media: "team") if !@root_abilities
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
