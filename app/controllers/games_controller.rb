class GamesController < ApplicationController
  before_action :set_user, except: [:email, :create_turn, :create_rating, :name, :record_pitch, :upload_pitch, :rating_user]
  before_action :set_game, only: [:customize, :email, :create_turn, :name, :rating_user]
  def create
	@game = Game.where(password: game_params[:password], active: true).last
	if @game
	  @games = Game.where(password: game_params[:password], active: true)
	  @games.each do |g|
		if g.created_at <= Date.yesterday
		  g.update(active: false)
		elsif g.game_ratings.count == 0
		  g.update(state: 'wait')
		end
    if g.active
      if g.company == @company
		    @game = g
      else
        flash[:alert] = 'Das Passwort ist schon vergeben!'
    	  redirect_to dashboard_pitches_path('', pitch_id: params[:pitch_id])
    	  return
      end
		end
	  end
	end
	@game.update(game_params) if @game
	@game = @company.games.new(game_params) if !@game
	@game.user = @user
	if @game.save
	#   game_login @game
	#   redirect_to gd_join_path(@game)
	  redirect_to dashboard_pitches_path(game_id: @game.id, pitch_id: params[:game][:pitch_id])
	else
	  redirect_to dashboard_pitches_path('', pitch_id: params[:pitch_id])
	end
  end

  def rating_user
	@game.update(game_params)
	redirect_to gm_game_path
  end

  def email
	  @user = User.find_by(email: params[:user][:email])
    if params[:user][:site] == 'admin_game_mobile'
      if @user && @user.fname && @user.lname
        @turn = @game.game_turns.where(user: @user, play: true, played: false).first
        if !@turn
          @turn = @game.game_turns.create(team: @game.team, user: @user, play: true, played: false)
          ActionCable.server.broadcast "count_#{@game.id}_channel", count: @game.game_turns.where(play: true).count, avatar: @user.avatar.url, state: @game.state, user_id: @user.id
        end
        flash[:success] = 'Nutzer hinzugefügt!'
        redirect_to gm_game_path
      elsif @user
        redirect_to gm_game_path(email: params[:user][:email])
      else
        @user = @company.users.new(email: params[:user][:email], role: 'inactive')
        @team = @game.team
        @teamAll = @game.user.teams.find_by(name: 'all')
        if @user.save(validate: false)
      		@teamAll.users << @user
      		@team.users << @user
          redirect_to gm_game_path(email: params[:user][:email])
        else
          flash[:alert] = 'Konnte dich nicht anlegen!'
          redirect_to gm_game_path
        end
      end
    elsif @user && @user.fname && @user.lname
      if @user.company == @company
        game_user_login @user
        redirect_to gm_join_path
      else
        flash[:alert] = 'Du gehörst nicht zum Unternehmen das gerade spielt!'
        redirect_to gm_error_path
      end
    elsif @user
      if @user.company == @company
        game_user_login @user
        redirect_to gm_new_name_path(@user)
      else
        flash[:alert] = 'Du gehörst nicht zum Unternehmen das gerade spielt!'
        redirect_to gm_error_path
      end
    else
      @user = @company.users.new(email: params[:user][:email], role: 'inactive')
      @team = @game.team
      @teamAll = @game.user.teams.find_by(name: 'all')
      if @user.save(validate: false)
    	  game_user_login @user
    		@teamAll.users << @user
    		@team.users << @user
    	  redirect_to gm_new_name_path(@user)
    	else
    		flash[:alert] = 'Konnte dich nicht anlegen!'
    		redirect_to gm_login_path
    	end
    end
  end

  def name
	  @user = User.find(params[:user_id])
	  password = SecureRandom.urlsafe_base64(8)
	  @user.update(fname: params[:user][:fname], lname: params[:user][:lname], password: password)
    if params[:user][:site] == 'admin_game_mobile'
      @turn = @game.game_turns.where(user: @user, play: true, played: false).first
      if !@turn
        @turn = @game.game_turns.create(team: @game.team, user: @user, play: true, played: false)
        ActionCable.server.broadcast "count_#{@game.id}_channel", count: @game.game_turns.where(play: true).count, avatar: @user.avatar.url, state: @game.state, user_id: @user.id
      end
      flash[:success] = 'Nutzer hinzugefügt!'
      redirect_to gm_game_path
    else
	    redirect_to gm_join_path
    end
  end
  def create_turn
	@user = current_game_user
	@turn = @game.game_turns.where(user: @user, repeat: false).last
	if @turn && @turn.update(turn_params)
	  if @user.avatar?
	    ActionCable.server.broadcast "count_#{@game.id}_channel", count: @game.game_turns.where(play: true).count, avatar: @user.avatar.url, state: @game.state, user_id: @user.id
	  else
		ActionCable.server.broadcast "count_#{@game.id}_channel", count: @game.game_turns.where(play: true).count, name: @user.fname[0].capitalize + @user.lname[0].capitalize, state: @game.state, user_id: @user.id, user_id: @user.id
	  end
	  redirect_to gm_game_path
	  return
	else
	@turn = @game.game_turns.new(turn_params) if !@turn
	@turn.user = @user
	end
	@turn.team = @game.team
	if @turn.save
	  @count = @game.game_turns.where(play: true).count
	  if @user.avatar?
	  ActionCable.server.broadcast "count_#{@game.id}_channel", count: @count, avatar: @user.avatar.url, state: @game.state, user_id: @user.id
	  else
		ActionCable.server.broadcast "count_#{@game.id}_channel", count: @count, name: @user.fname[0].capitalize + @user.lname[0].capitalize, state: @game.state, user_id: @user.id
	  end
	  redirect_to gm_game_path
	  return
	else
	  flash[:alert] = 'Konnte nicht beitreten!'
	  redirect_to gm_join_path
	  return
	end
  end

  def create_rating
	@turn = GameTurn.find(params[:turn_id])
	@game = @turn.game
	@user = current_game_user
	params[:rating].each do |r|
	  @rating_criterium = RatingCriterium.find_by(name: r.first)
	  @rating_criterium = RatingCriterium.create(name: r.first) if !@rating_criterium
	  @rating = @turn.ratings.find_by(rating_criterium: @rating_criterium, user: @user)
	  if @rating
	  	@rating.update(rating: r.last)
	  else
	  	@rating = @turn.ratings.create(rating_criterium: @rating_criterium, user: @user, rating: r.last)
		ActionCable.server.broadcast "game_#{@turn.game.id}_channel", rating: 'added', rating_count: ((@turn.ratings.count / @turn.game_turn_ratings.count).to_s + ' / ' + (@game.game_turns.where(repeat: false).count - 1).to_s)
	  end
	end
	if @turn.game_turn_ratings.count != 0 && (@turn.ratings.count / @turn.game_turn_ratings.count ) == (@game.game_turns.where(repeat: false).count - 1)
	  redirect_to gm_set_state_path('', state: 'rating')
	else
	  redirect_to gm_game_path
	end
  end

  def record_pitch
	@turn = GameTurn.find(params[:turn_id])
	@game = @turn.game
	@task = @game.pitch.task_orders.find_by(order: @game.current_task).task
	if @task.task_type == 'catchword'
	  @turn.update(catchword: @task.catchword_list.catchwords.sample)
	end
	flash[:alert] = 'Konnte Entscheidung nicht speichern!' if !@turn.update(turn_params)
	@turn.game.update(state: "play")
	ActionCable.server.broadcast "game_#{@turn.game.id}_channel", game_state: 'changed'
	redirect_to gm_game_path('', pitch: 'record')
  end

  def upload_pitch
	@turn = GameTurn.find(params[:turn_id])
	@video = PitchVideo.new(video: params[:file])
	@video.user = current_game_user
	@video.game_turn = @turn
	flash[:alert] = 'Konnte Video nicht uploaden!' if !@video.save
	render json: {file: @video.video.url}
  end

  def favorite_pitch
	@turn = GameTurn.find(params[:pitch_id])
	@pitch = @turn.pitch_video
	if @pitch.favorite
	  @pitch.update(favorite: false)
	else
	  @pitch.update(favorite: true)
	end
	render json: {favorite: @pitch.favorite}
  end

  def destroy_pitch
	@video = PitchVideo.find(params[:pitch_id])
	flash[:alert] = 'Konnte Video nicht löschen!' if !@video.destroy
	redirect_to dashboard_video_path
  end

  private
	def game_params
	  params.require(:game).permit(:team_id, :password, :game_seconds, :rating_list_id, :skip_elections, :max_users, :show_ratings, :rating_user, :video_id, :video_is_pitch, :youtube_url, :skip_rating_timer, :pitch_id)
	end
	def turn_params
	  params.require(:turn).permit(:play, :record_pitch)
	end
	def pitch_params
	  params.require(:pitch).permit(:video)
	end

	def set_game
	  @game = Game.find(params[:game_id])
	  @company = @game.company
	end
	def set_user
	  if user_signed_in?
	    @user = current_user
	    @company = @user.company
	  else
	    flash[:alert] = 'Logge dich ein um dein Dashboard zu sehen!'
	    redirect_to root_path
	  end
	end
end
