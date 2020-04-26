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
			  if(App.videoInProgress == true && data['game_state'] == 'changed') {
				  
			  } else if(data['game_state'] == 'changed'){
				  return window.location.reload();
			  }
			  if(data['rating'] == 'added' && $('#rating_count').length > 0) {
				  $('#rating_count').text(data['rating_count']);
			  }
			  if(data['comment_timer'] == 'start') {
				  App.commentTimer.restart();
			  }
			  if(data['comment_timer'] == 'stop') {
				  App.commentTimer.stop();
			  }
		  }
		});
		$(window).bind('beforeunload', function(){
      		App.game.unsubscribe()
    	});
	}
});
