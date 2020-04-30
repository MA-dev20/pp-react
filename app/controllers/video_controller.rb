class VideoController < ApplicationController
  before_action :check_user
  before_action :set_video, except: [:new]
	
  def new
	authorize! :create, Video
	@video = @admin.videos.new(name: params[:name], video: params[:file] )
	@video.company = @admin.company
	@video.department = @admin.department
	flash[:alert] = 'Konnte Video nicht speichern!' if !@video.save
	redirect_to dashboard_video_path(edit: true, video: @video.id)
  end
	
  def edit
	authorize! :update, @video
	flash[:alert] = 'Konnte Video nicht updaten!' if !@video.update(video_params)
	redirect_to dashboard_video_path(edit: true, video: @video.id)
  end
	
  def destroy
	authorize! :destroy, @video
	flash[:alert] = 'Konnte Video nicht löschen!' if !@video.destroy
	redirect_to dashboard_video_path
  end
  private
	def video_params
      params.require(:video).permit(:name, :video)
	end
	def set_video
	  @video = Video.find(params[:video_id])
	end
	def check_user
	  if user_signed_in?
		@admin = current_user
	  else
		flash[:alert] = 'Logge dich ein um dein Dashboard zu sehen!'
	  end
	end
end
