class GamesController < ApplicationController
  before_action :set_user, except: [:email, :create_turn, :create_rating, :name, :record_pitch, :upload_pitch, :rating_user]
  before_action :set_game, only: [:customize, :email, :create_turn, :name, :rating_user]
  def create
	@game = @company.games.where(password: game_params[:password], state: 'wait', active: true).first
	@game.update(game_params) if @game
	@game = @company.games.new(game_params) if !@game
	@game.user = @user
	if @game.save
	  redirect_to dashboard_customize_game_path(@game)
	else
	  redirect_to dashboard_path('', team: game_params[:team_id])
	end
  end
	
  def rating_user
	@game.update(game_params)
	redirect_to gm_game_path
  end
	
  def customize
	if @game.update(game_params)
	  @CL = params[:game][:word_list] if params[:game][:word_list]
	  if !@CL && CatchwordList.find_by(name: 'Peters Catchwords').nil?
		flash[:alert] = 'Bitte Lade erst Catchworte hoch!'
		redirect_to backoffice_path
		return
	  end
	  @CL = [CatchwordList.find_by(name: 'Peters Catchwords').id] if !@CL
	  build_catchwords(@game, @CL)
	  @OL = params[:game][:objection_list] if params[:game][:objection_list]
	  if !@OL && ObjectionList.find_by(name: 'Peters Objections').nil?
		flash[:alert] = 'Bitte Lade erst Objections hoch!'
		redirect_to backoffice_path
		return
	  end
	  @OL = [ObjectionList.find_by(name: 'Peters Objections').id] if !@OL
	  build_objections(@game, @OL)
	  if !game_params[:rating_list_id] && RatingList.find_by(name: 'Peters Scores').nil?
		flash[:alert] = 'Bitte Lade erst Ratings hoch!'
		redirect_to backoffice_path
		return  
	  else
	    @game.update(rating_list_id: RatingList.find_by(name: 'Peters Scores').id) if !game_params[:rating_list_id]
	  end
	  game_login @game
	  redirect_to gd_join_path(@game)
	else
	  flash[:alert] = 'Konnte game nicht speichern!'
	  redirect_to dashboard_customize_game_path(@game)
	end
  end
	
  def email
	@user = User.find_by(email: params[:user][:email])
	if @user && @user.company == @company && @user.role == 'user'
	  game_user_login @user
	  redirect_to gm_join_path
	elsif @user && @user.company == @company && @user.role != 'user'
	  game_user_login @user
	  redirect_to gm_join_path
	elsif @user
	  flash[:alert] = 'Du gehörst nicht zum Unternehmen das gerade spielt!'
	  redirect_to gm_error_path
	else
	  @user = @company.users.new(email: params[:user][:email])
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
	UserMailer.after_create(@user, password).deliver
	redirect_to gm_join_path
  end
  def create_turn
	@user = current_game_user
	@turn = @game.game_turns.find_by(user: @user)
	if @turn && @turn.update(turn_params)
	  ActionCable.server.broadcast "count_#{@game.id}_channel", count: @game.game_turns.where(play: true).count, avatar: @user.avatar.url, state: @game.state
	  redirect_to gm_game_path
	elsif @game.catchword_list.nil?
	  flash[:alert] = 'Bitte warte bis das Spiel gestartet wurde!'
	  redirect_to gm_join_path
	else
	@turn = @game.game_turns.new(turn_params) if !@turn
	@turn.user = @user
	@catchwords = @game.catchword_list.catchwords.order("RANDOM()").map{ |c| c.id }
	@game.game_turns.each do |t|
	  @catchwords.delete(t.catchword_id)
	end
	if @catchwords.length != 0
	@turn.catchword_id = @catchwords.first
	else
	@turn.catchword = @game.catchword_list.catchwords.order("RANDOM()").first
	end
	@turn.team = @game.team
	if @turn.save
	  @count = @game.game_turns.where(play: true).count
	  ActionCable.server.broadcast "count_#{@game.id}_channel", count: @count, avatar: @user.avatar.url, state: @game.state
	  redirect_to gm_game_path
	else
	  flash[:alert] = 'Konnte nicht beitreten!'
	  redirect_to gm_join_path
	end
	end
  end
	
  def create_rating
	@turn = GameTurn.find(params[:turn_id])
	@game = @turn.game
	@user = current_game_user
	params[:rating].each do |r|
	  @rating = @turn.ratings.find_by(rating_criterium_id: r.first, user: @user)
	  if @rating
	  	@rating.update(rating: r.last) if @rating
	  else
	  	@rating = @turn.ratings.create(rating_criterium_id: r.first, user: @user, rating: r.last)
		ActionCable.server.broadcast "game_#{@turn.game.id}_channel", rating: 'added', rating_count: ((@turn.ratings.count / @turn.game_turn_ratings.count).to_s + ' / ' + (@game.game_turns.count - 1).to_s)
	  end
	end
	if @turn.game_turn_ratings.count != 0 && (@turn.ratings.count / @turn.game_turn_ratings.count ) == (@game.game_turns.count - 1)
	  redirect_to gm_set_state_path('', state: 'rating')
	else	  
	  redirect_to gm_game_path
	end
  end
	
  def record_pitch
	@turn = GameTurn.find(params[:turn_id])
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

  def destroy_pitch
	@video = PitchVideo.find(params[:pitch_id])
	flash[:alert] = 'Konnte Video nicht löschen!' if !@video.destroy
	redirect_to dashboard_video_path
  end
	
  private
	def game_params
	  params.require(:game).permit(:team_id, :password, :game_seconds, :rating_list_id, :skip_elections, :max_users, :show_ratings, :rating_user, :video_id, :video_is_pitch, :youtube_url)
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
