class ApplicationController < ActionController::Base
  before_action :prepare_exception_notifier
  include GamesHelper
  include LoginHelper

  private

  def prepare_exception_notifier
    if user_signed_in?
      request.env["exception_notifier.exception_data"] = {
        current_user: {id: current_user.id, fname: current_user.fname, lname: current_user.lname, email: current_user.email}
      }
    end
  end
end
