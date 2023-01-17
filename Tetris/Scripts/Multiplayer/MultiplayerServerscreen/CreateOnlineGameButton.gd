extends Button

onready var roomName = get_node("../HBoxContainer/NameLineEdit")
onready var password = get_node("../HBoxContainer2/PasswordLineEdit")


func _on_CreateOnlineGameButton_pressed():
	if (roomName.get_text() == ""):
		roomName.set_placeholder("Bitte Raumname eingeben")
	else:
		if (Globals.network.get_connection_status() == 2):
			get_node("/root/Root/MultiplayerScreen").createGame(roomName.get_text(), password.get_text())
