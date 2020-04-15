jQuery(document).ready(function() {
	var count;
	count = $('#count_channel');
	if ($('#count_channel').length > 0) {
		App.count = App.cable.subscriptions.create({
		   channel: "CountChannel",
      	   game_id: count.data('game-id')
    	}, {
          connected: function() {
			  return console.log('connected');
		  },
          disconnected: function() {
			  return console.log('disconnected');
		  },
          received: function(data) {
			  if (data['state'] == 'wait') {
				  $('#count').text(data['count']);
				  document.getElementById('ping').play();
				  var left1 = Math.random() * 80;
				  var userDIV = '<img src="'+data['avatar']+'" style="left:' + left1 +'%;">';
				  $('#user-rain').append(userDIV);
			  }
			  if (data['choose'] == true) {
				  if(data['site'] == 'left') {
				  	var userDIV = '<div class="rain"><img src="'+data['avatar']+'"></div>';
					$('#left-img').addClass('pulse-single');
				  	$('.circle-left').append(userDIV);
					document.getElementById('ping').play();
				  } else {
					var userDIV = '<div class="rain"><img src="'+data['avatar']+'"></div>';
					$('#right-img').addClass('pulse-single');
				  	$('.circle-right').append(userDIV);
					document.getElementById('ping').play();
				  }
			  }
		  }
		});
		$(window).bind('beforeunload', function(){
      		App.count.unsubscribe()
    	});
	}
});