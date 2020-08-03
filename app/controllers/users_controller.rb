class UsersController < ApplicationController
  before_action :check_user, except: [:edit_avatar]
  before_action :set_user, only: [:edit, :edit_avatar, :destroy, :root, :admin, :user]
  before_action :set_company, only: [:activate_users, :create, :root, :admin, :user]
  def create
	authorize! :create, User
	@user = User.new(user_params)
  @user.companies << @company
	password = SecureRandom.urlsafe_base64(8)
	@user.password = password
	if @user.save
	  begin
	  UserMailer.after_create(@user, password).deliver
	  rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
	    flash[:alert] = 'Falsche Mail-Adresse? Konnte Mail nicht senden!'
	  end
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

  def new_password
	@user = User.find_by(email: params[:user][:email])
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

  def activate_users
    if params[:users]
      params[:users].each do |u|
        @user = User.find(u[1].to_i)
        @company_user = CompanyUser.find_by(company: @company, user: @user)
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

  def root
    @company_user = CompanyUser.find_by(company: @company, user: @user)
	  @company_user.update(role: 'root')
    @ability = Ability.new(@user)
    if !@ability.can?(:create, @company.teams)
      @user.teams.where(company: @company).each do |t|
        t.destroy
      end
    end
	  render json: {user: @user, role: @company_user.role}
  end

  def admin
    @company_user = CompanyUser.find_by(company: @company, user: @user)
    if @company_user.role == 'root' && @company.company_users.where(role: 'root').count > 1
	    @company_user.update(role: 'admin')
      @ability = Ability.new(@user)
      if !@ability.can?(:create, @company.teams)
        @user.teams.where(company: @company).each do |t|
          t.destroy
        end
      end
    else
      flash[:alert] = 'Ein User muss Company Admin bleiben!'
      render json: {error: true}
    end
	  render json: {user: @user, role: @company_user.role}
  end

  def user
    @company_user = CompanyUser.find_by(company: @company, user: @user)
    if @company_user.role == 'root' && @company.company_users.where(role: 'root').count > 1
  	  if @company_user.role == 'inactive'
  	    password = SecureRandom.urlsafe_base64(8)
  	    @user.update(password: password)
        @company_user.update(role: 'user')
  	    begin
  	      UserMailer.after_create(@user, password).deliver
  	    rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
  	      flash[:alert] = 'Falsche Mail-Adresse? Konnte Mail nicht senden!'
          render json: {error: true}
  	    end
  	  else
  	    @company_user.update(role: "user")
        @ability = Ability.new(@user)
        if !@ability.can?(:create, @company.teams)
          @user.teams.where(company: @company).each do |t|
            t.destroy
          end
        end
  	  end
      render json: {user: @user, role: @company_user.role}
    else
      flash[:alert] = 'Ein User muss Company Admin bleiben!'
      render json: {error: true}
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
	  if user_signed_in?
	    @admin = current_user
	  else
	    flash[:alert] = 'Logge dich ein um dein Dashboard zu sehen!'
	    redirect_to root_path
	  end
	end
end
