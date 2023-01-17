extends Button


func _on_Start_pressed():
	MusicController.setEffectsSoundState("ButtonPressed")
	get_node("/root/SceneSwitcher").save(Globals.highscorePoints, Globals.highscoreDeleteRows, Globals.highscoreTime, Globals.highscoreLevel)
	get_node("/root/SceneSwitcher").getCurrentScene().animationForNextScene()

func _on_Start_mouse_entered():
	get_node("/root/SceneSwitcher").getCurrentScene().mouseEnteredInButton(get_global_rect())
	MusicController.setEffectsSoundState("ButtonEntered")

func _on_Start_mouse_exited():
	get_node("/root/SceneSwitcher").getCurrentScene().mouseExitedFromButton()
