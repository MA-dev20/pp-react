jQuery(document).ready(function() {
	var game;
	game = $('#game_channel');
	if ($('#game_channel').length > 0) {
		App.game = App.cable.subscriptions.create({
		   channel: "GamesChannel",
      	   game_id: game.data('game-id')
    	}, {
          connected: function() {
			  return console.log('connected');
		  },
          disconnected: function() {
			  return console.log('disconnected');
		  },
          received: function(data) {
			  if(App.videoInProgress && data['game_state'] == 'changed') {
				  
			  } if(data['game_state'] == 'changed'){
				  return window.location.reload();
			  }
		  }
		});
		$(window).bind('beforeunload', function(){
      		App.game.unsubscribe()
    	});
	}
});