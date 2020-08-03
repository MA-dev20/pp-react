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
	@turn1 = GameTurn.find_by(id: @game.turn1) if @game.turn1
	@turn2 = GameTurn.find_by(id: @game.turn2) if @game.turn2
	@task = @pitch.task_orders.find_by(order: @game.current_task).task if @game.current_task != 0 && !@game.current_task.nil?
  @turn = @game.game_turns.find_by(task: @task) if !@turn
	if @turn && @game.show_ratings == 'all'
	  @turn_ratings = @turn.game_turn_ratings.all
	  @ges_rating = @turn.ges_rating
	elsif @turn && @game.show_ratings == 'one'
	  @rat_user = @game.rating_user
	  @turn_ratings = @turn.ratings.where(user_id: @rat_user).all
	  @ges_rating = @turn.ratings.where(user_id: @rat_user).average(:rating)
	end
	@turns = @game.game_turns.where.not(ges_rating: nil).order(ges_rating: :desc)
  @game_users = @game.game_users.where(play: true).order(best_rating: :desc)
	if @game.show_ratings == 'one'
	  @rat_user = @game.rating_user
	  @turns = @turns.sort_by{ |e| -(e.ratings.where(user_id: @rat_user).count != 0 ? e.ratings.where(user_id: @rat_user).average(:rating) : 0) }
	end
  if @game.state == 'bestlist' && @game.show_ratings == 'one'
    @ratings = [];
    @game.game_users.each do |u|
      if u.user_id != @game.rating_user
        @turns = @game.game_turns.where(user_id: u.user_id)
        @best_rating = 0
        @turns.each do |t|
          this_rating = t.ratings.where(user_id: @game.rating_user).average(:rating) if t.ratings.where(user_id: @game.rating_user).count != 0
          this_rating = 0 if t.ratings.where(user_id: @game.rating_user).count == 0
          if this_rating  > @best_rating
            @best_rating = this_rating
          end
        end
        if u.user.avatar?
          @ratings << {user_id: u.user_id, rating: @best_rating.to_i, avatar: u.user.avatar.url}
        else
          @ratings << {user_id: u.user_id, rating: @best_rating.to_i, name: u.user.fname[0].capitalize + u.user.lname[0].capitalize}
        end
      end
    end
    @ratings = @ratings.sort_by{|e| -e[:rating]}
  end
	render @state
  end

  def repeat
  end

  def ended
	game_logout
	redirect_to dashboard_path
  end

  def set_slide
	  @task_order = @pitch.task_orders.find_by(order: params[:slide])
    while @task_order && !@task_order.task.valide
      @task_order = @pitch.task_orders.find_by(order: @task_order.order + 1)
    end
    if @task_order
  	  if @game.state == 'slide' && @task_order.task.task_type == 'slide' && @game.current_task != @task_order.order
        @game.update(current_task: @task_order.order, state: 'slide') if @game.current_task != @task_order.order
    		ActionCable.server.broadcast "game_#{@game.id}_channel", game_state: 'changed'
    		redirect_to gd_game_path
    		return
      elsif @task_order.task.task_type == 'slide' && @game.state != "slide"
        @game.update(current_task: @task_order.order, state: 'slide') if @game.current_task != @task_order.order
    	  redirect_to gd_game_path
    		return
    	elsif @game.state != 'show_task' && @task_order.task.task_type != 'slide'
        @game.update(current_task: @task_order.order) if @game.current_task != @task_order.order
    		redirect_to gd_set_state_path(state: 'show_task')
    		return
      else
        @game.update(current_task: @task_order.order) if @game.current_task != @task_order.order
        redirect_to gd_game_path
    		return
      end
  	else
      if @game.show_ratings == 'one' || @game.show_ratings == 'all'
        redirect_to gd_set_state_path(state: 'bestlist')
        return
      else
        redirect_to gd_set_state_path(state: 'ended')
        return
      end
    end
  end
  def set_state
    if params[:state] == 'wait'
      @game.update(state: "wait") if @game.state != 'wait'
      redirect_to gd_game_path
	    return
	  elsif params[:state] == 'show_task'
      @task = @pitch.task_orders.find_by(order: @game.current_task).task
      @turn = @game.game_turns.where(task: @task, played: false).first
      if @turn && @game.turn1 != @turn.id && @game.turn2 != @turn.id
		    redirect_to gd_set_state_path(state: 'turn')
		    return
      elsif @game.state != 'show_task'
		    @game_users = @game.game_users.where(play: true, active: true).order('turn_count')
        @users = @game_users.where(turn_count: @game_users.first.turn_count).all
        if @users.count == 1 && @game_users.count >= 2
          @users = @game_users.first(2)
        elsif @users.count == 1
          redirect_to gd_set_state_path(state: 'turn')
          return
        else
          @users = @users.sample(2)
        end
        @turn1 = @game.game_turns.where(user: @users.first.user, task: @task, played: false).first
        @turn2 = @game.game_turns.where(user: @users.second.user, task: @task, played: false).first
        @turn1 = @game.game_turns.create(user: @users.first.user, task: @task, team: @game.team, played: false) if !@turn1
        @turn2 = @game.game_turns.create(user: @users.second.user, task: @task, team: @game.team, played: false) if !@turn2
        @game.update(state: "show_task", turn1: @turn1.id, turn2: @turn2.id, current_turn: nil) if @game.state != 'show_task'
        redirect_to gd_game_path
        return
      else
        redirect_to gd_game_path
        return
	    end
    elsif params[:state] == 'choose'
      @game.update(state: 'choose') if @game.state != 'choose'
      redirect_to gd_game_path
	    return
    elsif params[:state] == 'turn'
      @task = @pitch.task_orders.find_by(order: @game.current_task).task
      @turn = @game.game_turns.where(task: @task, played: false).first
      if @turn && @game.turn1 != @turn.id && @game.turn2 != @turn.id
        @game.update(state: 'turn', current_turn: @turn.id) if @game.state != 'turn'
      else
        @turn1 = GameTurn.find_by(id: @game.turn1) if @game.turn1
        @turn2 = GameTurn.find_by(id: @game.turn2) if @game.turn2
        if @turn1 && @turn2
          if @turn1.counter > @turn2.counter
			      @turn = @turn1
            @turn2.destroy
		      elsif @turn1.counter < @turn2.counter
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
          @game_users = @game.game_users.where(play: true, active: true).order('turn_count')
          @user = @game_users.where(turn_count: @game_users.first.turn_count).sample
          @turn = @game.game_turns.create(user: @user.user, team: @game.team, played: false)
          @game.update(state: 'turn', current_turn: @turn.id) if @game.state != 'turn'
        end
      end
      redirect_to gd_game_path
	    return
    elsif params[:state] == 'play'
      @turn = GameTurn.find_by(id: @game.current_turn) if @game.current_turn
	    @task = @pitch.task_orders.find_by(order: @game.current_task).task
	    if @task.task_type == 'catchword'
		    @turn.update(catchword: @task.catchword_list.catchwords.sample)
	    end
      @game.update(state: 'play', turn1: nil, turn2: nil) if @game.state != 'play'
      redirect_to gd_game_path
	    return
    elsif params[:state] == 'feedback'
      @turn = @game.game_turns.find_by(id: @game.current_turn)
      @game_user = @game.game_users.find_by(user: @turn.user)
      if @turn.game_turn_ratings.count == 0
        @turn.update(ges_rating: nil, played: true)
      end
      @game_user.update(turn_count: @game.game_turns.where(user: @game_user.user).count)
      @game.update(state: 'feedback') if @game.state != 'feedback'
      redirect_to gd_game_path
    elsif params[:state] == 'rate'
      if @game.show_ratings == 'none' || @game.game_users.count == 1
        redirect_to gd_set_state_path(state: "feedback")
        return
      end
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
		      redirect_to gd_set_state_path(state: 'feedback')
		      return
        end
		    redirect_to gd_game_path
	      return
	    else
		    redirect_to gd_set_slide_path(@game.current_task + 1)
		    return
	    end
    elsif params[:state] == 'rating'
      @turn = GameTurn.find_by(id: @game.current_turn)
      if @turn
        if @turn.game_turn_ratings.count == 0
          redirect_to gd_set_state_path(state: 'feedback')
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
          if @game.state != 'rating'
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
            if @game.show_ratings == 'skip' || @game.show_ratings == 'one' && @turn.user_id == @game.rating_user
              redirect_to gd_set_state_path(state: 'feedback')
    		      return
            else
              @game.update(state: 'rating')
            end
          end
        end
      end
      redirect_to gd_game_path
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
      redirect_to gd_game_path
      return
    elsif params[:state] == 'repeat'
      if @game.state != 'repeat' && @game.state != 'wait'
        @game.update(state: 'repeat', active: false)
		    game_old = @game
		    temp = Game.where(password: @game.password, state: 'wait', active: true).first
		    temp = Game.create(company: @game.company, user: @game.user, team: @game.team, state: 'wait', active: true, password: @game.password, pitch: @game.pitch, rating_user: @game.rating_user) if @temp.nil?
      end
	    redirect_to gd_game_path
	    return
    elsif params[:state] == 'ended'
	    @game.update(state: 'ended', active: false) if @game.state != "ended"
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
		redirect_to gd_game_path
	  elsif @state == 'ended'
	    redirect_to gd_ended_path
	  end
	end
end
