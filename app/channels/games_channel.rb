class GamesChannel < ApplicationCable::Channel
  def subscribed
	stop_all_streams
	stream_from "game_#{params['game_id']}_channel"
  end

  def unsubscribed
	stop_all_streams
	puts "unsubscribed"
  end
	
  def send_message(data)
  end
end