# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if user.bo_role == 'root'
		  can :manage, :all
    else
      user.company_users.each do |cu|
        @abilities = cu.company.user_abilities.find_by(role: cu.role)
        @abilities = UserAbility.where(role: cu.role, name: cu.company_type + '_abilities').first if !@abilities
        @abilities = UserAbility.create(name: cu.company_type + '_abilities', role: cu.role) if !@abilities

        can :create, Department if @abilities.create_department != 'none'
        can :create, Team if @abilities.create_team != 'none'
        can :create, User if @abilities.create_team != 'none'
        can :create, Pitch if @abilities.create_pitch != 'none'
        can :create, Task if @abilities.create_pitch != 'none'
        can :create, TaskMedium if @abilities.create_media != 'none'
        can :create, Game if @abilities.view_pitch != 'none'

        can :read, Department, :user_id => user.id if @abilities.view_department != 'none'
        can :update, Department, :user_id => user.id if @abilities.edit_department != 'none'
        can :destroy, Department, :user_id => user.id if @abilities.edit_department != 'none'

        can :read, Team, :user_id => user.id if @abilities.view_team != 'none'
        can :update, Team, :user_id => user.id if @abilities.edit_team != 'none'
        can :destroy, Team, :user_id => user.id if @abilities.edit_team != 'none'

        can :read, User, :id => user.id
        can :update, User, :id => user.id
        can :destroy, User, :id => user.id if @abilities.edit_team != 'none'

        can :read, Pitch, :available_for => 'global'
        can :read, Pitch, :user_id => user.id if @abilities.view_pitch != 'none'
        can :update, Pitch, :user_id => user.id if @abilities.edit_pitch != 'none'
        can :destroy, Pitch, :user_id => user.id if @abilities.edit_pitch != 'none'
        SharedPitch.where(user: user).each do |sp|
          can :read, Pitch, :id => sp.pitch_id
        end
        SharedContent.where(user: user).each do |sc|
          can :read, TaskMedium, :id => sc.task_medium_id
          can :read, CatchwordList, :id => sc.catchword_list_id
          can :read, ObjectionList, :id => sc.objection_list_id
        end
        SharedFolder.where(user: user).each do |sf|
          can :read, ContentFolder, :id => sf.content_folder_id
        end


        can :read, Task, :user_id => user.id if @abilities.view_pitch != 'none'
        can :update, Task, :user_id => user.id if @abilities.edit_pitch != 'none'
        can :destroy, Task, :user_id => user.id if @abilities.edit_pitch != 'none'

        can :read, TaskMedium, :available_for => 'global'
        can :read, TaskMedium, :user_id => user.id if @abilities.view_media != 'none'
        can :update, TaskMedium, :user_id => user.id if @abilities.edit_media != 'none'
        can :destroy, TaskMedium, :user_id => user.id if @abilities.edit_media != 'none'


        can :read, Game, :user_id => user.id if @abilities.view_pitch != 'none'
        can :update, Game, :user_id => user.id if @abilities.view_pitch != 'none'
        can :destroy, Game, :user_id => user.id if @abilities.view_pitch != 'none'

        TeamUser.where(user: user).each do |tu|
          if tu.team.company == @company
            can :read, Team, :id => tu.team_id if @abilities.view_team != 'none' && @abilities.view_team != 'user'
            can :update, Team, :id => tu.team_id if @abilities.edit_team != 'none' && @abilities.edit_team != 'user'
            can :destroy, Team, :id => tu.team_id if @abilities.edit_team != 'none' && @abilities.edit_team != 'user'

            can :read, Pitch, :team_id => tu.team_id, :available_for => 'team' if @abilities.view_pitch != 'none' && @abilities.view_pitch != 'user'
            can :update, Pitch, :team_id => tu.team_id, :available_for => 'team' if @abilities.edit_pitch != 'none' && @abilities.edit_pitch != 'user'
            can :destroy, Pitch, :team_id => tu.team_id, :available_for => 'team' if @abilities.edit_pitch != 'none' && @abilities.edit_pitch != 'user'

            can :read, ContentFolder, :team_id => tu.team_id if @abilities.view_pitch != 'none' && @abilities.view_pitch != 'user'
            can :update, ContentFolder, :team_id => tu.team_id if @abilities.edit_pitch != 'none' && @abilities.edit_pitch != 'user'
            can :destroy, ContentFolder, :team_id => tu.team_id if @abilities.edit_pitch != 'none' && @abilities.edit_pitch != 'user'

            can :read, Task, :team_id => tu.team_id if @abilities.view_pitch != 'none' && @abilities.view_pitch != 'user'
            can :update, Task, :team_id => tu.team_id if @abilities.edit_pitch != 'none' && @abilities.edit_pitch != 'user'
            can :destroy, Task, :team_id => tu.team_id if @abilities.edit_pitch != 'none' && @abilities.edit_pitch != 'user'

            can :read, TaskMedium, :team_id => tu.team_id, :available_for => 'team' if @abilities.view_media != 'none' && @abilities.view_media != 'user'
            can :update, TaskMedium, :team_id => tu.team_id, :available_for => 'team' if @abilities.edit_media != 'none' && @abilities.edit_media != 'user'
            can :destroy, TaskMedium, :team_id => tu.team_id, :available_for => 'team' if @abilities.edit_media != 'none' && @abilities.edit_media != 'user'

            can :read, CatchwordList, :team_id => tu.team_id, :available_for => 'team' if @abilities.view_media != 'none' && @abilities.view_media != 'user'
            can :update, CatchwordList, :team_id => tu.team_id, :available_for => 'team' if @abilities.edit_media != 'none' && @abilities.edit_media != 'user'
            can :destroy, CatchwordList, :team_id => tu.team_id, :available_for => 'team' if @abilities.edit_media != 'none' && @abilities.edit_media != 'user'

            can :read, ObjectionList, :team_id => tu.team_id, :available_for => 'team' if @abilities.view_media != 'none' && @abilities.view_media != 'user'
            can :update, ObjectionList, :team_id => tu.team_id, :available_for => 'team' if @abilities.edit_media != 'none' && @abilities.edit_media != 'user'
            can :destroy, ObjectionList, :team_id => tu.team_id, :available_for => 'team' if @abilities.edit_media != 'none' && @abilities.edit_media != 'user'

            tu.team.team_users.each do |u|
              can :read, User, :id => u.user_id if @abilities.view_team != 'none' && @abilities.view_team != 'user'
              can :update, User, :id => u.user_id if @abilities.edit_team != 'none' && @abilities.edit_team != 'user'
              can :destroy, User, :id => u.user_id if @abilities.edit_team != 'none' && @abilities.edit_team != 'user'
            end
          end
        end

        DepartmentUser.where(user: user).each do |du|
          if du.department.company == @company
            can :read, Department, :id => du.department_id if @abilities.view_department == 'department' || @abilities.view_department == 'company'
            can :update, Department, :id => du.department_id if @abilities.edit_department == 'department' || @abilities.edit_department == 'company'
            can :destroy, Department, :id => du.department_id if @abilities.edit_department == 'department' || @abilities.edit_department == 'company'

            can :read, Team, :department_id => du.department_id if @abilities.view_team == 'department' || @abilities.view_team == 'company'
            can :update, Team, :department_id => du.department_id if @abilities.edit_team == 'department' || @abilities.edit_team == 'company'
            can :destroy, Team, :department_id => du.department_id if @abilities.edit_team == 'department' || @abilities.edit_team == 'company'

            du.department.department_users.each do |u|
              can :read, User, :id => u.user_id if @abilities.view_team == 'department' || @abilities.view_team == 'company'
              can :update, User, :id => u.user_id if @abilities.edit_team == 'department' || @abilities.edit_team == 'company'
              can :destroy, User, :id => u.user_id if @abilities.edit_team == 'department' || @abilities.edit_team == 'company'
            end

            can :read, ContentFolder, :department_id => du.department_id, :available_for => 'department' if @abilities.view_pitch == 'department' || @abilities.view_pitch == 'company'
            can :update, ContentFolder, :department_id => du.department_id, :available_for => 'department'  if @abilities.edit_pitch == 'department' || @abilities.edit_pitch == 'company'
            can :destroy, ContentFolder, :department_id => du.department_id, :available_for => 'department'  if @abilities.edit_pitch == 'department' || @abilities.edit_pitch == 'company'

            can :read, Pitch, :department_id => du.department_id, :available_for => 'department' if @abilities.view_pitch == 'department' || @abilities.view_pitch == 'company'
            can :update, Pitch, :department_id => du.department_id, :available_for => 'department'  if @abilities.edit_pitch == 'department' || @abilities.edit_pitch == 'company'
            can :destroy, Pitch, :department_id => du.department_id, :available_for => 'department'  if @abilities.edit_pitch == 'department' || @abilities.edit_pitch == 'company'

            can :read, Task, :department_id => du.department_id if @abilities.view_task == 'department' || @abilities.view_task == 'company'
            can :update, Task, :department_id => du.department_id if @abilities.edit_task == 'department' || @abilities.edit_task == 'company'
            can :destroy, Task, :department_id => du.department_id if @abilities.edit_task == 'department' || @abilities.edit_task == 'company'

            can :read, TaskMedia, :department_id => du.department_id, :available_for => 'department' if @abilities.view_media == 'department' || @abilities.view_media == 'company'
            can :update, TaskMedia, :department_id => du.department_id, :available_for => 'department' if @abilities.edit_media == 'department' || @abilities.edit_media == 'company'
            can :destroy, TaskMedia, :department_id => du.department_id, :available_for => 'department' if @abilities.edit_media == 'department' || @abilities.edit_media == 'company'

            can :read, CatchwordList, :department_id => du.department_id, :available_for => 'department' if @abilities.view_media == 'department' || @abilities.view_media == 'company'
            can :update, CatchwordList, :department_id => du.department_id, :available_for => 'department'  if @abilities.edit_media == 'department' || @abilities.edit_media == 'company'
            can :destroy, CatchwordList, :department_id => du.department_id, :available_for => 'department'  if @abilities.edit_media == 'department' || @abilities.edit_media == 'company'

            can :read, ObjectionList, :department_id => du.department_id, :available_for => 'department' if @abilities.view_media == 'department' || @abilities.view_media == 'company'
            can :update, ObjectionList, :department_id => du.department_id, :available_for => 'department'  if @abilities.edit_media == 'department' || @abilities.edit_media == 'company'
            can :destroy, ObjectionList, :department_id => du.department_id, :available_for => 'department'  if @abilities.edit_media == 'department' || @abilities.edit_media == 'company'
          end
        end

        can :update, Company, :id => cu.id if @abilities.edit_company

        can :read, Department, :company_id => cu.company_id if @abilities.view_department == 'company'
        can :update, Department, :company_id => cu.company_id if @abilities.edit_department == 'company'
        can :destroy, Department, :company_id => cu.company_id if @abilities.edit_department == 'company'

        can :read, Team, :company_id => cu.company_id if @abilities.view_team == 'company'
        can :update, Team, :company_id => cu.company_id if @abilities.edit_team == 'company'
        can :destroy, Team, :company_id => cu.company_id if @abilities.edit_team == 'company'

        cu.company.users.each do |u|
          can :read, User, :id => u.id if @abilities.view_team == 'company'
          can :update, User, :id => u.id if @abilities.edit_team == 'company'
          can :destroy, User, :id => u.id if @abilities.edit_team == 'company'
        end

        can :read, Pitch, :company_id => cu.company_id, :available_for => 'company' if @abilities.view_pitch == 'company'
        can :update, Pitch, :company_id => cu.company_id, :available_for => 'company' if @abilities.edit_pitch == 'company'
        can :destroy, Pitch, :company_id => cu.company_id, :available_for => 'company' if @abilities.edit_pitch == 'company'

        can :read, Task, :company_id => cu.company_id if @abilities.view_pitch == 'company'
        can :update, Task, :company_id => cu.company_id if @abilities.edit_pitch == 'company'
        can :destroy, Task, :company_id => cu.company_id if @abilities.edit_pitch == 'company'

        can :read, ContentFolder, :company_id => cu.company_id, :available_for => 'company' if @abilities.view_media == 'company'
        can :update, ContentFolder, :company_id => cu.company_id, :available_for => 'company' if @abilities.edit_media == 'company'
        can :destroy, ContentFolder, :company_id => cu.company_id, :available_for => 'company' if @abilities.edit_media == 'company'

        can :read, TaskMedium, :company_id => cu.company_id, :available_for => 'company' if @abilities.view_media == 'company'
        can :update, TaskMedium, :company_id => cu.company_id, :available_for => 'company' if @abilities.edit_media == 'company'
        can :destroy, TaskMedium, :company_id => cu.company_id, :available_for => 'company' if @abilities.edit_media == 'company'

        can :read, CatchwordList, :company_id => cu.company_id, :available_for => 'company' if @abilities.view_media == 'company'
        can :update, CatchwordList, :company_id => cu.company_id, :available_for => 'company' if @abilities.edit_media == 'company'
        can :destroy, CatchwordList, :company_id => cu.company_id, :available_for => 'company' if @abilities.edit_media == 'company'

        can :read, ObjectionList, :company_id => cu.company_id, :available_for => 'company' if @abilities.view_media == 'company'
        can :update, ObjectionList, :company_id => cu.company_id, :available_for => 'company' if @abilities.edit_media == 'company'
        can :destroy, ObjectionList, :company_id => cu.company_id, :available_for => 'company' if @abilities.edit_media == 'company'
      end
    end
  end
end
