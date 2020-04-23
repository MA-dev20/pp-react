# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if user.bo_role == 'sales'
	end
	if user.coach
	  can :create, Coach, :user_id => user.id
	  can :manage, Company, :id => user.coach.company_id
	end
	if user.bo_role == 'root'
		can :manage, :all
	elsif user.role == 'company_admin' || user.coach == true 
	  can :manage, Company, :id => user.company_id
	  can :manage, Department, :company_id => user.company_id
	  can :manage, User, :company_id => user.company_id
	  can :manage, Team, :company_id => user.company_id
	  can :manage, CatchwordList, :company_id => user.company_id
	  can :manage, ObjectionList, :company_id => user.company_id
	  can :manage, RatingList, :company_id => user.company_id
	  can :manage, Game, :company_id => user.company_id
	elsif user.role == 'department_admin'
	  can [:read, :update], Department, :id => user.department_id
	  can :manage, User, :department_id => user.department_id
	  can :manage, Team, :department_id => user.department_id
	  can :manage, CatchwordList, :department_id => user.department_id
	  can :manage, ObjectionList, :department_id => user.department_id
	  can :manage, RatingList, :user_id => user.id
      can :manage, Game, :department_id => user.department_id
	elsif user.role == 'admin'
	  user.teams.find_by(name: 'all').users.each do |u|
	    can :manage, User, :id => u.id, role: 'user'
	  end
	  can :manage, Team, :user_id => user.id
	  can :manage, CatchwordList, :user_id => user.id
	  can :manage, ObjectionList, :user_id => user.id
	  can :manage, RatingList, :user_id => user.id
	  can :manage, Game, :user_id => user.id
	elsif user.role == 'user'
	  can [:read, :update, :destroy], User, :id => user.id
	end
	can :create, Rating
  end
end
