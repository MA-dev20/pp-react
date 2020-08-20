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
	  cookies[:game] = {value: game.password, same_site: 'Lax'}
  end

  def current_game
	  @current_game ||= Game.where(password: cookies[:game], active: true).last
  end

  def game_logged_in?
	!current_game.nil?
  end

  def game_logout
    cookies.delete(:game)
	  @current_game = nil
  end

  def game_user_login(user)
	  cookies[:game_user] = {value: user.id, same_site: 'Lax'}
  end

  def current_game_user
	  @current_game_user ||= GameUser.find_by(id: cookies[:game_user]).user
  end

  def game_user_logged_in?
	  !current_game_user.nil?
  end

  def game_user_logout
	cookies.delete(:game_user)
	@current_game = nil
  end
end
