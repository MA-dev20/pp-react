class DepartmentController < ApplicationController
  before_action :check_user
  before_action :set_department, except: [:new]
	
  def new
	authorize! :create, Department
	@department = @company.departments.new(department_params)
	flash[:alert] = 'Konnte Abteilung nicht anlegen!' if !@department.save
	redirect_to company_dash_departments_path
  end
	
  def edit
	authorize! :edit, @department
	flash[:alert] = 'Konnte Abteilung nicht updaten!' if !@department.update(department_params)
	redirect_to company_dash_departments_path(department: @department)
  end
  def destroy
	authorize! :destroy, @department
	flash[:alert] = 'Konnte Abteilung nicht löschen!' if !@department.destroy
	redirect_to company_dash_departments_path
  end
	
  def add_user
	authorize! :edit, @department
	@user = User.find(params[:user_id])
	@department.users << @user if @department.users.where(id: @user.id).count == 0
	render json: {count: @department.users.count, user_id: @user.id}
  end
	
  def delete_user
	authorize! :edit, @department
	@user = User.find(params[:user_id])
	@user.update(department: nil, role: 'user') if @user.role == 'department_admin'
	@user.update(department: nil) if @user.role != 'department_admin'
	redirect_to company_dash_departments_path(department: @department.id, edit: true)
  end

  private
	def department_params
	  params.require(:department).permit(:name)
	end
	def set_department
	  @department = Department.find(params[:department_id])
	end
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
