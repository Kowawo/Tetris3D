extends Button


func _on_Shop_pressed():
	MusicController.setEffectsSoundState("ButtonPressed")
	get_node("/root/SceneSwitcher").getCurrentScene().showShops()

func _on_Shop_mouse_entered():
	get_node("/root/SceneSwitcher").getCurrentScene().mouseEnteredInButton(get_global_rect())
	MusicController.setEffectsSoundState("ButtonEntered")

func _on_Shop_mouse_exited():
	get_node("/root/SceneSwitcher").getCurrentScene().mouseExitedFromButton()
