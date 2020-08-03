class DashboardController < ApplicationController
  before_action :set_user
  before_action :set_company, except: [:choose_company]
  before_action :check_inactive, except: [:choose_company]
  layout "dashboard"

  def choose_company
    @company = @admin.companies.first
    @companies = @admin.companies.order(:name)
  end

  def index
    redirect_to dashboard_pitches_path
  end

  def customize_game
	@game = Game.find(params[:game_id])
	@team = @game.team
	@uCL = @admin.catchword_lists.order('name')
	@cCL = @company.catchword_lists.where.not(user: @admin).order('name')
	@pCL = CatchwordList.where(company_id: nil, user_id: nil, game_id: nil).order('name')
	@uOL = @admin.objection_lists.order('name')
	@cOL = @company.objection_lists.where.not(user: @admin).order('name')
	@pOL = ObjectionList.where(company_id: nil, user_id: nil, game_id: nil).order('name')
	@uRL = @admin.rating_lists.order('name')
	@cRL = @company.rating_lists.where.not(user: @admin).order('name')
	@pRL = RatingList.where(company_id: nil, user_id: nil).order('name')
	@pitches = []
	@admin.games.each do |p|
	  p.game_turns.each do |t|
	  	if t.pitch_video && t.pitch_video.favorite
		  minutes = t.pitch_video.duration / 60
		  minutes = minutes < 10 ? '0' + minutes.to_s : minutes.to_s
		  seconds = t.pitch_video.duration % 60
		  seconds = seconds < 10 ? '0' + seconds.to_s : seconds.to_s
		  rating = t.ges_rating ? t.ges_rating / 10.0 : '?'
		  @pitches << {id: t.pitch_video.id, video: t.pitch_video, duration: minutes + ':' + seconds, word: t.catchword, user: t.user, rating: rating}
	  	end
	  end
	end
  end

  def teams
  @teams = @company.teams.accessible_by(current_ability)
	@team = Team.find(params[:team_id]) if params[:team_id]
  @users_count = @company.users.accessible_by(current_ability).count
	@users = @team.users.accessible_by(current_ability).order('lname') if params[:team_id] && params[:edit] != "true"
  @users = @company.users.accessible_by(current_ability).order('lname') if !@users
	@user = User.find(params[:edit_user]) if params[:edit_user]
  end

  def user_stats
	@user = User.find(params[:user_id])
	if @user.game_turn_ratings.count == 0
	  flash[:alert] = 'Der Spieler hat noch nicht gepitcht!'
    if can? :read, Team
      redirect_to dashboard_teams_path
 	    return
    else
      redirect_to dashboard_path
 	    return
    end
	end
	@user_ratings = []
	@user.user_ratings.each do |r|
	  @user_ratings << {icon: r.rating_criterium.icon, name: r.rating_criterium.name, rating: r.rating, change: r.change, id: r.rating_criterium.id}
	end
	@user_ratings = @user_ratings.sort_by{|e| -e[:name]}
	@days = 1
	@turns = @user.game_turns.order('created_at')
	date = @turns.first.created_at.beginning_of_day
	@chartdata = []
	@turns.each do |t|
	  bod = t.created_at.beginning_of_day
	  if date != bod
		@days += 1
		date = bod
	  end
	end
	@turns = @turns.where.not(ges_rating: nil)
	@turns.each do |t|
	  cust_rating = []
	  if t.game_turn_ratings.count != 0
	    t.game_turn_ratings.each do |tr|
		  cust_rating << {id: tr.rating_criterium.id, name: tr.rating_criterium.name, rating: tr.rating / 10.0}
	    end
	    @chartdata << {date: t.created_at.strftime('%d.%m.%Y'), time: t.created_at.strftime('%H:%M'), ges: t.ges_rating / 10.0, cust_ratings: cust_rating}
	  else
		@turns = @turns.except(t)
	  end
	end
  TeamUser.where(user: @user).each do |t|
    @team = t.team if t.team.company == @company
  end
  if @team
    @team_place = []
    place = 1
    @team.users.sort_by{|e| - e[:ges_rating]}.each do |tu|
      @team_place << {place: place, id: tu.id, name: tu.fname, rating: (tu.ges_rating / 10.0)}
      place = place + 1
    end
    this_user = @team_place.find {|x| x[:id] == @user.id}
    if this_user[:place] == 1
      @first_user = @team_place.find {|x| x[:place] == 1}
      @second_user = @team_place.find {|x| x[:place] == 2}
      @third_user = @team_place.find {|x| x[:place] == 3}
    elsif this_user[:place] == @team_place.size
      @first_user = @team_place.find {|x| x[:place] == this_user[:place] - 2}
      @second_user = @team_place.find {|x| x[:place] == this_user[:place] - 1}
      @third_user = this_user
    else
      @first_user = @team_place.find {|x| x[:place] == this_user[:place] - 1}
      @second_user = this_user
      @third_user = @team_place.find {|x| x[:place] == this_user[:place] + 1}
    end
  end
  end

  def team_stats
	@team = Team.find(params[:team_id])
	if @team.games.count == 0 || @team.users.count == 0
	  flash[:alert] = 'Das Team hat noch keine Spiele'
	  redirect_to dashboard_teams_path
	  return
	end
	@team_ratings = []
	@team.team_ratings.each do |r|
	  sum = 0
	  tcount = 0
	  @team.users.each do |u|
		if u.user_ratings.find_by(rating_criterium: r.rating_criterium)
			sum += u.user_ratings.find_by(rating_criterium: r.rating_criterium).change
			tcount += 1
		end
	  end
	  @team_ratings << {icon: r.rating_criterium.icon, name: r.rating_criterium.name, rating: r.rating, change: sum / tcount / 10.0, id: r.rating_criterium.id}
	end
	@team_ratings = @team_ratings.sort_by{|e| -e[:name]}
	@days = 1
	@games = @team.games.order('created_at')
	date = @games.first.created_at.beginning_of_day
	@chartdata = []
	@games.each do |t|
	  bod = t.created_at.beginning_of_day
	  if date != bod
		@days += 1
		date = bod
	  end
	end
	@games = @games.where.not(ges_rating: nil)
	@games.each do |t|
	  cust_rating = []
	  t.game_ratings.each do |tr|
		cust_rating << {id: tr.rating_criterium.id, name: tr.rating_criterium.name, rating: tr.rating / 10.0,}
	  end
	  @chartdata << {date: t.created_at.strftime('%d.%m.%Y'), time: t.created_at.strftime('%H:%M'), ges: t.ges_rating / 10.0, cust_ratings: cust_rating}
	end
	@turns = @team.game_turns.where.not(ges_rating: nil)
	@team_users = @team.users.sort_by{|e| -e[:ges_rating]}
  end

  def customize
    @folders = @admin.content_folders.where(content_folder: nil)
    @files = @admin.task_media.where(content_folder: nil)
    if params[:folder_id]
      @folder = ContentFolder.find(params[:folder_id])
      @folders = @folder.content_folders
      @files = @folder.task_media.order(:title)
    end
  end

  def account
  end

  def company
  end

  def video
	@pitches = []
	@admin.games.each do |p|
	  p.game_turns.each do |t|
	  	if t.pitch_video
		  minutes = t.pitch_video.duration / 60
		  minutes = minutes < 10 ? '0' + minutes.to_s : minutes.to_s
		  seconds = t.pitch_video.duration % 60
		  seconds = seconds < 10 ? '0' + seconds.to_s : seconds.to_s
		  rating = t.ges_rating ? t.ges_rating / 10.0 : '?'
		  @pitches << {id: t.id, video: t.pitch_video, duration: minutes + ':' + seconds, title: t&.task&.title, user: t.user, rating: rating}
	  	end
	  end
	end
	@videos = @admin.videos
	@videos << @company.videos
  end

  def pitch_video
	@turn = GameTurn.find(params[:turn_id])
	@task = @turn.task
	@ratings = @turn.game_turn_ratings
	@own_ratings = @turn.ratings.where(user: @admin).all
	@video = @turn.pitch_video
	@comments = @turn.comments.where.not(time: nil).order(:time)
  end

  def pitches
	@pitches = @admin.pitches
	@pitch = Pitch.find(params[:pitch_id]) if params[:pitch_id]
	@game = Game.find(params[:game_id]) if params[:game_id]
  @teams = @company.teams.accessible_by(current_ability)
  if @teams.count == 0
    @teams = []
    @admin.team_users.each do |t|
      @teams << t.team if t.team.company == @company
    end
  end
	@team = Team.find(params[:team]) if params[:team]
  end
  def new_pitch
	@pitch = @admin.pitches.create(company: @company)
	redirect_to dashboard_edit_pitch_path(@pitch)
  end

  def edit_pitch
	@pitches = @admin.pitches
	@pitch = Pitch.find(params[:pitch_id])
	if params[:task_id]
		@task = @pitch.tasks.find(params[:task_id])
	else
		@task = @pitch.task_orders.order(:order).first.task if @pitch.task_orders.present?
	end
	@cw_lists = @admin.catchword_lists
	@ol_list = @admin.objection_lists
  end

  def select_task
	@pitch = Pitch.find(params[:pitch_id])
	@task = Task.find(params[:selected_task_id])
	@task_type = @task.task_type
	@admin = current_user
	@cw_lists = @admin.catchword_lists
	@ol_list = @admin.objection_lists
	respond_to do |format|
		format.js { render 'select_task'}
	end
  end

  def update_values
	@task = Task.find(params[:selected_task_id])
	@task.update(params[:type].to_sym => params[:value])
  end

  private
  	def set_user
  	  if user_signed_in?
  		    @admin = current_user
  	  else
  		  flash[:alert] = 'Logge dich ein um dein Dashboard zu sehen!'
  		  redirect_to root_path
  	  end
  	end
    def set_company
      if company_logged_in?
        @company = current_company
        @role = CompanyUser.find_by(user: @admin, company: @company).role
      else
        redirect_to dash_choose_company_path
      end
    end

    def check_inactive
      if company_logged_in? && user_signed_in?
        @company = current_company
        @admin = current_user
        @role = CompanyUser.find_by(user: @admin, company: @company).role
        @company.company_users.where(role: 'inactive_user').each do |u|
          u.destroy
        end
        if @company.company_users.where(role: 'inactive').count != 0
          if @role == 'admin' || @role == 'root'
            @inactive_users = @company.company_users.where(role: 'inactive')
          end
        end
        @company.company_users.where(role: 'inactive_user').each do |cu|
          @user = cu.user
          if @user.company_users.count == 1
            @user.destroy
          else
            cu.destroy
          end
        end
      end
    end
end
