extends Button


func _on_Options_pressed():	
	MusicController.setEffectsSoundState("ButtonPressed")
	get_node("/root/SceneSwitcher").getCurrentScene().showOptions()

func _on_Options_mouse_entered():
	get_node("/root/SceneSwitcher").getCurrentScene().mouseEnteredInButton(get_global_rect())
	MusicController.setEffectsSoundState("ButtonEntered")

func _on_Options_mouse_exited():
	get_node("/root/SceneSwitcher").getCurrentScene().mouseExitedFromButton()
