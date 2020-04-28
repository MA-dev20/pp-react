class GameMobileController < ApplicationController
  before_action :check_game, except: [:welcome, :ended]
  before_action :check_user, only: [:game, :join, :choosen, :new_name, :repeat, :send_emoji]
  before_action :check_state, only: [:game]
	
  def welcome
	@game = Game.where(password: params[:password], active: true, state: 'wait').first
	if @game
	  @company = @game.company
	  game_login @game
	else
	  flash[:alert] = 'Konnte keinen passenden Pitch finden!'
	  redirect_to root_path
	end
  end
	
  def login
  end
	
  def join
  end
	
  def game
	@omenu = false
	@turn1 = GameTurn.find(@game.turn1) if @game.turn1
	@turn2 = GameTurn.find(@game.turn2) if @game.turn2
	@turn = GameTurn.find(@game.current_turn) if @game.current_turn
	render @state
  end
	
  def choosen
	if @game.state != 'choose'
	  redirect_to gm_game_path
	end
	@turn = GameTurn.find(params[:turn])
	@turn.update(counter: @turn.counter + 1)
	if @turn.id == @game.turn1
	  ActionCable.server.broadcast "count_#{@game.id}_channel", choose: true, avatar: @admin.avatar.url, site: 'left'
	else
	  ActionCable.server.broadcast "count_#{@game.id}_channel", choose: true, avatar: @admin.avatar.url, site: 'right'
	end
  end
	
  def upload_pitch
	@turn = GameTurn.find(params[:turn_id])
  end
	
  def ended
	if game_logged_in?
	  @game = current_game
	  @company = @game.company
	  game_logout
	  game_user_logout
	else
	  redirect_to root_path
	end
  end
	
  def repeat
	@game = current_game
	redirect_to gm_join_path if @admin == @game.user
  end
	
  def new_name
  end
	
  def set_timer
	if params[:timer] == 'start'
	  ActionCable.server.broadcast "game_#{@game.id}_channel", comment_timer: 'start'
	elsif params[:timer] == 'stop'
	  ActionCable.server.broadcast "game_#{@game.id}_channel", comment_timer: 'stop'
	end
  end
	
  def send_emoji
	ActionCable.server.broadcast "count_#{@game.id}_channel", emoji: true, emoji_icon: params[:emoji], user_avatar: @admin.avatar.url
  end
	
  def set_state
	if params[:state] == "choose" && @game.state != "choose"
	  if @game.game_turns.playable.count == 0 || (@game.game_turns.where(played: true).count == @game.max_users && @game.max_users != 0)
		@game.game_turns.playable.each do |gt|
		  gt.update(ges_rating: nil)
		end
		@turns = @game.game_turns.where.not(ges_rating: nil).order(ges_rating: :desc)
	    place = 1
	    @turns.each do |t|
		  t.update(place: place)
		  place += 1
	    end
		@game.update(state: 'bestlist')
	  elsif (@game.game_turns.where(played: true).count == (@game.max_users - 1) && @game.max_users != 0) || @game.game_turns.playable.count == 1
		@game.update(state: 'turn', current_turn: @game.game_turns.playable.first.id, active: false)
	  else
        @turns = @game.game_turns.playable.sample(2)
	  	if @game.skip_elections
			@game.update(state: 'turn', turn1: nil, turn2: nil, current_turn: @turns.first.id, active: false)		
		else  
			@game.update(state: 'choose', turn1: @turns.first.id, turn2: @turns.last.id)
		end
		@turns = @game.game_turns.where.not(ges_rating: nil).order(ges_rating: :desc)
	    place = 1
	    @turns.each do |t|
		  t.update(place: place)
		  place += 1
	    end
	  end
	elsif params[:state] == 'turn' && @game.state != "turn"
	  @turn1 = GameTurn.find(@game.turn1) if @game.turn1
	  @turn2 = GameTurn.find(@game.turn2) if @game.turn2
	  if @turn1.counter > @turn2.counter
		  @turn1.update(counter: 0)
		  @turn2.update(counter: 0)
		  @game.update(state: 'turn', current_turn: @turn1.id)
	  else
		  @turn1.update(counter: 0)
		  @turn2.update(counter: 0)
		  @game.update(state: 'turn', current_turn: @turn2.id)
	  end
	elsif params[:state] == 'rate' && @game.state != 'rate'
	  if @game.game_turns.count == 1
		@game.update(state: 'ended')
		@game.game_turns.first.update(ges_rating: nil, played: true)
	  	ActionCable.server.broadcast "game_#{@game.id}_channel", game_state: 'changed'
	  	redirect_to gm_ended_path
	  	return
	  else
		@game.update(state: 'rate')
	  end
	elsif params[:state] == 'rating' && @game.state != "rating"
	  @turn = GameTurn.find(@game.current_turn)
	  @user = @turn.user
	  if @turn.game_turn_ratings.count == 0
	    @turn.update(ges_rating: nil, played: true)
	    if @game.game_turns.playable.count >= 2
          @turns = @game.game_turns.playable.sample(2)
	  	  @game.update(state: 'choose', turn1: @turns.first.id, turn2: @turns.last.id)
	  	elsif @game.game_turns.playable.count == 1
		  @game.update(state: 'turn', current_turn: @game.game_turns.playable.first.id, active: false)
	    else
		  @turns = @game.game_turns.where.not(ges_rating: nil).order(ges_rating: :desc)
	      place = 1
	      @turns.each do |t|
		    t.update(place: place)
		    place += 1
	      end
		  @game.update(state: 'bestlist')
	    end
	  else
	    @turn.game_turn_ratings.each do |tr|
		  @rating = @user.user_ratings.find_by(rating_criterium: tr.rating_criterium)
		  new_rating = @user.game_turn_ratings.where(rating_criterium: tr.rating_criterium).average(:rating).round
		  if @rating
		    old_rating = @rating.rating
		    @rating.update(rating: new_rating, change: new_rating - old_rating)
		  else
		    @user.user_ratings.create(rating_criterium: tr.rating_criterium, rating: new_rating, change: new_rating)
		  end
		end
		new_rating = @user.user_ratings.average(:rating).round
		old_rating = @user.ges_rating
		@user.update(ges_rating: new_rating, ges_change: new_rating - old_rating)
		@turn.update(played: true)
		@game.update(state: 'rating')
	  end
	elsif params[:state] == 'repeat' && @game.state != "repeat"
	  @game.update(state: 'repeat')
	  @game_old = @game
	  ActionCable.server.broadcast "game_#{@game.id}_channel", game_state: 'changed'
	  temp = Game.where(password: @game.password, state: 'wait', active: true).first
	  temp = Game.create(company: @game.company, user: @game.user, team: @game.team, state: 'wait', password: @game.password, game_seconds: @game.game_seconds, video_id: @game.video_id, youtube_url: @game.youtube_url, video_is_pitch: @game.video_is_pitch, rating_list: @game.rating_list, skip_elections: @game.skip_elections, max_users: @game.max_users) if temp.nil?
	  build_catchwords(temp, [@game_old.catchword_list.id])
	  build_objections(temp, [@game_old.objection_list.id])
	  game_login temp
	  redirect_to gm_join_path
	  return
	elsif params[:state] == 'ended' && @game.state != "ended"
	  @game.update(state: 'ended')
	  ActionCable.server.broadcast "game_#{@game.id}_channel", game_state: 'changed'
	  redirect_to gm_ended_path
	  return
	else
	  @game.update(state: params[:state])
	end
	ActionCable.server.broadcast "game_#{@game.id}_channel", game_state: 'changed'
    redirect_to gm_game_path
  end
	
  def objection
	@objection = Objection.find(params[:objection])
	ActionCable.server.broadcast "count_#{@game.id}_channel", objection: true, objection_text: @objection.name, objection_sound: @objection.sound? ? @objection.sound.url : ""
  end

  private
	def check_game
	  if game_logged_in?
		@game = current_game
		@company = @game.company
	  else
		flash[:alert] = "Bitte trete dem Spiel zuerst bei!"
		redirect_to root_path
	  end
	end
	def check_user
	  if game_user_logged_in?
		@admin = current_game_user
		@company = @admin.company
	  else
		flash[:alert] = "Bitte logge dich ein um einem Spiel beizutreten!"
		redirect_to root_path
	  end
	end
	
	def check_state
	  @state = @game.state
	  @turn = GameTurn.find(@game.current_turn) if @game.current_turn
	  if @state == 'repeat'
		temp = Game.where(password: @game.password, state: 'wait', active: true).first
		game_login temp
		redirect_to gm_repeat_path
	  elsif @state == 'ended'
		redirect_to gm_ended_path
	  end
	end
end
