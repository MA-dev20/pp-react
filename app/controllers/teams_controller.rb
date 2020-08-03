class TeamsController < ApplicationController
  before_action :check_user
  before_action :check_company, only: [:create]
  before_action :set_team, only: [:edit, :add_user, :delete_user, :destroy]
  def create
	authorize! :create, Team
	@team = @company.teams.new(team_params)
	@team.user = @admin
	if @team.save
	  redirect_to dashboard_team_path(@team, edit: true) if params[:team][:site] == 'teams'
	  redirect_to dashboard_pitches_path('', team: @team.id, pitch_id: params[:pitch_id]) if params[:team][:site] != 'teams'
	else
	  redirect_to dashboard_teams_path if params[:team][:site] == 'teams'
	  redirect_to dashboard_path if params[:team][:site] != 'teams'
	end
  end

  def edit
	authorize! :edit, @team
	flash[:alert] = 'Konnte Team nicht updaten!' if !@team.update(team_params)
	redirect_to dashboard_team_path(@team)
  end

  def destroy
	authorize! :destroy, @team
	flash[:alert] = 'Konnte Team nicht löschen!' if !@team.destroy
	redirect_to dashboard_teams_path if params[:site] == "dashboard"
  end

  def add_user
	authorize! :edit, @team
	@user = User.find(params[:user_id])
	@team.users << @user if @team.users.where(id: @user.id).count == 0
	render json: {count: @team.users.count, user_id: @user.id}
  end
  def delete_user
	authorize! :edit, @team
	@user = User.find(params[:user_id])
	@team.users.delete(@user)
	redirect_to dashboard_team_path(@team, edit: 'true') if params[:site] = "dashboard_team_edit"
  end


  private
	def team_params
	  params.require(:team).permit(:name)
	end
	def set_team
	  @team = Team.find(params[:team_id])
	end
	def check_user
	  if user_signed_in?
	    @admin = current_user
	  else
	    flash[:alert] = 'Logge dich ein um dein Dashboard zu sehen!'
	    redirect_to root_path
	  end
	end
  def check_company
    if company_logged_in?
      @company = current_company
    else
      flash[:alert] = 'Wähle ein Unternehmen um dein Dashboard zu sehen!'
	    redirect_to dash_choose_company_path
    end
  end
end
