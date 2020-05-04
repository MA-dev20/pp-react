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
	if @turn && @game.show_ratings == 'all'
	  @turn_ratings = @turn.game_turn_ratings.all
	  @ges_rating = @turn.ges_rating
	elsif @turn && @game.show_ratings == 'one'
	  @rat_user = @game.rating_user
	  @turn_ratings = @turn.ratings.where(user_id: @rat_user).all
	  @ges_rating = @turn.ratings.where(user_id: @rat_user).average(:rating)
	end
	@turns = @game.game_turns.where.not(ges_rating: nil).all.order(ges_rating: :desc)
	if @game.show_ratings == 'one'
	  @rat_user = @game.rating_user
	  @turns = @turns.sort_by{ |e| -(e.ratings.where(user_id: @rat_user).count != 0 ? e.ratings.where(user_id: @rat_user).average(:rating) : 0) }
	end
	render @state
  end
	
  def repeat
  end
	
  def ended
	game_logout
	redirect_to dashboard_path
  end
	
  def set_state
	if params[:state] == 'intro' && @game.state != 'intro'
	  @game.update(state: "intro")
	end
	if params[:state] == 'choose' && @game.state != 'choose'
	  @turns = @game.game_turns.playable
	  if @turns.count == 0 || (@game.game_turns.where(played: true).count == @game.max_users && @game.max_users != 0)
		redirect_to gm_set_state_path('', state: 'bestlist')
		return
	  elsif @game.skip_elections || @turns.count == 1
		redirect_to gm_set_state_path('', state: 'turn')
		return
	  else
		@turns = @turns.sample(2)
		@game.update(state: 'choose', turn1: @turns.first.id, turn2: @turns.last.id)
	  end
	end
	if params[:state] == "turn" && @game.state != 'turn'
	  @turns = @game.game_turns.playable.all
	  if @game.skip_elections || @turns.count == 1
		@game.update(state: 'turn', turn1: nil, turn2: nil, current_turn: @turns.first.id)
	  else
	    @turn1 = GameTurn.find(@game.turn1)
	    @turn2 = GameTurn.find(@game.turn2)
		if @turn1.counter > @turn2.counter
		  @turn1.update(counter: 0)
		  @turn2.update(counter: 0)
		  @game.update(state: 'turn', current_turn: @turn1.id)
	    else
		  @turn1.update(counter: 0)
		  @turn2.update(counter: 0)
		  @game.update(state: 'turn', current_turn: @turn2.id)
	    end
	  end
	end
	if params[:state] == 'play' && @game.state != 'play'
		@game.update(state: 'play', turn1: nil, turn2: nil)
	end
	if params[:state] == 'rate' && @game.state != 'rate'
	  if @game.game_turns.count == 1
		@game.game_turns.first.update(ges_rating: nil, played: true)
		@game.update(active: false)
		redirect_to gd_set_state_path('', state: 'ended')
		return
	  else
		@game.update(state: 'rate')
	  end
	end
    if params[:state] == 'rating' && @game.state != 'rating'
	  if @game.game_turns.playable.count <= 1
		@game.update(active: false)
	  end
	  @turn = GameTurn.find(@game.current_turn)
	  if @turn
	    @turn_ratings = @turn.ratings.where(user: @game.rating_user) if @game.rating_user
	    if @turn.game_turn_ratings.count == 0
		  @turn.update(ges_rating: nil, played: true)
		  redirect_to gd_set_state_path(state: 'choose')
		  return
		elsif @turn && @game.show_ratings == 'none'
		  @turn.update(played: true)
		  redirect_to gd_set_state_path(state: 'choose')
		  return
		elsif @turn && (@game.show_ratings == 'one' && @turn_ratings.count == 0)
		  @turn.update(played: true)
		  redirect_to gd_set_state_path(state: 'choose')
		  return
		else
		  @user = @turn.user
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
	  end
	end
	if params[:state] == 'bestlist' && @game.state != 'bestlist'
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
	end
	if params[:state] == 'repeat' && (@game.state != "repeat" && @game.state != 'wait')
	  @game.update(state: 'repeat')
	  @game_old = @game
	  temp = Game.where(password: @game.password, state: 'wait', active: true).first
	  temp = Game.create(company: @game.company, user: @game.user, team: @game.team, state: 'wait', password: @game.password, game_seconds: @game.game_seconds, video_id: @game.video_id, youtube_url: @game.youtube_url, video_is_pitch: @game.video_is_pitch, rating_list: @game.rating_list, skip_elections: @game.skip_elections, max_users: @game.max_users, show_ratings: @game.show_ratings, rating_user: @game.rating_user) if temp.nil?
	  build_catchwords(temp, [@game_old.catchword_list.id])
	  build_objections(temp, [@game_old.objection_list.id])
	  game_login temp
	  redirect_to gd_join_path
	  return
	end
	if params[:state] == 'ended' && @game.state != "ended"
	  @game.update(state: 'ended')
	  redirect_to gd_ended_path
	  return
	end
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
