# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if user.bo_role == 'root'
		  can :manage, :all
    else
      user.company_users.each do |cu|
        @abilities = cu.company.user_abilities.find_by(role: cu.role)
        @abilities = UserAbility.where(role: cu.role, name: cu.company.company_type + '_abilities').first if !@abilities
        @abilities = UserAbility.create(name: cu.company.company_type + '_abilities', role: cu.role) if !@abilities

        can :update, Company if @abilities.edit_company != "none"

        can :create, Department if @abilities.create_department != "none"
        can :read, Department, :user_id => user.id if @abilities.view_department != 'none'
        can :update, Department, :user_id => user.id if @abilities.edit_department != 'none'
        can :destroy, Department, :user_id => user.id if @abilities.edit_department != 'none'

        if @abilities.create_team != 'none'
          can :create, Team
          can :create, User
        end
        if @abilities.view_team != "none"
          can :read, Team, :user_id => user.id
          can :read, User, :id => user.id
          user.user_users.where(company: cu.company).each do |u|
            can :read, User, :id => u.userID
          end
        end
        if @abilities.edit_team != 'none'
          can :update, Team, :user_id => user.id
          can :destroy, Team, :user_id => user.id
          can :update, User, :id => user.id
          can :destroy, User, :id => user.id
          user.user_users.where(company: cu.company).each do |u|
            can :update, User, :id => u.userID
            can :destroy, User, :id => u.userID
          end
        end

        if @abilities.create_content != 'none'
          can :create, Pitch
          can :create, Task
          can :create, TaskMedium
          can :create, ContentFolder
        end
        if @abilities.view_content != "none"
          can :read, Pitch, :user_id => user.id
          can :read, Task, :user_id => user.id
          can :read, ContentFolder, :user_id => user.id
          can :read, TaskMedium, :user_id => user.id
          can :read, List, :user_id => user.id
          can :create, Game
          can :read, Game, :user_id => user.id
          can :update, Game, :user_id => user.id
          can :destroy, Game, :user_id => user.id
          user.lists.each do |list|
            list.list_entries.each do |entry|
              can :read, ListEntry, :id => entry.id
            end
          end
        end
        if @abilities.edit_content != 'none'
          can :update, Pitch, :user_id => user.id
          can :destroy, Pitch, :user_id => user.id
          can :update, Task, :user_id => user.id
          can :destroy, Task, :user_id => user.id
          can :update, ContentFolder, :user_id => user.id
          can :destroy, ContentFolder, :user_id => user.id
          can :update, TaskMedium, :user_id => user.id
          can :destroy, TaskMedium, :user_id => user.id
          can :update, List, :user_id => user.id
          can :destroy, List, :user_id => user.id
        end
        can :read, PitchVideo, :user_id => user.id
        can :read, PitchVideo, :user_id => user.id
        can :read, PitchVideo, :user_id => user.id
        GameTurn.where(user: user).each do |turn|
          can :read, PitchVideo, :game_turn_id => turn.id, :released => true
        end

        can :read, Pitch, :available_for => 'global'
        can :read, ContentFolder, :available_for => 'global'
        can :read, TaskMedium, :available_for => 'global'
        can :read, List, :available_for => 'global'
        can :read, Pitch, :available_for => 'global_hidden'
        can :read, ContentFolder, :available_for => 'global_hidden'
        can :read, TaskMedium, :available_for => 'global_hidden'
        can :read, List, :available_for => 'global_hidden'
        List.where(available_for: 'global_hidden').each do |list|
          list.list_entries.each do |entry|
            cannot :read, ListEntry, :id => entry.id
          end
        end
        List.where(available_for: 'global').each do |list|
          list.list_entries.each do |entry|
            can :read, ListEntry, :id => entry.id
          end
        end

        SharedPitch.where(user: user).each do |sp|
          can :read, Pitch, :id => sp.pitch_id
        end
        SharedContent.where(user: user).each do |sc|
          can :read, TaskMedium, :id => sc.task_medium_id
          can :read, List, :id => sc.list_id
          sc.list.list_entries.each do |entry|
            can :read, ListEntry, :id => entry.id
          end
        end
        SharedFolder.where(user: user).each do |sf|
          can :read, ContentFolder, :id => sf.content_folder_id
        end

        user.teams.where(company: cu.company).each do |team|
          team.team_users.each do |u|
            can :read, User, :id => u.user_id if @abilities.view_team != "none" && @abilities.view_team != 'user'
            can :update, User, :id => u.user_id if @abilities.edit_team != 'none' && @abilities.edit_team != 'user'
            can :destroy, User, :id => u.user_id if @abilities.edit_team != 'none' && @abilities.edit_team != 'user'
          end
          if @abilities.view_content != 'none' && @abilities.view_content != 'user'
            can :read, Pitch, :team_id => team.id, :available_for => 'team'
            can :read, TaskMedium, :team_id => team.id, :available_for => 'team'
            can :read, ContentFolder, :team_id => team.id, :available_for => 'team'
            can :read, List, :team_id => team.id, :available_for => 'team'
            List.where(team: team, available_for: 'team').each do |list|
              list.list_entries.each do |entry|
                can :read, ListEntry, :id => entry.id
              end
            end
          end
          if @abilities.edit_content != 'none' && @abilities.edit_content != 'user'
            can :update, Pitch, :team_id => team.id, :available_for => 'team'
            can :destroy, Pitch, :team_id => team.id, :available_for => 'team'
            can :update, ContentFolder, :team_id => team.id, :available_for => 'team'
            can :destroy, ContentFolder, :team_id => team.id, :available_for => 'team'
            can :update, TaskMedium, :team_id => team.id, :available_for => 'team'
            can :destroy, TaskMedium, :team_id => team.id, :available_for => 'team'
            can :update, List, :team_id => team.id, :available_for => 'team'
            can :destroy, List, :team_id => team.id, :available_for => 'team'
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

            if @abilities.view_content == 'department' || @abilities.view_content == 'company'
              can :read, Pitch, :department_id => du.department_id, :available_for => 'department'
              can :read, TaskMedium, :department_id => du.department_id, :available_for => 'department'
              can :read, ContentFolder, :department_id => du.department_id, :available_for => 'department'
              can :read, List, :department_id => du.department_id, :available_for => 'department'
              List.where(department: du.department, available_for: 'department').each do |list|
                list.list_entries.each do |entry|
                  can :read, ListEntry, :id => entry.id
                end
              end
            end

            if @abilities.edit_content == 'department' || @abilities.edit_content == 'company'
              can :update, Pitch, :department_id => du.department_id, :available_for => 'department'
              can :destroy, Pitch, :department_id => du.department_id, :available_for => 'department'
              can :update, ContentFolder, :department_id => du.department_id, :available_for => 'department'
              can :destroy, ContentFolder, :department_id => du.department_id, :available_for => 'department'
              can :update, TaskMedium, :department_id => du.department_id, :available_for => 'department'
              can :destroy, TaskMedium, :department_id => du.department_id, :available_for => 'department'
              can :update, List, :department_id => du.department_id, :available_for => 'department'
              can :destroy, List, :department_id => du.department_id, :available_for => 'department'
            end
          end
        end

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

        if @abilities.view_content == 'company'
          can :read, Pitch, :company_id => cu.company_id, :available_for => 'company'
          can :read, TaskMedium, :company_id => cu.company_id, :available_for => 'company'
          can :read, ContentFolder, :company_id => cu.company_id, :available_for => 'company'
          can :read, List, :company_id => cu.company_id, :available_for => 'company'
          List.where(company: cu.company, available_for: 'company').each do |list|
            list.list_entries.each do |entry|
              can :read, ListEntry, :id => entry.id
            end
          end
        end
        if @abilities.edit_content == 'company'
          can :update, Pitch, :company_id => cu.company_id, :available_for => 'company'
          can :destroy, Pitch, :company_id => cu.company_id, :available_for => 'company'
          can :update, ContentFolder, :company_id => cu.company_id, :available_for => 'company'
          can :destroy, ContentFolder, :company_id => cu.company_id, :available_for => 'company'
          can :update, TaskMedium, :company_id => cu.company_id, :available_for => 'company'
          can :destroy, TaskMedium, :company_id => cu.company_id, :available_for => 'company'
          can :update, CatchwordList, :company_id => cu.company_id, :available_for => 'company'
          can :destroy, ObjectionList, :company_id => cu.company_id, :available_for => 'company'
          can :update, CatchwordList, :company_id => cu.company_id, :available_for => 'company'
          can :destroy, ObjectionList, :company_id => cu.company_id, :available_for => 'company'
        end
      end
    end
  end
end
