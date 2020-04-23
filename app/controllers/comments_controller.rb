class CommentsController < ApplicationController
  before_action :set_turn
  before_action :set_comment, only: [:update, :destroy]
  def create
	@comment = @turn.comments.create(comment_params)
	redirect_to dashboard_pitch_video_path(@turn)
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
