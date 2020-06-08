module Dashboard
    class PitchesController < ApplicationController
        before_action :set_user, :get_cw_reactions
        before_action :set_pitch, only: [:edit, :update, :deleteMedia]

        layout "dashboard"

        def index
            @pitches = @admin.pitches
        end

        def new
            @pitch = @admin.pitches.new
            @pitch.tasks.build
        end

        def create
            # TODO:
            # JSON()
            debugger
            if Pitch.create(pitch_params)
                redirect_to dashboard_pitches_path, status: :moved_permanently
            else
                flash[:alert] = 'Error while creating pitch'
		        redirect_to root_path
            end
        end

        def edit
            render :new
        end

        def update
            pitch_params[:tasks_attributes].each do |key, values|
                if values[:destroy_media].present?
                    id = values[:destroy_media].to_i
                    @task = Task.find(id)
                    if @task.image.present?
                        @task.remove_image!
                    elsif @task.video.present?
                        @task.remove_video!
                    else
                        @task.remove_audio!
                    end
                    @task.update(media_option: '')
                    @task.save!
                end
            end
            if pitch_params[:destroy_image] == "true"
                @pitch.remove_image!
            end
            if pitch_params[:destroy_video] == "true"
                @pitch.remove_video!
            end

            if @pitch.update(pitch_params)
                @pitch.tasks.each do |task|
                    task.update(destroy_media: '')
                end
                @pitch.update(destroy_image: 'false', destroy_video: 'false')
                redirect_to dashboard_pitches_path, status: :moved_permanently
            else
                flash[:alert] = 'Error while creating pitch'
		        redirect_to root_path
            end
        end

        def createAudio
            @task_media = TaskMedium.create(audio: params[:file]) if params[:file].present?
            render json: {id: @task_media.id}
        end

        def deleteMedia
            @task = @pitch.tasks.find(params[:task_id])
            @task.remove_image!
            @task.save!
        end

        private

        def pitch_params
            params.require(:pitch).permit(:title, :description, :pitch_sound, :show_ratings, :skip_elections, :video_path, :image, :video, :destroy_image, :destroy_video, :user_id, tasks_attributes: [:id, :title, :time, :user_id, :image, :video, :video_id, :audio, :audio_id, :ratings, :reactions, :media_option, :reaction_ids, :catchwords, :catchword_ids, :destroy_media, :_destroy])
        end

        def set_pitch
            @pitch = Pitch.find(params[:id])
        end

        def set_user
            if user_signed_in?
                @admin = current_user
                @company = @admin.company
                @department = @admin.department
                @teamAll = @admin.teams.find_by(name: 'all') if @admin.role != "user"
                @teams = @admin.teams.where.not(name: 'all').order('name') if @admin.role != "user"
                @users = @teamAll.users.order('fname') if @admin.role != "user"
            else
                flash[:alert] = 'Logge dich ein um dein Dashboard zu sehen!'
                redirect_to root_path
            end
        end

        def get_cw_reactions
            @cw_lists = @admin.catchword_lists.order('name').includes(:catchwords)
	        @obj_lists = @admin.objection_lists.order('name').includes(:objections)
        end
    end 
end