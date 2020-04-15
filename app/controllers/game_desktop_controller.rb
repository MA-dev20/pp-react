class GameDesktopController < ApplicationController
  layout 'game_desktop'
  before_action :check_user
  before_action :check_game, except: [:join]
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
		@game.update(state: 'choose')
	  else
	    @turn.game_turn_ratings.each do |tr|
		  @rating = @user.user_ratings.find_by(rating_criterium: tr.rating_criterium)
		  new_rating = @user.game_turn_ratings.where(rating_criterium: tr.rating_criterium).average(:rating)
		  if @rating
		    old_rating = @rating.rating
		    @rating.update(rating: new_rating, change: new_rating - old_rating)
		  else
		    @user.user_ratings.create(rating_criterium: tr.rating_criterium, rating: new_rating, change: new_rating)
		  end
		end
		new_rating = @user.user_ratings.average(:rating)
		old_rating = @user.ges_rating
		@user.update(ges_rating: new_rating, ges_change: new_rating - old_rating)
		@turn.update(played: true)
		@game.update(state: 'rating')
	  end
	elsif params[:state] == 'ended' && @game.state != "ended"
	  @game.update(state: 'ended')
	  ActionCable.server.broadcast "game_#{@game.id}_channel", game_state: 'changed'
	  redirect_to root_path
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
	  if @state == 'wait' || @state == 'choose' || @state == 'rate'
		@handy = true
	  end
	  if @state == 'ended'
	    redirect_to dashboard_path
	  end
	end
end
