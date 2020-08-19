class UsersController < ApplicationController
  before_action :check_user, except: [:edit_avatar]
  before_action :set_user, only: [:set_role, :edit, :edit_avatar, :destroy, :send_password]
  before_action :set_company, only: [:set_role, :activate_users, :create]
  def create
	authorize! :create, User
	@user = User.new(user_params)
  @user.companies << @company
	if @user.save
	  redirect_to dashboard_teams_path
	else
	  flash[:alert] = 'Konnte User nicht speichern!'
	  redirect_to dashboard_teams_path
	end
  end

  def edit
	authorize! :update, @user
  @user.company_users.find_by(company: @admin_company).update(role: params[:user][:role]) if params[:user][:role]
	flash[:alert] = 'Konnte User nicht updaten!' if !@user.update(user_params)
	if params[:user][:password] && params[:site] == 'account'
	  @user.update(password: params[:user][:password])
	  bypass_sign_in(@user)
	end
	redirect_to backoffice_company_path(@user.company_id) if params[:site] == 'backoffice_company'
	redirect_to dashboard_teams_path if params[:site] == 'dashboard_teams'
	redirect_to account_path if params[:site] == 'account'
  end

  def send_password
    password = SecureRandom.urlsafe_base64(8)
    if @user.update(password: password)
      begin
  	  UserMailer.after_create(@user, password).deliver
  	  rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
  	    flash[:alert] = 'Falsche Mail-Adresse? Konnte Mail nicht senden!'
  	  end
      flash[:info_head] = 'Passwort gesendet!'
      flash[:info] = 'Prima. Wir haben dem Nutzer sein Passwort in einer Mail zukommen lassen.'
  	  redirect_to dashboard_teams_path(edit_user: @user)
    else
      flash[:alert] = 'Konnte Passwort nicht ändern!'
  	  redirect_to dashboard_teams_path(edit_user: @user)
    end
  end

  def new_password
	@user = User.find_by(email: params[:user][:email])
  end

  def edit_avatar
	@user.update(avatar: params[:file]) if params[:file].present? && @user.present?
	render json: {file: @user.avatar.url}
  end

  def destroy
    authorize! :destroy, @user
	@user.companies.each do |c|
  	if @user == c.users.first
  	  flash[:alert] = 'Du kannst diesen User nicht löschen!'
  	else
  	  c.company_users.find_by(user: @user).destroy
  	end
  end
  @user.destroy if @user.companies.count == 0
	redirect_to backoffice_company_path(@company) if params[:site] == 'backoffice'
	redirect_to dashboard_teams_path if params[:site] == 'dashboard'
  end

  def set_role
    @company_user = CompanyUser.find_by(company: @company, user: @user)
    if @company_user.role == 'sroot' && @company.company_users.where(role: 'sroot').count == 1
      flash[:alert] = 'Ein User muss Company Admin bleiben!'
      render json: {error: true}
    else
      @company_user.update(role: params[:user][:role])
      render json: {user: @user, role: @company_user.role}
    end
  end

  private
	def user_params
	  params.require(:user).permit(:fname, :lname, :email, :avatar)
	end
	def set_user
	  @user = User.find(params[:user_id])
	end
  def set_company
    @company = Company.find(params[:company_id])
  end
	def check_user
	  if user_signed_in? && company_logged_in?
	    @admin = current_user
      @admin_company = current_company
	  elsif user_signed_in?
      flash[:alert] = 'Wähle Unternehmen um dein Dashboard zu sehen!'
      redirect_to dash_choose_company_path
    else
	    flash[:alert] = 'Logge dich ein um dein Dashboard zu sehen!'
	    redirect_to root_path
	  end
	end
end
