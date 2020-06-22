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
	@order = @pitch.task_orders
	@turn1 = GameTurn.find(@game.turn1) if @game.turn1
	@turn2 = GameTurn.find(@game.turn2) if @game.turn2
	@turn = GameTurn.find(@game.current_turn) if @game.current_turn
	@task = @pitch.task_orders.find_by(order: @game.current_task).task if @game.current_task != 0 && !@game.current_task.nil?
	if @turn && @pitch.show_ratings == 'all'
	  @turn_ratings = @turn.game_turn_ratings.all
	  @ges_rating = @turn.ges_rating
	elsif @turn && @pitch.show_ratings == 'one'
	  @rat_user = @game.rating_user
	  @turn_ratings = @turn.ratings.where(user_id: @rat_user).all
	  @ges_rating = @turn.ratings.where(user_id: @rat_user).average(:rating)
	end
	@turns = @game.game_turns.where(play: true).where.not(ges_rating: nil).order(ges_rating: :desc)
	if @pitch.show_ratings == 'one'
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
    if params[:state] == 'wait'
      @game.update(state: "wait") if @game.state != 'wait'
      redirect_to gd_game_path
	  return
	elsif params[:state] == 'slide' && params[:slide]
	  @task_order = @pitch.task_orders.find_by(order: params[:slide])
	  if @task_order && @task_order.task.task_type == 'slide'
		@game.update(current_task: params[:slide], state: 'slide')
		redirect_to gd_game_path
	  elsif @task_order
		@turns = @game.game_turns.playable
		if @pitch.skip_elections || @turns.count == 1
		  redirect_to gd_set_state_path(slide: params[:slide], state: 'turn')
		  return
		elsif @turns.count > 1
		  redirect_to gd_set_state_path(slide: params[:slide], state: 'choose')
		  return
		else
		  @turns = @game.game_turns.where(play: true, played: true)
		  @turns.each do |t|
			  @turn = GameTurn.create(game: @game, user: t.user, team: t.team, play: true, played: false)
			  t.update(played: false, play: false, repeat: true)
		  end
		  redirect_to gd_set_state_path(state: 'slide',slide: params[:slide])
		  return
		end
	  else
		redirect_to gd_set_state_path(state: 'bestlist')
	  end
    elsif params[:state] == 'choose'
      @turns = @game.game_turns.playable.sample(2)
	  @task = @pitch.task_orders.find_by(order: params[:slide])
      @game.update(state: "choose", turn1: @turns.first.id, turn2: @turns.last.id, current_task: params[:slide]) if @game.state != 'choose'
      redirect_to gd_game_path
	  return
    elsif params[:state] == 'turn'
      @turns = @game.game_turns.playable
	  if @pitch.skip_elections || @turns.count == 1
		@task_order = @pitch.task_orders.find_by(order: params[:slide])
		@turn = @turns.first
		@turn.update(task: @task_order.task)
		@game.update(state: 'turn', current_turn: @turn.id, current_task: params[:slide])
	  elsif @turns.count > 1
		  @task = @pitch.task_orders.find_by(order: @game.current_task).task
		  @turn1 = GameTurn.find(@game.turn1)
		  @turn2 = GameTurn.find(@game.turn2)
		  if @turn1.counter > @turn2.counter
			 @turn1.update(task: @task)
			 @game.update(state: 'turn', current_turn: @turn1.id)
		  elsif @turn1.counter < @turn2.counter
			@turn2.update(task: @task)
		    @game.update(state: 'turn', current_turn: @turn2.id)
		  end
	  end
      redirect_to gd_game_path
	  return
    elsif params[:state] == 'play'
	  @task = @pitch.task_orders.find_by(order: @game.current_task)
	  if @task.task.task_type == 'catchword'
		@turn.update(catchword: @task.catchword_list.catchwords.sample)
	  end
      @game.update(state: 'play', turn1: nil, turn2: nil) if @game.state != 'play'
      redirect_to gd_game_path
	  return
    elsif params[:state] == 'rate'
	  @turn = GameTurn.find(@game.current_turn)
	  @task = @turn.task
	  if @task.rating_list.nil?
		@turn.update(ges_rating: nil, played: true)
		redirect_to gd_set_state_path('', state: 'slide', slide: @game.current_task + 1)
		return
      elsif @pitch.show_ratings == 'skip' || @turn.ratings.count == 0 || @game.game_turns.where(user_id: @game.game_turns.first.user_id).count == @game.game_turns.count
		@turn.update(ges_rating: nil, played: true)
		redirect_to gd_set_state_path('', state: 'slide', slide: @game.current_task + 1)
		return
      elsif @game.state != "rate"
        @game.update(state: 'rate')
      end
	  redirect_to gd_game_path
      return
    elsif params[:state] == 'rating'
      @game.update(active: false) if @game.game_turns.playable.count <= 1
      @turn = GameTurn.find_by(id: @game.current_turn)
      if @turn
        @turns = @game.game_turns.where(user_id: @turn.user_id)
        if @turns.count != 1 && @turns.find_by(ges_rating: @turns.maximum("ges_rating")) != @turn
          @bestturn = @turns.find_by(ges_rating: @turns.maximum("ges_rating"))
          @bestturn.update(play: true)
          @turn.update(play: false)
        end
        if @turn.game_turn_ratings.count == 0
          @turn.update(ges_rating: nil, played: true)
          redirect_to gd_set_state_path('', state: 'slide', slide: @game.current_task + 1)
          return
        elsif @pitch.show_ratings == 'none'
          @turn.update(played: true)
          redirect_to gd_set_state_path('', state: 'slide', slide: @game.current_task + 1)
          return
        elsif @pitch.show_ratings == 'one' && @turn_ratings.count == 0
          @turn.update(played: true)
          redirect_to gd_set_state_path('', state: 'slide', slide: @game.current_task + 1)
          return
        elsif  @game.state != 'rating'
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
      redirect_to gd_game_path
      return
    elsif params[:state] == 'bestlist'
      if @game.state != 'bestlist'
        @game.game_turns.playable.each do |gt|
          gt.update(ges_rating: nil)
        end
        @turns = @game.game_turns.where(play: true).all
        @turns = @turns.where.not(ges_rating: nil).order(ges_rating: :desc)
        place = 1
        @turns.each do |t|
          t.update(place: place)
          place += 1
        end
        @game.update(state: 'bestlist')
      end
      redirect_to gd_game_path
      return
    elsif params[:state] == 'repeat'
      if @game.state != 'repeat' && @game.state != 'wait'
        @game.update(state: 'repeat')
		game_old = @game
		temp = Game.where(password: @game.password, state: 'wait', active: true).first
		temp = Game.create(company: @game.company, user: @game.user, team: @game.team, state: 'wait', active: true, password: @game.password, pitch: @game.pitch, rating_user: @game.rating_user) if @temp.nil?
		game_login temp
      end
	  redirect_to gd_game_path
	  return
    elsif params[:state] == 'ended'
	  @game.update(state: 'ended') if @game.state != "ended"
	  redirect_to gd_game_path
	  return
	end
  end
  private
	def check_game
	  if game_logged_in?
		@game = current_game
		@pitch = @game.pitch
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
