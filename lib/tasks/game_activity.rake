namespace :game_activity do
  desc "TODO"
  task remove_game_due_to_inactivity: :environment do
  	@games = Game.where('id not in (?)',Game.where(updated_at: (Time.now - 1.hours)..Time.now).pluck(:id))
  	puts "found some games which are inactive " if @games.length > 0
  	@games.each do |game|
  		game.turns.update_all(status: "ended")
  		game.update(state: 'ended', active: false) 
  	end
  end
end
