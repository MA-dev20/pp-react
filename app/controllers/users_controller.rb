class UsersController < ApplicationController
  before_action :check_user, except: [:edit_avatar]
  before_action :set_user, only: [:edit, :edit_avatar, :destroy, :company_admin, :department_admin, :admin, :user]
  def create
	authorize! :create, User
	@teamAll = @admin.teams.find_by(name: 'all')
	@user = @admin.company.users.new(user_params)
	@user.department = @admin.department if @admin.department
	password = SecureRandom.urlsafe_base64(8)
	@user.password = password
	if @user.save
	  @teamAll.users << @user
	  UserMailer.after_create(@user, password).deliver
	  redirect_to dashboard_teams_path
	else
	  flash[:alert] = 'Konnte User nicht speichern!'
	  redirect_to dashboard_teams_path
	end
  end
	
  def edit
	authorize! :update, @user
	flash[:alert] = 'Konnte User nicht updaten!' if !@user.update(user_params)
	if params[:user][:password] && params[:site] == 'account'
	  @user.update(password: params[:user][:password])
	  bypass_sign_in(@user)
	end
	redirect_to backoffice_company_path(@user.company_id) if params[:site] == 'backoffice_company'
	redirect_to dashboard_teams_path if params[:site] == 'dashboard_teams'
	redirect_to account_path if params[:site] == 'account'
  end
	
  def edit_avatar
	@user.update(avatar: params[:file]) if params[:file].present? && @user.present?
	render json: {file: @user.avatar.url}
  end
	
  def destroy
    authorize! :destroy, @user
	@company = @user.company
	if @user == @company.users.first
	  flash[:alert] = 'Du kannst diesen User nicht löschen!'
	else
	  flash[:alert] = 'Konnte User nicht löschen!' if !@user.destroy
	end
	redirect_to backoffice_company_path(@company) if params[:site] == 'backoffice_company'
	redirect_to dashboard_teams_path if params[:site] == 'dashboard'
  end
	
  def company_admin
	@user.update(role: "company_admin")
	render json: {user: @user}
  end
	
  def department_admin
	@user.update(role: 'department_admin')
	render json: {user: @user}
  end
	
  def admin
	@user.update(role: 'admin')
	render json: {user: @user}
  end
	
  def user
	@user.update(role: "user")
	render json: {user: @user}
  end
  private
	def user_params
	  params.require(:user).permit(:fname, :lname, :email, :avatar)
	end
	def set_user
	  @user = User.find(params[:user_id])
	end
	def check_user
	  if user_signed_in?
	    @admin = current_user
	  else
	    flash[:alert] = 'Logge dich ein um dein Dashboard zu sehen!'
	    redirect_to root_path
	  end
	end
end
