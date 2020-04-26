class GameDesktopController < ApplicationController
  layout 'game_desktop'
  before_action :check_user
  before_action :check_game, except: [:join, :ended]
  before_action :check_state, only: [:game]
	
  def join
	@game = Game.find(params[:game_id])
	game_login @game
	redirect_to gd_game_path
  end
	
  def game
	@turn1 = GameTurn.find(@game.turn1) if @game.turn1
	@turn2 = GameTurn.find(@game.turn2) if @game.turn2
	@turn = GameTurn.find(@game.current_turn) if @game.current_turn
	@turn_ratings = @turn.game_turn_ratings if @turn
	@turns = @game.game_turns.where.not(ges_rating: nil).all.order(ges_rating: :desc)
	render @state
  end
	
  def repeat
  end
	
  def ended
	game_logout
	redirect_to dashboard_path
  end
	
  def set_state
	if params[:state] == "choose" && @game.state != "choose"
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
		@game.update(state: 'ended', ges_rating: nil)
		@game.game_turns.first.update(ges_rating: nil, played: true)
	  	ActionCable.server.broadcast "game_#{@game.id}_channel", game_state: 'changed'
	  	redirect_to gd_ended_path
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
	elsif params[:state] == 'ended' && @game.state != "ended"
	  @game.update(state: 'ended')
	  ActionCable.server.broadcast "game_#{@game.id}_channel", game_state: 'changed'
	  redirect_to gd_ended_path
	  return
	elsif params[:state] == 'repeat' && @game.state != "repeat"
	  @game.update(state: 'repeat')
	  ActionCable.server.broadcast "game_#{@game.id}_channel", game_state: 'changed'
	  temp = Game.where(password: @game.password, state: 'wait', active: true).first
	  temp = Game.create(company: @game.company, user: @game.user, team: @game.team, state: 'wait', password: @game.password, game_seconds: @game.game_seconds, video_id: @game.video_id, youtube_url: @game.youtube_url, video_is_pitch: @game.video_is_pitch, rating_list: @game.rating_list) if temp.nil?
	  build_objections(temp, [@game.objection_list.id]) if temp.objection_list.nil?
	  build_catchwords(temp, [@game.catchword_list.id]) if temp.catchword_list.nil?
	  game_login temp
	  redirect_to gd_game_path
	  return 
	else
	  @game.update(state: params[:state])
	end
	ActionCable.server.broadcast "game_#{@game.id}_channel", game_state: 'changed'
    redirect_to gd_game_path
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
	  if user_signed_in?
		@admin = current_user
		@company = @admin.company
	  else
		flash[:alert] = "Bitte logge dich ein um einem Spiel beizutreten!"
		redirect_to root_path
	  end
	end
	def check_state
	  @state = @game.state
	  if @state == 'repeat'
		temp = Game.where(password: @game.password, state: 'wait', active: true).first
		game_login temp
		redirect_to gd_game_path
	  elsif @state == 'ended'
	    redirect_to gd_ended_path
	  end
	end
end
