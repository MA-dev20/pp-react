class GameMobileController < ApplicationController
  before_action :check_game, except: [:welcome, :ended, :error]
  before_action :check_user, only: [:game, :join, :choosen, :new_name, :repeat, :send_emoji]
  before_action :check_state, only: [:game]
 
  def error
  end
	
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
	@task = @turn.task if @turn
	@task = @pitch.tasks.first(@game.game_turns.where(played: true).count + 1).last if !@task
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
	
  def set_state
    if params[:state] == 'wait'
      @game.update(state: "wait") if @game.state != 'wait'
      redirect_to gm_game_path
	  return
	elsif params[:state] == 'slide' && params[:slide]
	  @task = @pitch.task_orders.find_by(order: params[:slide])
	  if @game.state != 'choose' && @game.state != 'turn'
	  if @task && @task.task.task_type == 'slide'
		@game.update(current_task: params[:slide], state: 'slide')
		redirect_to gm_game_path
	    return
	  else
	    redirect_to gm_set_state_path('', state: 'choose')
		return
	  end
	  end
	  redirect_to gm_game_path
	  return
    elsif params[:state] == 'choose'
      @turns = @game.game_turns.playable
      @task = @pitch.task_orders.find_by(order: @game.current_task + 1)
	  if @task.nil?
		redirect_to gm_set_state_path('', state: 'bestlist')
		return
	  elsif @turns.count == 0
		redirect_to gm_set_state_path('', state: 'turn')
		return
	  #if @turns.count == 0
	    #redirect_to gm_set_state_path('', state: 'bestlist')
		#return
      #elsif @game.game_turns.where(played: true).count == @game.max_users && @game.max_users != 0
     #   redirect_to gm_set_state_path('', state: 'bestlist')
	#	return
      elsif @pitch.skip_elections || @turns.count == 1
        redirect_to gm_set_state_path('', state: 'turn')
		return
      elsif @game.state != 'choose'
        @turns = @turns.sample(2)
        @game.update(state: "choose", turn1: @turns.first.id, turn2: @turns.last.id, current_task: @game.current_task + 1)
      end
	  
      redirect_to gm_game_path
	  return
    elsif params[:state] == 'turn'
      @turns = @game.game_turns.playable
      @turn = GameTurn.find_by(id: @game.current_turn)
	  @task = @pitch.task_orders.find_by(order: @game.current_task + 1).task
      if @turn && @turn.played == false
		@turn.update(task: @task) if @turn.task.nil?
        @game.update(state: "turn", turn1: nil, turn2: nil, current_task: @game.current_task + 1) if @game.state != 'turn'
	  elsif @turn || @turns.count == 0
		@turn.update(task: @task)
        @game.update(state: "turn", turn1: nil, turn2: nil, current_task: @game.current_task + 1) if @game.state != 'turn'
      elsif @pitch.skip_elections || @turns.count == 1
        @game.update(state: 'turn', turn1: nil, turn2: nil, current_turn: @turns.first.id, current_task: @game.current_task + 1) if @game.state != 'turn'
      elsif @game.state != 'turn'
        @turn1 = GameTurn.find(@game.turn1)
        @turn2 = GameTurn.find(@game.turn2)
        if @turn1.counter > @turn2.counter
		  @turn1.update(task: @task) if @turn1.task.nil?
          @game.update(state: 'turn', current_turn: @turn1.id, current_task: @game.current_task + 1)
        else
		  @turn2.update(task: @task) if @turn2.task.nil?
          @game.update(state: 'turn', current_turn: @turn2.id, current_task: @game.current_task + 1)
        end
        @turn1.update(counter: 0)
        @turn2.update(counter: 0)
      end
      redirect_to gm_game_path
	  return
    elsif params[:state] == 'play'
      @game.update(state: 'play', turn1: nil, turn2: nil) if @game.state != 'play'
      redirect_to gm_game_path
	  return
    elsif params[:state] == 'rate'
      if @game.game_turns.count == 1
        @game.game_turns.first.update(ges_rating: nil, played: true)
		@game.update(active: false)
		redirect_to gm_set_state_path('', state: 'slide', slide: @game.current_task + 1)
		return
      elsif @pitch.show_ratings == 'skip'
        @turn = GameTurn.find(@game.current_turn)
		@turn.update(ges_rating: nil, played: true)
		redirect_to gm_set_state_path('', state: 'slide', slide: @game.current_task + 1)
		return
      elsif @game.state != "rate"
        @game.update(state: 'rate')
      end
	  redirect_to gm_game_path
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
          redirect_to gm_set_state_path('', state: 'slide', slide: @game.current_task + 1)
          return
        elsif @pitch.show_ratings == 'none'
          @turn.update(played: true)
          redirect_to gm_set_state_path('', state: 'slide', slide: @game.current_task + 1)
          return
        elsif @pitch.show_ratings == 'one' && @turn_ratings.count == 0
          @turn.update(played: true)
          redirect_to gm_set_state_path('', state: 'slide', slide: @game.current_task + 1)
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
        @game.update(state: 'bestlist')
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
		  if @game.game_turns.find_by(user: @admin)
			redirect_to gm_game_path
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
