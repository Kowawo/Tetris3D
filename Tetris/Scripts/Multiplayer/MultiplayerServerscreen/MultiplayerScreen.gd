extends Node


var connected = preload("res://Image/MultiplayerServerscreen/ServerConnected.png")
var disconnected = preload("res://Image/MultiplayerServerscreen/ServerDisconnected.png")

onready var particles2D = $Particles2D

var timeForReset = 5 # Alle x-Sekunden werden die Räume aktualisiert
var tmpTime = 0

func _process(delta):
	# Verbindung überprüfen
	if (Server.network.get_connection_status() == 0):
		Server.connectToServer(delta)
		connectionFailed()
	elif (Server.network.get_connection_status() == 2):
		connectionSucceeded()
	
	# Erstellte Räume anzeigen
	createRooms(delta)

func createRooms(delta):
	tmpTime += delta
	
	if (tmpTime > timeForReset):
		var vboxParent = get_node("Hud/VBoxContainer/HBoxContainer/TabContainer/Spiel beitreten/ScrollContainer/VBoxContainer")
		var hboxParent
		
		for child in vboxParent.get_children():
			child.queue_free()
		
		for i in range(Globals.rooms.size()):
			if(i % 3 == 0 and i > 0):
				vboxParent.add_child(hboxParent)
			
			if (i % 3 == 0):
				hboxParent = HBoxContainer.new()
			
			var hboxChild = HBoxContainer.new()
			hboxChild.set_alignment(1) # Center
			hboxChild.set_h_size_flags(3) #  Fill and Expand
			hboxChild.rect_min_size.y = 200
			
			var vbox = VBoxContainer.new()
			vbox.set_alignment(1) # Center
			
			var roomName = Label.new()
			roomName.set_text("Raum: " + Globals.rooms.keys()[i])
			roomName.set_align(1) # Center
			roomName.rect_min_size.y = 30
			
			var password = Label.new()
			password.set_text("Passwortgeschützt" if Globals.rooms.values()[i][0] else "Offen")
			password.set_align(1) # Center
			password.rect_min_size.y = 30
			
			var enterGame = Button.new()
			enterGame.set_text("Spiel beitreten")
			
			vbox.add_child(roomName)
			vbox.add_child(password)
			vbox.add_child(enterGame)
			
			hboxChild.add_child(vbox)
			
			hboxParent.add_child(hboxChild)
			
			if(i == Globals.rooms.size() - 1):
				vboxParent.add_child(hboxParent)
		
		tmpTime = 0


func createGame(roomName, password):
	Server.createGame(roomName, password)

func gameExists(boolean):
	if (!boolean):
		# LineEdits unsichtbar machen
		get_node("Hud/VBoxContainer/HBoxContainer/TabContainer/Spiel hosten/HBoxContainer/VBoxContainer/HBoxContainer/NameLineEdit").hide()
		get_node("Hud/VBoxContainer/HBoxContainer/TabContainer/Spiel hosten/HBoxContainer/VBoxContainer/HBoxContainer2/PasswordLineEdit").hide()
		
		# Spiel beitreten Tab deaktivieren
		get_node("Hud/VBoxContainer/HBoxContainer/TabContainer").set_tab_disabled(0, true)
		
		# Spiel erstellen - Button unsichtbar machen
		get_node("Hud/VBoxContainer/HBoxContainer/TabContainer/Spiel hosten/HBoxContainer/VBoxContainer/CreateOnlineGameButton").hide()
		
		# Beenden - Button sichtbar machen
		get_node("Hud/VBoxContainer/HBoxContainer/TabContainer/Spiel hosten/HBoxContainer/VBoxContainer/CancelOnlineGameButton").show()
		
		# Partikel hinzufügen
		particles2D.position = Vector2(OS.window_size.x / 2, OS.window_size.y / 2)
		particles2D.show()
	else:
		# Für den Spieler anzeigen, dass der Raumname schon vorhanden ist
		get_node("Hud/VBoxContainer/HBoxContainer/TabContainer/Spiel hosten/HBoxContainer/VBoxContainer/HBoxContainer/NameLineEdit").set_placeholder("Raum schon vorhanden")

func deleteGame():
	Server.deleteGame()

func closeConnection():
	Server.closeConnection()

func connectionFailed():
	$Hud/VBoxContainer/HBoxContainer2/HBoxContainer2/ServerTextureRect.set_texture(disconnected)
	$Hud/VBoxContainer/HBoxContainer2/HBoxContainer2/ServerConnectionLabel.set_text("Getrennt")

func connectionSucceeded():
	$Hud/VBoxContainer/HBoxContainer2/HBoxContainer2/ServerTextureRect.set_texture(connected)
	$Hud/VBoxContainer/HBoxContainer2/HBoxContainer2/ServerConnectionLabel.set_text("Verbunden")
