class GamesController < ApplicationController
  before_action :set_company, only: [:create]
  before_action :set_user, except: [:email, :create_game_user, :create_rating, :name, :record_pitch, :upload_pitch, :rating_user]
  before_action :set_game, only: [:customize, :email, :create_game_user, :name, :rating_user]
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
	  game_login @game
	  redirect_to gd_join_path(@game)
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
    @game_user = @game.game_users.find_by(user: @user) if @user
    @company = @game.company
    @admin_role = @company.company_users.find_by(user: @game.user).role
    @ability = Ability.new(@game.user)
    if params[:user][:site] == 'admin_game_mobile'
      if @user && @game_user
        flash[:success] = 'Nutzer hinzugefügt!'
        redirect_to gm_game_path
        return
      elsif @user && @user.fname && @user.lname
        this_cuser = @company.company_users.find_by(user_id: @user.id)
        if this_cuser
          if this_cuser.role == 'inactive'
            this_cuser.update(role: 'active')
          elsif this_cuser.role == 'inactive_user'
            this_cuser.update(role: 'active_user')
          end
        else
          if @ability.can?(:create, User)
            @company.company_users.create(user: @user, role: 'active')
            @company.user_users.create(user: @admin, userID: @user.id)
          else
            @company.company_users.create(user: @user, role: 'active_user')
          end
          @team = @game.team
          @team.users << @user if @team
        end
        @game_user = @game.game_users.create(user: @user, play: true, company: @company)
        if @user.avatar?
          ActionCable.server.broadcast "count_#{@game.id}_channel", count: @game.game_users.where(play: true).count, avatar: @user.avatar.url, state: @game.state, user_id: @user.id
        else
          ActionCable.server.broadcast "count_#{@game.id}_channel", count: @game.game_users.where(play: true).count, name: @user.fname[0].capitalize + @user.lname[0].capitalize, state: @game.state, user_id: @user.id
        end
        flash[:success] = 'Nutzer hinzugefügt!'
        redirect_to gm_game_path
        return
      elsif @user
        redirect_to gm_game_path(email: params[:user][:email])
        return
      else
        @user = User.new(email: params[:user][:email])
        @team = @game.team
        if @user.save(validate: false)
          this_cuser = @company.company_users.find_by(user_id: @user.id)
          if this_cuser
            if this_cuser.role == 'inactive'
              this_cuser.update(role: 'active')
            elsif this_cuser.role == 'inactive_user'
              this_cuser.update(role: 'active_user')
            end
          else
            if @ability.can?(:create, User)
              @company.company_users.create(user: @user, role: 'active')
            else
              @company.company_users.create(user: @user, role: 'active_user')
            end
          end
          @team.users << @user if @team
          redirect_to gm_game_path(email: params[:user][:email])
          return
        else
          flash[:alert] = 'Konnte Nutzer nicht anlegen!'
          redirect_to gm_game_path
        end
      end
    else
      if @user && @game_user
        game_user_login @user
        flash[:success] = 'Erfolgreich beigetreten!'
        redirect_to gm_game_path
        return
      elsif @user && @user.fname && @user.lname
        this_cuser = @company.company_users.find_by(user_id: @user.id)
        if this_cuser
          if this_cuser.role == 'inactive'
            this_cuser.update(role: 'active')
          elsif this_cuser.role == 'inactive_user'
            this_cuser.update(role: 'active_user')
          end
        else
          if @ability.can?(:create, User)
            @company.company_users.create(user: @user, role: 'active')
          else
            @company.company_users.create(user: @user, role: 'active_user')
          end
          @team = @game.team
          @team.users << @user if @team
        end
        game_user_login @user
        redirect_to gm_join_path
        return
      elsif @user
        this_cuser = @company.company_users.find_by(user_id: @user.id)
        if this_cuser
          if this_cuser.role == 'inactive'
            this_cuser.update(role: 'active')
          elsif this_cuser.role == 'inactive_user'
            this_cuser.update(role: 'active_user')
          end
        else
          @company.company_users.create(user: @user, role: 'active') if @admin_role != 'user'
          @company.company_users.create(user: @user, role: 'active_user') if @admin_role == 'user'
          @team = @game.team
          @team.users << @user if @team
        end
        game_user_login @user
        redirect_to gm_new_name_path(@user)
        return
      else
        @user = User.new(email: params[:user][:email])
        @team = @game.team
        if @user.save(validate: false)
          @company.company_users.create(user: @user, role: 'active') if @admin_role != 'user'
          @company.company_users.create(user: @user, role: 'active_user') if @admin_role == 'user'
          @team.users << @user if @team
          game_user_login @user
          redirect_to gm_new_name_path(@user)
          return
        else
          flash[:alert] = 'Konnte Nutzer nicht anlegen!'
          redirect_to gm_login_path
        end
      end
    end
  end

  def name
	  @user = User.find(params[:user_id])
	  password = SecureRandom.urlsafe_base64(8)
	  @user.update(fname: params[:user][:fname], lname: params[:user][:lname], password: password)
    @company = @game.company
    if params[:user][:site] == 'admin_game_mobile'
      @game_user = @game.game_users.find_by(user: @user)
      if !@game_user
        @game_user = @game.game_users.create(user: @user, play: true, company: @company)
        if @user.avatar?
          ActionCable.server.broadcast "count_#{@game.id}_channel", count: @game.game_users.where(play: true).count, avatar: @user.avatar.url, state: @game.state, user_id: @user.id
        else
          ActionCable.server.broadcast "count_#{@game.id}_channel", count: @game.game_users.where(play: true).count, name: @user.fname[0].capitalize + @user.lname[0].capitalize, state: @game.state, user_id: @user.id
        end
      end
      flash[:success] = 'Nutzer hinzugefügt!'
      redirect_to gm_game_path
    else
	    redirect_to gm_join_path
    end
  end
  def create_game_user
    @user = User.find_by(id: params[:user_id])
    @game_user = @game.game_users.find_by(user: @user)
    if @game_user && @game_user.update(play: params[:game_user][:play], active: true)
      if @user.avatar?
        ActionCable.server.broadcast "count_#{@game.id}_channel", count: @game.game_users.where(play: true).count, avatar: @user.avatar.url, state: @game.state, user_id: @user.id
      else
        ActionCable.server.broadcast "count_#{@game.id}_channel", count: @game.game_users.where(play: true).count, name: @user.fname[0].capitalize + @user.lname[0].capitalize, state: @game.state, user_id: @user.id, user_id: @user.id
      end
      redirect_to gm_game_path
  	  return
    else
      @game_user = @game.game_users.new(game_user_params)
      @game_user.company = @company
      @game_user.user = @user
      @game_user.active = true
      if @game_user.save
        if @user.avatar?
          ActionCable.server.broadcast "count_#{@game.id}_channel", count: @game.game_users.where(play: true).count, avatar: @user.avatar.url, state: @game.state, user_id: @user.id
        else
          ActionCable.server.broadcast "count_#{@game.id}_channel", count: @game.game_users.where(play: true).count, name: @user.fname[0].capitalize + @user.lname[0].capitalize, state: @game.state, user_id: @user.id, user_id: @user.id
        end
        redirect_to gm_game_path
    	  return
      else
        flash[:alert] = 'Konnte nicht beitreten!'
    	  redirect_to gm_join_path
    	  return
      end
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
		ActionCable.server.broadcast "game_#{@turn.game.id}_channel", rating: 'added', rating_count: ((@turn.own_ratings.count / @turn.game_turn_ratings.count) + (@turn.ratings.count / @turn.game_turn_ratings.count) ).to_s + ' / ' + (@game.game_users.count).to_s
	  end
	end
	if @turn.game_turn_ratings.count != 0 && (@turn.own_ratings.count / @turn.game_turn_ratings.count) + (@turn.ratings.count / @turn.game_turn_ratings.count) == (@game.game_users.count)
	  redirect_to gm_set_state_path('', state: 'rating')
	else
	  redirect_to gm_game_path
	end
  end

  def create_own_rating
    @turn = GameTurn.find(params[:turn_id])
  	@game = @turn.game
  	@user = current_game_user
  	params[:rating].each do |r|
  	  @rating_criterium = RatingCriterium.find_by(name: r.first)
  	  @rating_criterium = RatingCriterium.create(name: r.first) if !@rating_criterium
  	  @rating = @turn.own_ratings.find_by(rating_criterium: @rating_criterium, user: @user)
  	  if @rating
  	  	@rating.update(rating: r.last)
  	  else
  	  	@rating = @turn.own_ratings.create(rating_criterium: @rating_criterium, user: @user, rating: r.last)
  		ActionCable.server.broadcast "game_#{@turn.game.id}_channel", rating: 'added', rating_count: ( @turn.game_turn_ratings.count != 0 ? ( (@turn.own_ratings.count / @turn.game_turn_ratings.count) + (@turn.ratings.count / @turn.game_turn_ratings.count) ).to_s : '1') + ' / ' + (@game.game_users.count).to_s
  	  end
  	end
  	if @turn.game_turn_ratings.count != 0 && (@turn.own_ratings.count / @turn.game_turn_ratings.count) + (@turn.ratings.count / @turn.game_turn_ratings.count) == (@game.game_users.count)
  	  redirect_to gm_set_state_path('', state: 'rating')
  	else
  	  redirect_to gm_game_path
  	end
  end

  def record_pitch
	@turn = GameTurn.find(params[:turn_id])
	@game = @turn.game
	@task = @game.pitch.task_orders.find_by(order: @game.current_task).task
  @turn.update(task: @task)
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
  @video.company = @turn.game.company
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

  def customize_game
    @game = Game.find(params[:game_id])
    if @game.update(game_params)
      if params[:json] == "true"
        render json: {show_ratings: @game.show_ratings, rating_user: @game.rating_user, skip_rating_timer: @game.skip_rating_timer, game_sound: @game.game_sound}
      else
        game_login @game
        redirect_to gd_join_path(@game)
      end
    else
      flash[:alert] = 'Konnte Spiel nicht speichern!'
      if params[:json] == "true"
        render json: {show_ratings: @game.show_ratings, rating_user: @game.rating_user, skip_rating_timer: @game.skip_rating_timer, game_sound: @game.game_sound}
      else
        redirect_to dashboard_pitches_path(game_id: @game.id, pitch_id: @pitch.id)
      end
    end
  end

  private
	def game_params
	  params.require(:game).permit(:team_id, :password, :show_ratings, :rating_user, :skip_rating_timer, :pitch_id, :game_sound)
	end
	def turn_params
	  params.require(:turn).permit(:play, :record_pitch)
	end
  def game_user_params
	  params.require(:game_user).permit(:play)
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
	  elsif game_user_logged_in?
      @user = current_game_user
    else
	    flash[:alert] = 'Logge dich ein um dein Dashboard zu sehen!'
	    redirect_to root_path
	  end
	end
  def set_company
    if company_logged_in?
      @company = current_company
    else
      flash[:alert] = 'Wähle ein Unternehmen dein Dashboard zu sehen!'
	    redirect_to dash_choose_company_path
    end
  end
end
