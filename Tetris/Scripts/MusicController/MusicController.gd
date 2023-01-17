extends Node


# Wird abgespielt, wenn der Spieler sich im Titlescreen befindet
# Entfernt aus Lizengründen
# var menuBackgroundMusic = preload("res://Music/Background/Tetris.mp3")
# Wird abgespielt, wenn der Spieler sich im Spiel befindet
var gameBackgroundMusic = preload("res://Music/Background/TetrisGameBeat.mp3")

# Wird abgespielt, wenn das Grid im Spiel gezeichnet wird
var particleDrawingSound = preload("res://Music/Effects/ParticleDrawing.mp3")
# Wird abgespielt, wenn der Mauszeiger die Buttonfläche betritt
var buttonEnteredSound = preload("res://Music/Effects/ButtonEntered.mp3")
# Wird abgespielt, wenn ein Button betätigt wird
var buttonPressedSound = preload("res://Music/Effects/ChooseButton.mp3")
# Wird abgespielt, wenn eine Reihe im Spiel voll ist und entfernt wurde
var rowIsFullSound = preload("res://Music/Effects/RowIsFull.mp3")
# Wird abgespielt, wenn ein Achievement freigeschaltet wurde
var achievementSound = preload("res://Music/Effects/Achievement.mp3")


# Musik für den Hintergrund
var backgroundSoundState setget setBackgroundSoundState

func setBackgroundSoundState(value):
	if (backgroundSoundState != value):
		backgroundSoundState = value
		changeBackgroundMusic()

func changeBackgroundMusic():
	match backgroundSoundState:
		"Titlescreen":
			setBackgroundMusic(gameBackgroundMusic)
		"Game":
			setBackgroundMusic(gameBackgroundMusic)


# Effekte, welche abgespielt werden
var effectsSoundState setget setEffectsSoundState

func setEffectsSoundState(value):
	effectsSoundState = value
	changeEffectsMusic()

func changeEffectsMusic():
	match effectsSoundState:
		# keinen neuen SoundEffect starten
		"AwaitSound":
			pass
		"ButtonEntered":
			setEffectAudio(buttonEnteredSound)
		"ButtonPressed":
			setEffectAudio(buttonPressedSound)
		"ParticleDrawing":
			setEffectAudio(particleDrawingSound)
		"RowIsFull":
			setEffectAudio(rowIsFullSound)
		"Achievement":
			setEffectAudio(achievementSound)


func _on_BGMTween_tween_completed(_object, _key):
	if ($BackgroundMusic.volume_db == -40):
		$BackgroundMusic._set_playing(false)
		changeBackgroundMusic()

func setBackgroundMusic(audio):
	# Wenn ein Hintergrund abgespielt wird, wird ein weicher Übergang erzeugt
	if ($BackgroundMusic.is_playing()):
		$BGMTween.interpolate_property($BackgroundMusic, "volume_db", $BackgroundMusic.volume_db, -40, 3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	else:
		$BackgroundMusic.set_stream(audio)
		$BackgroundMusic._set_playing(true)
		$BGMTween.interpolate_property($BackgroundMusic, "volume_db", $BackgroundMusic.volume_db, -10, 3, Tween.TRANS_QUART, Tween.EASE_OUT)
	
	$BGMTween.start()

func setEffectAudio(audio):
	var audioPlayed = false
	for child in $Effects.get_children():
		if (!child.is_playing()):
			child.stream = audio
			audioPlayed = true
			child.play()
			break
	
	if (!audioPlayed):
		var newEffect = $Effects/Effect1.duplicate()
		$Effects.add_child(newEffect)
		newEffect.stream = audio
		newEffect.play()


func setMute():
	AudioServer.set_bus_mute(0, not AudioServer.is_bus_mute(0))

func getMute():
	return AudioServer.is_bus_mute(0)

func stopEffect(audioname):
	for child in $Effects.get_children():
		if (child.get_stream().resource_path.get_file().get_basename() == audioname):
			child.stop()
			break
