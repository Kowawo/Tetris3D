extends Button


func _on_CancelOnlineGameButton_pressed():
	# LineEdits sichtbar machen
	get_node("/root/Root/MultiplayerScreen/Hud/VBoxContainer/HBoxContainer/TabContainer/Spiel hosten/HBoxContainer/VBoxContainer/HBoxContainer/NameLineEdit").show()
	get_node("/root/Root/MultiplayerScreen/Hud/VBoxContainer/HBoxContainer/TabContainer/Spiel hosten/HBoxContainer/VBoxContainer/HBoxContainer2/PasswordLineEdit").show()
	
	# Spiel beitreten Tab aktivieren
	get_node("/root/Root/MultiplayerScreen/Hud/VBoxContainer/HBoxContainer/TabContainer").set_tab_disabled(0, false)
	
	# Spiel erstellen - Button sichtbar machen
	get_node("/root/Root/MultiplayerScreen/Hud/VBoxContainer/HBoxContainer/TabContainer/Spiel hosten/HBoxContainer/VBoxContainer/CreateOnlineGameButton").show()
	
	# Beenden - Button unsichtbar machen
	get_node("/root/Root/MultiplayerScreen/Hud/VBoxContainer/HBoxContainer/TabContainer/Spiel hosten/HBoxContainer/VBoxContainer/CancelOnlineGameButton").hide()
	
	# Partikel hinzufügen
	get_node("/root/Root/MultiplayerScreen/Particles2D").hide()
	
	# Erstellten Raum löschen
	get_node("/root/Root/MultiplayerScreen").deleteGame()
