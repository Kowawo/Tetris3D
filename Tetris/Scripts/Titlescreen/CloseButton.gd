extends Button


func _on_Close_pressed():
	get_tree().quit()

func _on_Close_mouse_entered():
	get_node("/root/SceneSwitcher").getCurrentScene().mouseEnteredInButton(get_global_rect())
	MusicController.setEffectsSoundState("ButtonEntered")

func _on_Close_mouse_exited():
	get_node("/root/SceneSwitcher").getCurrentScene().mouseExitedFromButton()
