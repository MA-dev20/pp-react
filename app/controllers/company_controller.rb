class CompanyController < ApplicationController
  before_action :check_user, except: [:register]
  before_action :set_company, only: [:login, :accept, :edit, :destroy, :edit_logo]
  def register
	if Company.find_by(name: company_params[:name]).nil?
	  @company = Company.new(company_params)
    @user = User.find_by(email: user_params[:email])
    @user = User.new(user_params) if !@user
	  if @company.save
	  begin
	    if @user.save!(:validate => false)
      @company.company_users.create(user: @user, role: 'root')
		  UserMailer.after_register(@user).deliver
		  @root = User.where(bo_role: "root").all
		  @root.each do |r|
			  UserMailer.new_company(r, @company).deliver
		  end
		  flash[:thanks_for_register] = 'Du hast dich erfolgreich registriert! Bitte warte bis sich einer unserer Wölfe bei dir meldet!'
		  redirect_to root_path
	    else
		  @company.destroy
		  flash[:alert] = 'Konnte User nicht erstellen!'
		  redirect_to root_path
	    end
		rescue ActiveRecord::RecordNotUnique
		  @company.destroy
		  flash[:alert] = 'User existiert schon!'
		   redirect_to root_path
		end
	  else
	    flash[:alert] = 'Konnte Unternehmen nicht erstellen!'
	    redirect_to root_path
	  end
	else
	  flash[:alert] = 'Du hast dich bereits registriert oder der Firmenname ist schon vergeben!'
	  redirect_to root_path
    end
  end

  def login
    company_login @company
    redirect_to dashboard_path
  end

  def new
	authorize! :create, Company
	@company = Company.new(company_params)
	@company.activated = true
	flash[:alert] = "Konnte Unternehmen nicht anlegen!" if !@company.save
	redirect_to backoffice_companies_path
  end

  def accept
	authorize! :manage, @company
	flash[:alert] = 'Konnte Unternehmen nicht aktivieren!' if !@company.update(activated: true)
	@user = @company.users.first
	password = SecureRandom.urlsafe_base64(8)
	flash[:alert] = 'Konnte User Passwort nicht setzen!' if !@user.update(password: password)
	UserMailer.after_activate(@user, password).deliver
	redirect_to backoffice_company_path(@company)
  end

  def edit
	authorize! :update, @company
  @company.update(company_params)
	redirect_to backoffice_company_path(@company) if params[:site] == 'backoffice_company'
	redirect_to dash_company_path if params[:site] == 'company_dash'
  end

  def edit_logo
	authorize! :update, @company
	@company.update(logo: params[:file]) if params[:file].present? && @company.present?
	render json: {file: @company.logo.url}
  end

  def destroy
	authorize! :destroy, @company
	if Company.first == @company
	  flash[:alert] = 'Du kannst Peter Pitch GmbH nicht löschen!!!!'
	elsif !@company.destroy
	  flash[:alert] = 'Konnte Unternehmen nicht löschen'
	end
	redirect_to backoffice_companies_path if params[:site] == 'backoffice_company'
  end

  private
	def company_params
	  params.require(:company).permit(:name, :logo, :employees, :message, :color_hex, :company_type)
	end
	def user_params
	  params.require(:company).permit(:fname, :lname, :phone, :email, :position)
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
