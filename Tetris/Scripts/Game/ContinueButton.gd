extends Button


func _on_ContinueButton_pressed():
	if (get_node("/root/SceneSwitcher/CurrentNode/Game").gameState == 3): # 5 = Reload
		get_node("/root/SceneSwitcher/CurrentNode/Game").changeGameState(5)
	else:
		get_node("/root/SceneSwitcher/CurrentNode/Game").changeGameState(1) # 1 = PLAYING
		get_node("/root/SceneSwitcher/CurrentNode/Game/Hud/PausedGameOverTexturRect").hide()
