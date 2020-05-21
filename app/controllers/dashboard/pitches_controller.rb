module Dashboard
    class PitchesController < ApplicationController
        before_action :set_user, :get_cw_reactions
        layout "dashboard"

        def new
            @pitch = Pitch.new
            @pitch.tasks.build
            # debugger
        end

        def edit
        end

        def create
            # JSON.parse(Pitch.last.tasks.first.catchwords.join())
            debugger
            # Pitch.create(pitch_params)
        end

        def index
        end

        private

        def pitch_params
            params.require(:pitch).permit(:user_id, tasks_attributes: [:id, :title, :time, :user_id, :catchwords, :reactions])
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