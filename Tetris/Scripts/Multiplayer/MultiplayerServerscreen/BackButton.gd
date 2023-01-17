extends Button


func _on_BackButton_pressed():
	MusicController.setEffectsSoundState("ButtonPressed")
	get_node("/root/SceneSwitcher/CurrentNode/MultiplayerScreen/Hud/VBoxContainer").hide()
	get_node("/root/SceneSwitcher/CurrentNode/MultiplayerScreen").closeConnection()
	
	get_node("/root/SceneSwitcher").createThread("res://Szenen/Titlescreen.tscn")


func _on_BackButton_mouse_entered():
	MusicController.setEffectsSoundState("ButtonEntered")
