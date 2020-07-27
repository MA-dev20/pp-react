class UserAbilitiesController < ApplicationController
  before_action :set_company

  def update_user
    @ability = @company.user_abilities.find_by(role: 'user')
    if @ability
      @ability.update(ability_params)
    else
      @ability = @company.user_abilities.new(ability_params)
      @ability.role = 'user'
      @ability.save
    end
    render json: {ability: @ability}
  end

  def update_admin
    @ability = @company.user_abilities.find_by(role: 'admin')
    if @ability
      @ability.update(ability_params)
    else
      @ability = @company.user_abilities.new(ability_params)
      @ability.role = 'admin'
      @ability.save
    end
    render json: {ability: @ability}
  end

  def update_root
    @ability = @company.user_abilities.find_by(role: 'root')
    if @ability
      @ability.update(ability_params)
    else
      @ability = @company.user_abilities.new(ability_params)
      @ability.role = 'root'
      @ability.save
    end
    render json: {ability: @ability}
  end

  private
    def set_company
      @company = Company.find(params[:company_id])
    end
    def ability_params
      params.require(:user_ability).permit(:edit_company, :view_department, :create_department, :edit_department, :view_team, :create_team, :edit_team, :share_team, :view_user, :create_user, :edit_user, :share_user, :view_stats, :view_pitch, :create_pitch, :edit_pitch, :share_pitch, :view_task, :create_task, :edit_task, :share_task, :view_media, :create_media, :edit_media, :share_media)
    end
end
