module GamesHelper
  def build_catchwords(game, params)
	@game = game
	@wl = game.catchword_list
	@wl.catchwords.clear if !@wl.nil?
	@wl = CatchwordList.create(game_id: @game.id) if @wl.nil?
	params.each do |p|
	  @temp = CatchwordList.find(p)
	  @wl.catchwords << @temp.catchwords
	end
  end

  def build_objections(game, params)
	@game = game
	@ol = @game.objection_list
	@ol.objections.clear if !@ol.nil?
	@ol = ObjectionList.create(game_id: @game.id) if @ol.nil?
	params.each do |p|
	  @temp = ObjectionList.find(p)
	  @ol.objections << @temp.objections
	end
  end

  def generate_qr(text)
    qrcode = RQRCode::QRCode.new( text, :size => 5 )
	html = qrcode.as_html
  end

  def game_login(game)
	session[:game_id] = game.id
  end

  def current_game
	@current_game ||= Game.find_by(id: session[:game_id])
  end

  def game_logged_in?
	!current_game.nil?
  end

  def game_logout
	session.delete(:game_id)
	@current_game = nil
  end

  def game_user_login(user)
	session[:game_user_id] = user.id
  end

  def current_game_user
	@current_game_user ||= User.find_by(id: session[:game_user_id])
  end

  def game_user_logged_in?
	!current_game_user.nil?
  end

  def game_user_logout
	session.delete(:game__user_id)
	@current_game = nil
  end
end
