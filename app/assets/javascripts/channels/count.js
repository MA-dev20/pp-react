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
				  if( $('#count-reload').length > 0 ) {
				  	window.location.reload();
			  	} else {
					 	$('#count').text(data['count']);
						if (data['remove'] == true) {
							$('#user_'+data['user_id']).remove();
						} else {
					  	document.getElementById('ping').play();
					  	var left1 = Math.random() * 80;
					  	var userDiv;
					  	if (data['avatar']) {
					    	userDIV = '<img src="'+data['avatar']+'" style="left:' + left1 +'%;" id="user_'+data['user_id']+'">';
					  	} else {
								userDIV = '<div class="circle" style="left:' + left1 + '%;" id="user_'+data['user_id']+'">'+data['name']+'</div>';
					  	}
							if ($('#user_' + data['user_id']).length > 0) {
								$('#user_'+data['user_id']).remove();
							}
					  	$('#user-rain').append(userDIV);
						}
				  }
			  }
			  if (data['choose'] == true) {
				  if(data['site'] == 'left') {
					var userDIV;
					if (data['avatar']) {
				  		userDIV = '<div class="rain"><img src="'+data['avatar']+'"></div>';
					} else {
						userDIV = '<div class="rain"><div class="circle">'+data['name']+'</div></div>';
					}
					$('#left-img').addClass('pulse-single');
				  	$('.circle-left').append(userDIV);
					document.getElementById('ping').play();
				  } else {
					var userDIV;
					if (data['avatar']) {
				  		userDIV = '<div class="rain"><img src="'+data['avatar']+'"></div>';
					} else {
						userDIV = '<div class="rain"><div class="circle">'+data['name']+'</div></div>';
					}
					$('#right-img').addClass('pulse-single');
				  	$('.circle-right').append(userDIV);
					document.getElementById('ping').play();
				  }
			  }
			  if (data['objection'] == true) {
				  var userDiv = '<div class="objection"><div class="text" >'+data['objection_text']+'</div><div class="otimer">00:15</div></div>';
				  if(data['objection_sound'] != "") {
					  userDiv += '<audio src="'+data['objection_sound']+'" id="objection_sound" />'
				  }
				  $('#content').prepend(userDiv);
				  startObjectionTimer();
			  }
				if ( data["addTime"] == true ) {
					if(data["time"] == 10) {
							MyApp.timer.add10();
					}
					if(data["time"] == 20) {
							MyApp.timer.add20();
					}
					if(data["time"] == 30) {
							MyApp.timer.add30();
					}
				}
			  if (data['comment'] == true) {
				  var userDiv;
				  if(data['comment_user_avatar']) {
					 userDiv = '<div class="comment"><img src="'+data['comment_user_avatar']+'"><div class="text-bg">'+data['comment_text']+'</div><div class="text">'+data['comment_text']+'</div></div>';
				  } else {
					  userDiv = '<div class="comment"><div class="circle">'+data['name']+'</div><div class="text-bg">'+data['comment_text']+'</div><div class="text">'+data['comment_text']+'</div></div>';
				  }
					if (data['reverse'] == true) {
						$('#game_comments').prepend(userDiv);
					} else {
							$('#game_comments').append(userDiv);
					}
					if (data['hide'] == true) {
						$('#game_comments').fadeIn(1000);
						App.commentHideTimer.restart();
					}
			  }
			  if (data["emoji"] == true) {
				  var userDiv;
				  if(data['user_avatar']) {
					 userDiv = '<div class="comment"><img src="'+data['user_avatar']+'"><div class="emoji">'+data["emoji_icon"]+'</div>'
				  } else {
					  userDiv = '<div class="comment"><div class="circle">'+data['name']+'</div><div class="emoji">'+data["emoji_icon"]+'</div>'
				  }
					if (data['reverse'] == true) {
						$('#game_comments').prepend(userDiv);
					} else {
							$('#game_comments').append(userDiv);
					}
					if (data['hide'] == true) {
						$('#game_comments').fadeIn(1000);
						App.commentHideTimer.restart();
					}
			  }
		  }
		});
		$(window).bind('beforeunload', function(){
      		App.count.unsubscribe()
    	});
	}
});
