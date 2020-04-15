class UserMailer < ApplicationMailer
  default from: 'noreply@peterpitch.de'
  def after_register(user)
	@user = user
	mail to: @user.email, subject: 'Willkommen bei Peter Pitch!'
  end
  def after_activate(user, password)
	@user = user
	@password = password
	mail to: @user.email, subject: 'Du wurdest freigeschaltet!'
  end
	
  def after_create(user, password)
	@user = user
	@password = password
	mail to: @user.email, subject: 'Herzlich Willkommen!'
  end
end