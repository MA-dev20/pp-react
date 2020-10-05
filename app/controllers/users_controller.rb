class UsersController < ApplicationController
  before_action :check_user, except: [:edit_avatar]
  before_action :set_user, only: [:set_role, :edit, :edit_ajax, :edit_avatar, :destroy, :send_password]
  before_action :set_company, only: [:set_role, :activate_users, :create]
  def create
    @user = User.find_by(email: user_params[:email])
    @team = Team.find_by(id: params[:team]) if params[:team]
    @companyUser = @company.company_users.find_by(user: @user) if @user
    if @user
      if @company.user_users.find_by(user: @admin, userID: @user.id)
        flash[:alert] = 'Nutzer existiert bereits'
        redirect_to dashboard_teams_path(@team) if @team
        redirect_to dashboard_teams_path if !@team
        return
      end
      if @companyUser
        if @team && @team.users.find_by(id: @user.id)
          flash[:alert] = 'Nutzer existiert bereits'
          redirect_to dashboard_teams_path(@team)
          return
        elsif @team
          @company.user_users.create(user: @admin, userID: @user.id) if @companyUser.role == 'user' || @companyUser.role == 'inactive'
          @team.users << @user
          redirect_to dashboard_teams_path(@team)
          return
        else
          @company.user_users.create(user: @admin, userID: @user.id) if @companyUser.role == 'user' || @companyUser.role == 'inactive'
          redirect_to dashboard_teams_path
          return
        end
      else
        @user.companies << @company
        @company.user_users.create(user: @admin, userID: @user.id)
        if @team
          @team.users << @user
          redirect_to dashboard_teams_path(@team)
          return
        else
          redirect_to dashboard_teams_path
          return
        end
      end
    else
  	  @user = User.new(user_params)
      @user.companies << @company
      @user.teams << @team if @team
      if @user.save(:validate => false)
        @company.user_users.create(user: @admin, userID: @user.id)
      else
        flash[:alert] = 'Konnte User nicht speichern!'
      end
  	  redirect_to dashboard_teams_path(@team) if @team
      redirect_to dashboard_teams_path if !@team
    end
  end

  def edit_ajax
    @user.update(user_params)
    render json: {fname: @user.fname, lname: @user.lname, email: @user.email, avatar: @user.avatar.url}
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
  def activate_users
    if params[:users]
      params[:users].each do |u|
        @user = User.find(u[1].to_i)
        @admin.user_users.create(company: @company, userID: @user.id) if !@admin.user_users.find_by(company: @company, userID: @user.id)
        @company_user = CompanyUser.find_by(company: @company, user: @user)
        @company.user_users.create(user: @admin, userID: @user.id)
        if !@company_user.update(role: 'user')
          render json: {error: true}
          return
        end
      end
    end
    @company.company_users.where(role: 'inactive').each do |cu|
      @user = cu.user
      if @user.company_users.count == 1
        @user.destroy
      else
        cu.destroy
      end
    end
    render json: {success: true}
    return
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
      if params[:backoffice]
        redirect_to backoffice_company_teams_path(params[:backoffice], user: @user)
      else
  	    redirect_to dashboard_teams_path(edit_user: @user)
      end
    else
      flash[:alert] = 'Konnte Passwort nicht ändern!'
      if params[:backoffice]
        redirect_to backoffice_company_teams_path(params[:backoffice], user: @user)
      else
  	    redirect_to dashboard_teams_path(edit_user: @user)
      end
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
    if CompanyUser.find_by(user: @user, company: @admin_company, role: 'sroot')
  	  flash[:alert] = 'Du kannst diesen User nicht löschen!'
  	elsif @user.companies.count == 1
      @user.destroy
    else
      @user.company_users.find_by(company: @admin_company).destroy
      @user.department_users.each do |department|
        department.destroy if department.department.company == @admin_company
      end
      @user.team_users.each do |team|
        team.destroy if team.team.company == @admin_company
      end
      @admin.user_users.where(userID: @user.id).each do |user|
        user.destroy
      end
    end
	  redirect_to backoffice_company_path(@admin_company) if params[:site] == 'backoffice'
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
