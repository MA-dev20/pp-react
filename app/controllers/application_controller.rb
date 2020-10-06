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
    elsif game_user_logged_in? && game_logged_in?
      request.env["exception_notifier.exception_data"] = {
        game_user: {id: current_game_user.id, fname: current_game_user.fname, lname: current_game_user.lname, email: current_game_user.email},
        game: {id: current_game.id, pitch: current_game.pitch_id}
      }
    elsif game_logged_in?
      request.env["exception_notifier.exception_data"] = {
        game: {id: current_game.id, pitch: current_game.pitch_id}
      }
    elsif game_user_logged_in?
      request.env["exception_notifier.exception_data"] = {
        game_user: {id: current_game_user.id, fname: current_game_user.fname, lname: current_game_user.lname, email: current_game_user.email}
      }
    end
  end
end
