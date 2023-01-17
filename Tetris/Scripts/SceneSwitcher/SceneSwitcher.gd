extends Spatial

# Daten speichern
func save(points, deleteRows, playtime, level):
	# Daten übernehemn
	if (points > Globals.highscorePoints):
		Globals.highscorePoints = points
	if (deleteRows > Globals.highscoreDeleteRows):
		Globals.highscoreDeleteRows = deleteRows
	if (playtime > Globals.highscoreTime):
		Globals.highscoreTime = playtime
	if (level > Globals.highscoreLevel):
		Globals.highscoreLevel = level
	
	# Daten in eine Variable speichern
	var data = {
		"moveKeyboard" : Globals.moveKeyboard,
		"fullscreen" : Globals.fullscreen,
		"resolutionIndex" : Globals.resolutionIndex,
		"borderless" : Globals.borderless,
		"mute": Globals.mute,
		"highscorePoints" : Globals.highscorePoints,
		"highscoreDelteRows" : Globals.highscoreDeleteRows,
		"highscoreTime" : Globals.highscoreTime,
		"highscoreLevel" : Globals.highscoreLevel,
		"framePicker" : Globals.framePicker
	}
	
	# Ordner, für bessere Struktur, erstellen, falls nicht vorhanden
	var dir = Directory.new()
	if (!dir.dir_exists("user://saves/")):
		dir.make_dir_recursive("user://saves/")
	
	# Daten abspeichern
	var file = File.new()
	var error = file.open("user://saves/save.dat", File.WRITE)
	if (error == OK):
		file.store_var(data)
		file.close()


# Daten laden
func loadSaveGame():
	var file = File.new()
	if (file.file_exists("user://saves/save.dat")):
		var error = file.open("user://saves/save.dat", File.READ)
		if (error == OK):
			var data = file.get_var()
			
			# Optionen
			Globals.moveKeyboard = data["moveKeyboard"]
			Globals.fullscreen = data["fullscreen"]
			Globals.resolutionIndex = data["resolutionIndex"]
			Globals.borderless = data["borderless"]
			Globals.mute = data["mute"]

			# Game
			Globals.highscorePoints = data["highscorePoints"]
			Globals.highscoreDeleteRows = data["highscoreDelteRows"]
			Globals.highscoreTime = data["highscoreTime"]
			Globals.highscoreLevel = data["highscoreLevel"]
			Globals.framePicker = data["framePicker"]
			
			file.close()


# Um eine nächste Szene zu laden und die alte entfernen
func createThread(path):
	var thread = Thread.new()
	thread.start(self, "goToScene", [ResourceLoader.load_interactive(path), thread])


func goToScene(arguments):
	var loader = arguments[0]
	var thread = arguments[1]
	
	$LoadingLabel.show()
	while loader.poll() == OK:
		$LoadingLabel.set_text("Laden " + str(round(float(loader.get_stage()) / loader.get_stage_count() * 100)) + " %")
	call_deferred("loadLevelDone", thread)
	$LoadingLabel.hide()
	
	return loader.get_resource()


func loadLevelDone(thread):
	var levelResource = thread.wait_to_finish()
	var scene = levelResource.instance()
	
	if (get_node("CurrentNode").get_child_count() > 0):
		get_node("CurrentNode").get_children()[0].queue_free()
	
	# Neue Szene hinzufügen
	get_node("CurrentNode").add_child(scene)

func getCurrentScene():
	return $CurrentNode.get_children()[0]

func _ready():
	loadSaveGame()
	createThread("res://Szenen/Titlescreen.tscn")
