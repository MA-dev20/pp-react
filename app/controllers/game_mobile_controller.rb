class GameMobileController < ApplicationController
  before_action :check_game, except: [:welcome, :ended, :error]
  before_action :check_user, only: [:game, :join, :choosen, :new_name, :repeat, :send_emoji]
  before_action :check_state, only: [:game]
  before_action :check_entered, only: [:game]
 
  def error
  end
	
  def welcome
	@game = Game.where(password: params[:password], active: true).last
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
	@turn1 = GameTurn.find_by(id: @game.turn1) if @game.turn1
	@turn2 = GameTurn.find_by(id: @game.turn2) if @game.turn2
	@turn = GameTurn.find_by(id: @game.current_turn) if @game.current_turn
	@task = @pitch.task_orders.find_by(order: @game.current_task).task if @game.current_task != 0 && !@game.current_task.nil?
	render @state
  end
	
  def choosen
	if @game.state != 'choose'
	  redirect_to gm_game_path
	end
	@turn = GameTurn.find(params[:turn])
	@turn.update(counter: @turn.counter + 1)
	if @turn.id == @game.turn1
	  if @admin.avatar?
	  ActionCable.server.broadcast "count_#{@game.id}_channel", choose: true, avatar: @admin.avatar.url, site: 'left'
	  else
	  ActionCable.server.broadcast "count_#{@game.id}_channel", choose: true, name: @admin.fname[0].capitalize + @admin.lname[0].capitalize, site: 'left'
	  end
	else
	  if @admin.avatar?
	  ActionCable.server.broadcast "count_#{@game.id}_channel", choose: true, avatar: @admin.avatar.url, site: 'right'
	  else
	  ActionCable.server.broadcast "count_#{@game.id}_channel", choose: true, name: @admin.fname[0].capitalize + @admin.lname[0].capitalize, site: 'right'
	  end
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
	if @admin.avatar?
		ActionCable.server.broadcast "count_#{@game.id}_channel", emoji: true, emoji_icon: params[:emoji], user_avatar: @admin.avatar.url
	else
		ActionCable.server.broadcast "count_#{@game.id}_channel", emoji: true, emoji_icon: params[:emoji], name: @admin.fname[0].capitalize + @admin.lname[0].capitalize
	end
  end
	
  def repeat_turn
	@turn = GameTurn.find(@game.current_turn)
    @game.game_turns.where(user: @turn.user).each do |t|
        t.update(played: false, play: false, repeat: true)
    end
	@new_turn = GameTurn.create(game: @game, user: @turn.user, team: @turn.team, task: @turn.task, play: true, played: false)
	@game.update(current_turn: @new_turn.id)
	redirect_to gm_set_state_path('', state: 'turn')
  end
	
  def delete_turn
	@turn = GameTurn.find(params[:turn_id])
	if @turn.id == @game.current_turn
	  flash[:alert] = 'der Nutzer ist gerade dran!'
	else
	  @turn.destroy
	end
	redirect_to gm_game_path
  end
	
  def set_current
	@turn = GameTurn.find(params[:turn_id])
	if @game.state == 'choose'
	  @game.update(current_turn: @turn.id)
	  redirect_to gm_set_state_path(state: 'turn')
	  return
	elsif @game.state == 'play'
	  flash[:alert] = 'Warte bis der aktuelle Pitch durch ist!'
	  redirect_to gm_game_path
	  return
	else
	  @game.update(current_turn: @turn.id)
	  redirect_to gm_game_path
	  return
	end
  end
	
  def set_slide
	@task_order = @pitch.task_orders.find_by(order: params[:slide])
	if @task_order
	  @game.update(current_task: params[:slide])
	  if @game.state == 'slide' && @task_order.task.task_type == 'slide'
		ActionCable.server.broadcast "game_#{@game.id}_channel", game_state: 'changed'
		redirect_to gm_game_path
		return
	  elsif @task_order.task.task_type == 'slide'
	    redirect_to gm_set_state_path(state: 'slide')
		return
	  else
		redirect_to gm_set_state_path(state: 'choose')
		return
	  end
	else
	  redirect_to gm_set_state_path(state: 'bestlist')
	end
  end
  def set_state
    if params[:state] == 'wait'
      @game.update(state: "wait") if @game.state != 'wait'
      redirect_to gm_game_path
	  return
	elsif params[:state] == 'slide'
	  @game.update(state: 'slide')
	  redirect_to gm_game_path
    elsif params[:state] == 'choose'
      @turn = GameTurn.find_by(id: @game.current_turn)
	  if @turn && !@turn.played && @turn.play
		redirect_to gm_set_state_path(state: 'turn')
		return
	  else
		@turns = @game.game_turns.playable
		if @turns.count == 0
		  @turns = @game.game_turns.where(play: true, played: true)
		  @turns.each do |t|
			  @turn = GameTurn.create(game: @game, user: t.user, team: t.team, play: true, played: false)
			  t.update(played: false, play: false, repeat: true)
		  end
		  redirect_to gd_set_state_path(state: 'choose')
		  return
		elsif @turns.count == 1
		 redirect_to gm_set_state_path(state: 'turn')
		 return
		else
          @turns = @game.game_turns.playable.sample(2)
	      @task = @pitch.task_orders.find_by(order: @game.current_task)
          @game.update(state: "choose", turn1: @turns.first.id, turn2: @turns.last.id, current_turn: nil) if @game.state != 'choose'
		  redirect_to gm_game_path
	      return
	   end
	 end
    elsif params[:state] == 'turn'
      @turns = @game.game_turns.playable
	  @turn = GameTurn.find_by(id: @game.current_turn)
	  @task = @pitch.task_orders.find_by(order: @game.current_task).task
	  if @turn && !@turn.played && @turn.play && @game.state != 'turn'
		@turn.update(task: @task)
		@game.update(state: 'turn', current_turn: @turn.id)
	  elsif @pitch.skip_elections || @turns.count == 1
		@turn = @turns.first
		@turn.update(task: @task)
		@game.update(state: 'turn', current_turn: @turn.id)
	  elsif @turns.count > 1
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
      redirect_to gm_game_path
	  return
    elsif params[:state] == 'play'
	  @task = @pitch.task_orders.find_by(order: @game.current_task).task
	  if @task.task_type == 'catchword'
		@turn.update(catchword: @task.catchword_list.catchwords.sample)
	  end
      @game.update(state: 'play', turn1: nil, turn2: nil) if @game.state != 'play'
      redirect_to gm_game_path
	  return
    elsif params[:state] == 'rate'
	  @turn = GameTurn.find_by(id: @game.current_turn)
	  if @turn	  
	    @task = @turn.task
	    if @task.rating_list.nil?
		  @turn.update(ges_rating: nil, played: true)
		  redirect_to gm_set_slide_path(@game.current_task + 1)
		  return
		elsif @pitch.show_ratings == 'skip' || @turn.ratings.count == 0 || @game.game_turns.where(user_id: @game.game_turns.first.user_id).count == @game.game_turns.count
		  @turn.update(ges_rating: nil, played: true)
		  redirect_to gm_set_slide_path(@game.current_task + 1)
		  return
		elsif @game.state != "rate"
		  @game.update(state: 'rate')
		end
		redirect_to gm_game_path
	    return
	  else
		redirect_to gm_game_path
		return
	  end
    elsif params[:state] == 'rating'
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
          redirect_to gm_set_slide_path(@game.current_task + 1)
          return
        elsif @pitch.show_ratings == 'none'
          @turn.update(played: true)
          redirect_to gm_set_slide_path(@game.current_task + 1)
          return
        elsif @pitch.show_ratings == 'one' && @turn_ratings.count == 0
          @turn.update(played: true)
          redirect_to gm_set_slide_path(@game.current_task + 1)
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
      redirect_to gm_game_path
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
        @game.update(state: 'bestlist', active: false)
      end
      redirect_to gm_game_path
      return
    elsif params[:state] == 'repeat'
      if @game.state != 'repeat' && @game.state != 'wait'
        @game.update(state: 'repeat')
		game_old = @game
		temp = Game.where(password: @game.password, state: 'wait', active: true).first
		temp = Game.create(company: @game.company, user: @game.user, team: @game.team, state: 'wait', active: true, password: @game.password, pitch: @game.pitch, rating_user: @game.rating_user) if @temp.nil?
		game_login temp
      end
	  redirect_to gm_game_path
	  return
    elsif params[:state] == 'ended'
	  @game.update(state: 'ended') if @game.state != "ended"
	  redirect_to gm_game_path
	  return
	end
  end
	
  def objection
	@objection = Objection.find_by(name: params[:objection])
	if @objection
	ActionCable.server.broadcast "count_#{@game.id}_channel", objection: true, objection_text: @objection.name, objection_sound: @objection.sound? ? @objection.sound.url : ""
	else
	  ActionCable.server.broadcast "count_#{@game.id}_channel", objection: true, objection_text: params[:objection], objection_sound: ""
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
	def check_entered
	  if game_logged_in?
		@game = current_game
		if game_user_logged_in?
		  @admin = current_game_user
		  if !@game.game_turns.find_by(user: @admin)
			game_logout
	  	  	game_user_logout
		  	flash[:alert] = 'Bitte trete dem Spiel erneut bei!'
		  	redirect_to root_path
		  end
		end
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
	  @turn = GameTurn.find_by(id: @game.current_turn) if @game.current_turn
	  if @state == 'repeat'
		temp = Game.where(password: @game.password, state: 'wait', active: true).first
		game_login temp
		redirect_to gm_repeat_path
	  elsif @state == 'ended'
		redirect_to gm_ended_path
	  end
	end
end
