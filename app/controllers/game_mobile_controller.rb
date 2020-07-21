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
  @turn = @game.game_turns.find_by(task: @task) if !@turn
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

  def logout
    @user = User.find(params[:turn_id])
    @turns = @game.game_turns.where(user: @user)
    @turns.each do |t|
      if t.played || t.id == @game.current_turn
        t.update(repeat: true)
      else
        t.destroy
      end
    end
    if @game.state == 'wait'
      ActionCable.server.broadcast "count_#{@game.id}_channel", remove: true, count: @game.game_turns.where(play: true).count, user_id: @user.id, state: @game.state
    end
    game_logout
    game_user_logout
    flash[:alert] = 'Du bist dem Spiel ausgetreten!'
    redirect_to root_path
    return
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
    if params[:emoji]
	    if @admin.avatar?
		    ActionCable.server.broadcast "count_#{@game.id}_channel", emoji: true, emoji_icon: params[:emoji], user_avatar: @admin.avatar.url
	    else
		    ActionCable.server.broadcast "count_#{@game.id}_channel", emoji: true, emoji_icon: params[:emoji], name: @admin.fname[0].capitalize + @admin.lname[0].capitalize
	    end
    elsif params[:comment]
      if @admin.avatar?
  	  	ActionCable.server.broadcast "count_#{@game.id}_channel", hide: true, comment: true, comment_text: params[:comment], comment_user_avatar: @admin.avatar.url, reverse: true
  	  else
  		  ActionCable.server.broadcast "count_#{@game.id}_channel", hide: true, comment: true, comment_text: params[:comment], name: @admin.fname[0].capitalize + @admin.lname[0].capitalize, reverse: true
  	  end
    elsif params[:emoji_comment]
      if @admin.avatar?
  	  	ActionCable.server.broadcast "count_#{@game.id}_channel", hide: true, emoji: true, emoji_icon: params[:emoji_comment], user_avatar: @admin.avatar.url, reverse: true
  	  else
        ActionCable.server.broadcast "count_#{@game.id}_channel", hide: true, emoji: true, emoji_icon: params[:emoji_comment], name: @admin.fname[0].capitalize + @admin.lname[0].capitalize, reverse: true
  	  end
    end
  end

  def repeat_turn
	@turn = @game.game_turns.find_by(id: @game.current_turn) if @game.current_turn
  @turn = @game.game_turns.find_by(task_id: @game.current_task) if !@turn
    @game.game_turns.where(task: @turn.task, user: @turn.user).each do |t|
        t.update(played: true, play: false, repeat: true)
    end
	@new_turn = GameTurn.create(game: @game, user: @turn.user, team: @turn.team, task: @turn.task, play: true, played: false)
	redirect_to gm_set_state_path('', state: 'turn')
  end

  def delete_turn
    @game_user = @game.game_users.find_by(id: params[:turn_id])
    if @game_user
      @user = @game_user.user
      @turns = @game.game_turns.where(user: @user)
      @turns.each do |t|
        if !t.played
          t.destroy
        end
      end
      @game_user.destroy
      if @game.state == 'wait'
        ActionCable.server.broadcast "count_#{@game.id}_channel", remove: true, count: @game.game_users.where(play: true).count, user_id: @user.id, state: @game.state
      end
    end
    flash[:success] = 'Nutzer entfernt!'
	  redirect_to gm_game_path
  end

  def delete_task_user
    @turn = GameTurn.find_by(id: params[:turn_id])
    @task = @turn.task
    @order = @pitch.task_orders.find_by(task_id: @task.id)
    if @turn != @game.current_turn
      @turn.destroy if !@turn.played
      render json: {order: @order.order, task: @task.id}
    else
      flash[:alert] = 'Bitte warte bis der aktuelle Pitch beendet ist!'
      redirect_to gm_game_path
    end
  end
  def set_task_user
    @task = @pitch.tasks.find(params[:task_id])
    @user = User.find_by(id: params[:turn_id])
    @turns = @game.game_turns.where(task: @task, played: false)
    @turns.each do |t|
      t.destroy
    end
    @turn = @game.game_turns.create(user: @user, team: @game.team, task: @task, play: true, played: false)
    if @game.current_task == @pitch.task_orders.find_by(task: @task).order
        @game.update(current_turn: @turn.id, state: 'turn')
    end
    if params[:show_task]
      redirect_to gm_game_path
      return
    else
      redirect_to gm_game_path(slide: @pitch.task_orders.find_by(task: @task).order)
      return
    end
  end

  def set_slide
	  @task_order = @pitch.task_orders.find_by(order: params[:slide])
    if @task_order
      while @task_order && !@task_order.task.valide
        @task_order = @pitch.task_orders.find_by(order: @task_order.order + 1)
      end
    else
      redirect_to gm_set_state_path(state: 'bestlist')
      return
    end
  	if @task_order && @game.current_task != @task_order.order
  	  @game.update(current_task: @task_order.order)
  	  if @game.state == 'slide' && @task_order.task.task_type == 'slide'
  		ActionCable.server.broadcast "game_#{@game.id}_channel", game_state: 'changed'
  		redirect_to gm_game_path
  		return
  	  elsif @task_order.task.task_type == 'slide'
  	    redirect_to gm_set_state_path(state: 'slide')
  		return
  	  else
  		redirect_to gm_set_state_path(state: 'show_task')
  		return
  	  end
  	elsif @task_order
      redirect_to gm_game_path
      return
    else
      redirect_to gm_set_state_path(state: 'bestlist')
      return
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
    elsif params[:state] == 'show_task'
      @task = @pitch.task_orders.find_by(order: @game.current_task).task
      @turn = @game.game_turns.where(task: @task, played: false).first
      if @turn && @game.turn1 != @turn.id && @game.turn2 != @turn.id
		    redirect_to gm_set_state_path(state: 'turn')
		    return
      elsif @game.state != 'show_task'
		    @game_users = @game.game_users.where(play: true, active: true).order('turn_count')
        @users = @game_users.where(turn_count: @game_users.first.turn_count).all
        if @users.count == 1 && @game_users.count >= 2
          @users = @game_users.first(2)
        elsif @users.count == 1
          redirect_to gm_set_state_path(state: 'turn')
          return
        else
          @users = @users.sample(2)
        end
        @turn1 = @game.game_turns.where(user: @users.first.user, task: @task, played: false).first
        @turn2 = @game.game_turns.where(user: @users.second.user, task: @task, played: false).first
        @turn1 = @game.game_turns.create(user: @users.first.user, task: @task, team: @game.team, played: false) if !@turn1
        @turn2 = @game.game_turns.create(user: @users.second.user, task: @task, team: @game.team, played: false) if !@turn2
        @game.update(state: "show_task", turn1: @turn1.id, turn2: @turn2.id, current_turn: nil) if @game.state != 'show_task'
        redirect_to gm_game_path
        return
      else
        redirect_to gm_game_path
        return
	    end
    elsif params[:state] == 'choose'
      @game.update(state: 'choose') if @game.state != 'choose'
      redirect_to gm_game_path
	    return
    elsif params[:state] == 'turn'
      @task = @pitch.task_orders.find_by(order: @game.current_task).task
      if @game.turn1 && @game.turn2
        @turn1 = GameTurn.find_by(id: @game.turn1)
        @turn2 = GameTurn.find_by(id: @game.turn2)
        if @turn1.counter > @turn2.counter
			    @turn = @turn1
          @turn2.destroy
		    elsif  @turn1.counter < @turn2.counter
          @turn = @turn2
          @turn1.destroy
        else
          @user1 = @game.game_users.find_by(user: @turn1.user)
          @user2 = @game.game_users.find_by(user: @turn2.user)
          if @user1.turn_count < @user2.turn_count
            @turn = @turn1
            @turn2.destroy
          else
            @turn = @turn2
            @turn1.destroy
          end
		    end
        @game.update(state: 'turn', current_turn: @turn.id, turn1: nil, turn2: nil) if @game.state != 'turn'
      else
        @turn = @game.game_turns.where(task: @task, played: false).last
        if @turn
          @game.update(state: 'turn', current_turn: @turn.id) if @game.state != 'turn'
        else
          @game_users = @game.game_users.where(play: true, active: true).order('turn_count')
          @user = @game_users.where(turn_count: @game_users.first.turn_count).sample
          @turn = @game.game_turns.create(user: @user.user, team: @game.team, played: false)
          @game.update(state: 'turn', current_turn: @turn.id) if @game.state != 'turn'
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
    elsif params[:state] == 'feedback'
      @turn = @game.game_turns.find_by(id: @game.current_turn)
      @game_user = @game.game_users.find_by(user: @turn.user)
      @turn.update(ges_rating: nil, played: true)
      @game_user.update(turn_count: @game.game_turns.where(user: @game_user.user).count)
      @game.update(state: 'feedback') if @game.state != 'feedback'
      redirect_to gm_game_path
    elsif params[:state] == 'rate'
      @turn = @game.game_turns.find_by(id: @game.current_turn)
	    if @turn
	      @task = @turn.task
        @task = @pitch.task_orders.find_by(order: @game.current_task).task if !@task
        if ( @task.rating1 && @task.rating1 != '' ) || ( @task.rating2 && @task.rating2 != '' ) || ( @task.rating3 && @task.rating3 != '' ) || ( @task.rating4 && @task.rating4 != '' )
          @turn = @game.game_turns.find_by(id: @game.current_turn)
          @game_user = @game.game_users.find_by(user: @turn.user)
          @turn.update(played: true)
          @game_user.update(turn_count: @game.game_turns.where(user: @game_user.user).count)
          @game.update(state: 'rate')
        else
		      redirect_to gm_set_state_path(state: 'feedback')
		      return
        end
		    redirect_to gm_game_path
	      return
	    else
		    redirect_to gm_set_slide_path(@game.current_task + 1)
		    return
	    end
    elsif params[:state] == 'rating'
      @turn = GameTurn.find_by(id: @game.current_turn)
      if @turn
        if @turn.game_turn_ratings.count == 0
          redirect_to gm_set_state_path(state: 'feedback')
		      return
        else
          @turns = @game.game_turns.where(user: @turn.user)
          @game_user = @game.game_users.find_by(user: @turn.user)
          if @turns.count > 0 && @turns.find_by(ges_rating: @turns.maximum("ges_rating"))
            if @turns.maximum("ges_rating") != nil
              @game_user.update(best_rating: @turns.maximum("ges_rating"))
            else
              @game_user.update(best_rating: 0)
            end
          end
          if @pitch.show_ratings == 'none'
            redirect_to gm_set_state_path(state: 'feedback')
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
      end
      redirect_to gm_game_path
      return
    elsif params[:state] == 'bestlist'
      if @game.state != 'bestlist'
        @game.game_turns.where(played: false).each do |gt|
          gt.update(ges_rating: nil)
        end
        @users = @game.game_users.where(play: true).order(best_rating: :desc).all
        place = 1
        @users.each do |t|
          if t.best_rating && t.best_rating != 0
            t.update(place: place)
            place += 1
          end
        end
        @game.update(state: 'bestlist', active: false)
      end
      redirect_to gm_game_path
      return
    elsif params[:state] == 'repeat'
      if @game.state != 'repeat' && @game.state != 'wait'
        @game.update(state: 'repeat', active: false)
		    game_old = @game
		    temp = Game.where(password: @game.password, state: 'wait', active: true).first
		    temp = Game.create(company: @game.company, user: @game.user, team: @game.team, state: 'wait', active: true, password: @game.password, pitch: @game.pitch, rating_user: @game.rating_user) if @temp.nil?
      end
	    redirect_to gm_game_path
	    return
    elsif params[:state] == 'ended'
	    @game.update(state: 'ended', active: false) if @game.state != "ended"
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

  def add_time
    @time = params[:time]
    ActionCable.server.broadcast "count_#{@game.id}_channel", addTime: true, time: @time
    render json: {time: @time}
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
		if game_user_logged_in? && @state != 'repeat'
		  @admin = current_game_user
		  if !@game.game_users.find_by(user: @admin)
			  game_logout
	  	  game_user_logout
		  	flash[:alert] = 'Du wurdest ausgeloggt!'
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
