module GameSoundHelper
  def wait_sound
	r = Random.rand(1...5)
	return 'game/wait/aufgeregt.mp3' if r == 1
	return 'game/wait/bereit.mp3' if r == 2
	return 'game/wait/kommando.mp3' if r == 3
	return 'game/wait/truppe.mp3'
  end
  def choose_sound
	r = Random.rand(1...11)
	return 'game/choose/2kandidaten.mp3' if r == 1
	return 'game/choose/2woelfe.mp3' if r == 2
	return 'game/choose/fingerauficons.mp3' if r == 3
	return 'game/choose/handesmartphones.mp3' if r == 4
	return 'game/choose/hatbegonnen.mp3' if r == 5
	return 'game/choose/ichhabefavoriten.mp3' if r == 6
	return 'game/choose/jetztabstimmen.mp3'if r == 7
	return 'game/choose/tipptaufden.mp3' if r == 8
	return 'game/choose/wahlehre.mp3' if r == 9
	return 'game/choose/werpitcht.mp3'
  end
  def turn_sound
	r = Random.rand(1...7)
	return 'game/turn/besonderescatchword.mp3' if r == 1
	return 'game/turn/glaskugel.mp3' if r == 2
	return 'game/turn/lettheshow.mp3' if r == 3
	return 'game/turn/naechstevertriebsleiter.mp3' if r == 4
	return 'game/turn/shakkaduschaffst.mp3' if r == 5
	return 'game/turn/wow.mp3'
  end
  def rate_sound
	r = Random.rand(1...4)
	return 'game/rate/haltemichraus.mp3' if r == 1
	return 'game/rate/lehnezurueck.mp3' if r == 2
	return 'game/rate/nichtschlecht.mp3'
  end
  def rating_sound
	r = Random.rand(1...11)
	return 'game/rating/befoerderung.mp3' if r == 1
	return 'game/rating/haettegekauft.mp3' if r == 2
	return 'game/rating/hopodertop.mp3' if r == 3
	return 'game/rating/ihrhabtbewertet.mp3' if r == 4
	return 'game/rating/jaaaaa.mp3' if r == 5
	return 'game/rating/neuerleitwolf.mp3' if r == 6
	return 'game/rating/staunen.mp3' if r == 7
	return 'game/rating/ueberzeugendeperformance.mp3' if r == 8
	return 'game/rating/wasfuereinpitch.mp3' if r == 9
	return 'game/rating/wolfoderwelpe.mp3'
  end
  def bestlist_sound
	r = Random.rand(1...5)
	return 'game/bestlist/runde.mp3' if r == 1
	return 'game/bestlist/trommelwirbel.mp3' if r == 2
	return 'game/bestlist/ueberzeugt.mp3' if r == 3
	return 'game/bestlist/vorne.mp3'
  end
end