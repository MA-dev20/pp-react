module Dashboard
    class PitchesController < ApplicationController
        before_action :set_user, :get_cw_reactions
        layout "dashboard"

        def new
            @pitches = @admin.pitches.new
            @pitches.tasks.build
        end

        def edit
        end

        def create
            # TODO:
            # JSON()
            if Pitch.create(pitch_params)
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

        def index
            @pitch = Pitch.find(params[:pitch_id]) if params[:pitch_id]
            @pitches = @admin.pitches.includes(:tasks)
        end

        private

        def pitch_params
            params.require(:pitch).permit(:title, :image, :video, :description, :pitch_sound, :show_ratings, :skip_elections, :video_url, :user_id, tasks_attributes: [:id, :title, :time, :user_id, :image, :video, :video_id, :audio, :audio_id, :ratings, :reactions, :reaction_ids, :catchwords, :catchword_ids])
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