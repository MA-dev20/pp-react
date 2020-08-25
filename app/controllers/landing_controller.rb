class LandingController < ApplicationController
  layout 'landing'
  before_action :check_user

  def index
  end

  def product
  end

  def contact
  end

  def blogs
  end

  def impressum
  end

  def datenschutz
  end

  def new_password
  end

  def accept_cookie
	cookies[:accepted] = {value: 'true', same_site: 'Lax'}
	redirect_to root_path
  end

  private
    def check_user
  	  if user_signed_in?
  		  redirect_to dashboard_path
  	  elsif User.where(bo_role: 'root').count == 0
  		  @company = Company.find_by(name: 'Peter Pitch GmbH')
  		  @company = Company.create(name: 'Peter Pitch GmbH', activated: true) if @company.nil?
  		  password = SecureRandom.urlsafe_base64(8)
        @user = User.find_by(email: 'resing@peterpitch.com')
        if @user
          @user.update(bo_role: 'root')
          CompanyUser.find_by(user: @user, company: @company).update(role: 'sroot')
        else
  		    @user = @company.users.create(fname: 'Jan Philipp', lname: 'Resing', bo_role: 'root', email: 'resing@peterpitch.com', password: password)
          CompanyUser.find_by(user: @user, company: @company).update(role: 'sroot')
  		    UserMailer.after_create(@user, password).deliver
        end
  	  end
	  end
end
