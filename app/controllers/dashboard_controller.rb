class DashboardController < ApplicationController
  before_action :set_user
  layout "dashboard"

  def index
	@team = Team.find(params[:team]) if params[:team]

	if @admin.ratings.count != 0 && @admin.role == 'user'
	@admin_ratings = []
	@admin.user_ratings.each do |r|
	  @admin_ratings << {icon: r.rating_criterium.icon, name: r.rating_criterium.name, rating: r.rating, change: r.change, id: r.rating_criterium.id}
	end
	@admin_ratings = @admin_ratings.sort_by{|e| -e[:name]}
	@days = 1
	@turns = @admin.game_turns.order('created_at')
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
	    @chartdata << {date: t.created_at.strftime('%d.%m.%Y'), time: t.created_at.strftime('%H:%M'), word: t.catchword.name, ges: t.ges_rating / 10.0, cust_ratings: cust_rating}
	  else
		@turns = @turns.except(t)
	  end
	end
	@team = TeamUser.find_by(user: @admin).team
	@team_users = @team.users.sort_by{|e| - e[:ges_rating]}
	elsif @admin.role == 'user'
	    render 'index'
    end
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
	@team = Team.find(params[:team_id]) if params[:team_id]
	@users = @team.users.order('fname') if params[:team_id] && params[:edit] != "true"
	@users.order('lname')
	@user = User.find(params[:edit_user]) if params[:edit_user]
  end

  def user_stats
	@user = User.find(params[:user_id])
	if @user.ratings.count == 0
	  flash[:alert] = 'Der Spieler hat noch nicht gepitcht!'
	  redirect_to dashboard_teams_path
 	  return
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
	@team = TeamUser.find_by(user: @user).team
	@team_users = @team.users.sort_by{|e| - e[:ges_rating]}
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
	@CLs = @admin.catchword_lists.order('name')
	@CL = CatchwordList.find_by(id: params[:CL]) if params[:CL]
	@OLs = @admin.objection_lists.order('name')
	@OL = ObjectionList.find_by(id: params[:OL]) if params[:OL]
	@RLs = @admin.rating_lists.order('name')
	@RL = RatingList.find_by(id: params[:RL]) if params[:RL]
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
	@ratings = @turn.game_turn_ratings
	@own_ratings = @turn.ratings.where(user: @admin).all
	@video = @turn.pitch_video
	@comments = @turn.comments.where.not(time: nil).order(:time)
  end

  def pitches
	@pitches = @admin.pitches
	@pitch = Pitch.find(params[:pitch_id]) if params[:pitch_id]
	@game = Game.find(params[:game_id]) if params[:game_id]
	@team = Team.find(params[:team]) if params[:team]
  end
  def new_pitch
	@pitch = @admin.pitches.create()
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
		@company = @admin.company
		@department = @admin.department
		@teamAll = @admin.teams.find_by(name: 'all') if @admin.role != "user"
		@teams = @admin.teams.where.not(name: 'all').order('name') if @admin.role != "user"
		@users = @teamAll.users.order('fname') if @admin.role != "user"
	  else
		flash[:alert] = 'Logge dich ein um dein Dashboard zu sehen!'
		redirect_to root_path
	  end
	end
end
