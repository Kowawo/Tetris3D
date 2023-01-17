extends Button


func _on_TitlescreenMenu_pressed():
	for child in get_node("/root/SceneSwitcher/CurrentNode/Game").get_children():
		if (child.has_method("hide") and child.name != "Platform"):
			child.hide()
	# Zum Hauptmenü
	get_node("/root/SceneSwitcher").createThread("res://Szenen/Titlescreen.tscn")
