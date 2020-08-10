class UserAbilitiesController < ApplicationController
  before_action :set_company, only: [:update]

  def update
    @user_ability = @company.user_abilities.find_by(role: params[:role])
    if @user_ability
      @user_ability.update(ability_params)
    else
      @user_ability = @company.user_abilities.new(ability_params)
      @user_ability.role = params[:role]
      @user_ability.save
    end
    render json: {ability: @user_ability}
  end

  def update_preset
    @user_ability = UserAbility.find_by(name: params[:type] + '_abilities', role: params[:role])
    @user_ability.update(ability_params)
    render json: {ability: @user_ability}
  end

  private
    def set_company
      @company = Company.find(params[:company_id])
    end
    def ability_params
      params.require(:user_ability).permit(:edit_company, :view_department, :create_department, :edit_department, :view_team, :create_team, :edit_team, :share_team, :view_user, :create_user, :edit_user, :share_user, :view_stats, :view_pitch, :create_pitch, :edit_pitch, :share_pitch, :view_task, :create_task, :edit_task, :share_task, :view_media, :create_media, :edit_media, :share_media)
    end
end
