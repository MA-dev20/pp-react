class CommentsController < ApplicationController
  before_action :set_turn
  before_action :set_comment, only: [:update, :destroy]
  def create
	@comment = @turn.comments.create(comment_params)
	if params[:site] == 'game'
	  @game = @turn.game
	  if @comment.user.avatar?
	  	ActionCable.server.broadcast "count_#{@game.id}_channel", comment: true, comment_text: @comment.text, comment_user_avatar: @comment.user.avatar.url
	  else
		ActionCable.server.broadcast "count_#{@game.id}_channel", comment: true, comment_text: @comment.text, name: @comment.user.fname[0].capitalize + @comment.user.lname[0].capitalize
	  end
	  render json: {comment: @comment.text}
  elsif params[:site] == 'feedback'
    @game = @turn.game
	  if @comment.user.avatar?
	  	ActionCable.server.broadcast "count_#{@game.id}_channel", comment: true, comment_text: @comment.text, comment_user_avatar: @comment.user.avatar.url, reverse: true
	  else
		ActionCable.server.broadcast "count_#{@game.id}_channel", comment: true, comment_text: @comment.text, name: @comment.user.fname[0].capitalize + @comment.user.lname[0].capitalize, reverse: true
	  end
	  render json: {comment: @comment.text}
	else
		respond_to do |format|
			format.html { redirect_to dashboard_pitch_video_path(@turn)}
			format.js { render }
		end
	end
  end

  def add_comment
	@comment = @turn.comments.create(comment_params)
	@comments = @turn.comments.where.not(time: nil).order(:time)
	respond_to do |format|
		format.html { redirect_to dashboard_pitch_video_path(@turn)}
		format.js { render }
	end
  end

  def update
	@comment.update(comment_params)
	redirect_to dashboard_pitch_video_path(@turn)
  end

  def destroy
	@comment.destroy
	redirect_to dashboard_pitch_video_path(@turn)
  end

  private
	def comment_params
	  params.require(:comment).permit(:text, :time, :user_id, :positive)
	end
	def set_comment
	  @comment = Comment.find(params[:comment_id])
	end
	def set_turn
	  @turn = GameTurn.find(params[:turn_id])
	end
	def check_user
	  if user_signed_in?
	    @admin = current_user
	    @company = @admin.company
	  else
	    flash[:alert] = 'Logge dich ein um dein Dashboard zu sehen!'
	    redirect_to root_path
	  end
	end
end
