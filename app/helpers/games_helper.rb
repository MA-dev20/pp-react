module GamesHelper
  def generate_qr(text)
    qrcode = RQRCode::QRCode.new( text, :size => 5 )
	html = qrcode.as_html
  end

  def game_login(game)
	  cookies[:game] = {value: game.password, same_site: 'Lax'}
  end

  def current_game
	  @current_game ||= Game.where(password: cookies[:game]).last
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
	  @current_game_user ||= User.find_by(id: cookies[:game_user])
  end

  def game_user_logged_in?
	  !current_game_user.nil?
  end

  def game_user_logout
	cookies.delete(:game_user)
	@current_game = nil
  end
end
