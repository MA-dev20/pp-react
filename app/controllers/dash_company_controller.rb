class DashCompanyController < ApplicationController
  before_action :check_user
  
  def index
	@users = @company.users.where.not(role: 'company_admin').all
	@cAdmins = @company.users.where(role: 'company_admin').all
  end
	
  def company
  end
	
  def departments
	@departments = @company.departments
	@department = @company.departments.find(params[:department]) if params[:department]
  end
	
  def department
	@department = Department.find(params[:department_id])
	@users = @department.users.where.not(role: 'department_admin').or(@department.users.where.not(role: 'company_admin')).all.order(:lname)
	@dAdmins = @department.users.where(role: 'department_admin').or(@department.users.where(role: 'company_admin')).all
  end

  private
	def check_user
	  if user_signed_in?
		@admin = current_user
		@company = @admin.company
	  else
		flash[:alert] = 'Logge dich ein um dein Dashboard zu sehen!'
		redirect_to root_path
	  end
	end
end
