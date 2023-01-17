extends Spatial

enum { READY, PLAYING, PAUSED, DEAD, RELOAD}
var gameState = READY

var gridSize = Vector2(10, 20)


# Klasse für Cubes
var tetrominoClass = preload("res://Scripts/TetrominoClass.gd")
# 2D-Cube (für die Ansicht)
var cubeIn2D = preload("res://Objects/Cubes2D/Cube2D.tscn").instance()


# Zeitbestimmung für die automatische Bewegung der Tetromino
var timePeriod = 1
var tmpTimePeriod = timePeriod # Um die Zeit der fallenden Tetromino richtig einzustellen
# Gilt timeForMoveCubeAuto > timePeriod wird der Tetromino um eins nach unten versetzt
var timeForMoveCubeAuto = 0


# Achievement
# Werden Achievement erreicht, dann werden diese angezeigt,
# aber nur ein einziges mal pro Spiel
onready var achievementView = get_node("Hud/AchievementTextureRect")
var showAchievements = false
var achievements = {
	"highscoreDeleteRows" : true,
	"highscoreLevel" : true,
	"highscorePoints" : true,
	"highscoreTime" : true
}


# Spielervariablen
var level = 1
var points = 0
var playtime = 0
var deletedRows = 0

var createTetromino = true
var speedModus = false

var cubesInGame = []
var nextTetrominoView = [] # 2D-Ansicht

var randomNumberArr = [0, 1, 2, 3, 4, 5, 6]
var tetrominoPicker = 0

var playableCube
var playableTetromino = [] # Array mit dem momentanen Tetromino, welcher aus 4 Cubes besteht

var nextCube
var nextTetromino = [] # Array mit dem nächsten Tetromino, welcher aus 4 Cubes besteht


func getCubeInGame(position):
	return cubesInGame[position.x][position.y]


func setCubeInGame(position, cube, boolean):
	# Cube-Referenz
	cubesInGame[position.x][position.y][0] = cube
	# Position-Boolean
	cubesInGame[position.x][position.y][1] = boolean


func deleteAllCubes():
	for x in range(gridSize.x):
		for y in range(gridSize.y):
			if(!cubesInGame[x][y][1]):
				cubesInGame[x][y][0].getCube().queue_free()
				setCubeInGame(Vector2(x, y), null, true)


func newTetrominoPicker():
	tetrominoPicker = (tetrominoPicker + 1)  % randomNumberArr.size()
	if (tetrominoPicker == 0):
		randomNumberArr.shuffle()


func createNewTetromino(playable):
	var newCube = tetrominoClass.Tetromino.new(randomNumberArr[tetrominoPicker])
	newCube.setScale(Vector3(0.475, 0.475, 0.15))
	newCube.setMeshColor(newCube.getColor())
	
	newTetrominoPicker()
	
	if (playable):
		playableCube = newCube
	else:
		nextCube = newCube
	
	for vector in newCube.getTetrominoVector():
		var cubeDuplicate = newCube.duplicate()
		cubeDuplicate.setPosition(Vector3(int(gridSize.x / 2) + vector.x, gridSize.y - 2 + vector.y, 0))
		
		if (playable):
			get_node("CubesGrid").add_child(cubeDuplicate.getCube())
			playableTetromino.append(cubeDuplicate)
		else:
			nextTetromino.append(cubeDuplicate)


func nextTetrominoToPlayableTetromino(cube):
	# Nächste Figur wird als spielbare Figur übernommen
	playableCube = cube
	playableTetromino.clear()
	playableTetromino.append_array(nextTetromino)
	nextTetromino.clear()
	
	# GameOver-Status wird überprüft
	for vector in cube.getTetrominoVector():
		if (!getCubeInGame(Vector2(int(gridSize.x / 2) + vector.x, gridSize.y - 2 + vector.y))[1]):
			gameState = DEAD
			break
	
	if (gameState != DEAD):
		for cube in playableTetromino:
			get_node("CubesGrid").add_child(cube.getCube())


func createTetrominoView():
	Globals.cubeList2D.shuffle()
	
	if (nextTetrominoView.size() == 0):
		for vector in nextCube.getTetrominoVector():
			var cube = cubeIn2D.duplicate()
			# NextTetrominoView hinzufügen
			get_node("NextCubeView").add_child(cube)
			nextTetrominoView.append(cube)
	
	var tetrominoVector = nextCube.getTetrominoVector()
	for i in nextTetrominoView.size():
		nextTetrominoView[i].get_node("TextureRect").set_texture(Globals.cubeList2D[i])
		# NextTetrominoView platzieren
		var vector = tetrominoVector[i]
		if (nextCube.getName() == "O-Cube" or nextCube.getName() == "I-Cube"):
			nextTetrominoView[i].position = getCameraUnprojectPosition(Vector3(14.9 + vector.x, 17 + vector.y, 0))
		else:
			nextTetrominoView[i].position = getCameraUnprojectPosition(Vector3(14.4 + vector.x, 16 + vector.y, 0))


func moveAllowed(moveVector):
	var position
	var newPosition
	
	for cube in playableTetromino:
			position = cube.getPosition()
			newPosition = Vector3(position.x + moveVector.x, position.y + moveVector.y, 0)
			# Horizontale Bewegung
			if (newPosition.x < 0 or newPosition.x > gridSize.x - 1):
				return false
			# Vertikale Bewegung
			if (newPosition.y < 0):
				return false
			# Platz von einem fest platzierten Cube belegt
			if (!getCubeInGame(newPosition)[1]):
				return false
	return true


func moveTetromino(moveVector):
	var horizontalAllowed = true
	var verticalAllowed = true
	
	var position
	var newPosition
	
	# Horizontale Bewegung wird ausgeführt
	if (abs(moveVector.x) > 0):
		horizontalAllowed = moveAllowed(moveVector)
	# Verticale Bewegung wird ausgeführt
	else:
		verticalAllowed = moveAllowed(moveVector)
	
	# Bewegung ausführen
	if (horizontalAllowed and verticalAllowed):
		for cube in playableTetromino:
			position = cube.getPosition()
			newPosition = Vector3(position.x + moveVector.x, position.y + moveVector.y, 0)
			cube.setPosition(newPosition)
	# Wenn keine vertikale Bewegung mehr möglich ist, wird der Tetromino endgültig platziert
	elif (!verticalAllowed):
		# Wenn das Upgrade nicht aktiviert ist, dann wird das Tetromino normal platziert
		for cube in playableTetromino:
			position = cube.getPosition()
			setCubeInGame(position, cube, false)
		
		createTetromino = !createTetromino


func moveTetrominoAuto():
	if (speedModus or timeForMoveCubeAuto >= timePeriod):
		moveTetromino(Vector2(0, -1))
		timeForMoveCubeAuto = 0


func rotateAllowed(origin, newTetrominoVector):
	for i in playableTetromino.size():
		var newPosition = Vector3(origin.x + newTetrominoVector[i].x, origin.y + newTetrominoVector[i].y, 0)
		# Überprüft, ob die Figur trotz Rotierung horizontal im Spielfeld bleibt
		if (newPosition.x < 0 or newPosition.x > gridSize.x - 1):
			return false
		# Überprüft, ob die Figur trotz Rotierung vertikal im Spielfeld bleibt
		if (newPosition.y < 0 or newPosition.y > 19):
			return false
		# Überprüft, ob die Figur trotz Rotierung auf freie Positionen landet
		if (!getCubeInGame(newPosition)[1]):
			return false
	return true


func rotateTetromino(angle):
	var newTetrominoVector = []
	var tetrominoName = playableCube.getName()
	var origin = playableTetromino[0].getPosition()
	
	# Bei dem I-Cube muss der Ursprung verändert werden, um die spieltreue
	# Rotierung zu erhalten
	if (tetrominoName == "I-Cube"):
		# Drehung eines Punktes P um einen beliebigen Punkt Z
		# P' = Drehmatrix * ZP + OZ
		for vector in playableCube.getTetrominoVector():
			var p = (vector - playableTetromino[0].getOrigin()).rotated(angle) + playableTetromino[0].getOrigin()
			newTetrominoVector.append(Vector2(round(p.x), round(p.y)))
		playableTetromino[0].setOrigin(playableTetromino[0].getOrigin().rotated(angle))
	else:
		# Bei den restlichen Figuren können wir die Vektoren direkt rotieren
		for vector in playableCube.getTetrominoVector():
			newTetrominoVector.append(Vector2(round(vector.rotated(angle).x), round(vector.rotated(angle).y)))
	
	
	if (tetrominoName != "O-Cube"): # O-Cube muss nicht gedreht werden
		if (rotateAllowed(origin, newTetrominoVector)):
			if (tetrominoName != "I-Cube"):
				playableCube.setTetrominoVector(newTetrominoVector)
			else:
				# Die ursprünglichen Vektoren für den I-Cube müssen separiert rotiert werden
				# da der Ursprung beim erzeugen nicht im richtigen Ursprung liegt
				var tmp = []
				for vector in playableCube.getTetrominoVector():
					tmp.append(Vector2(round(vector.rotated(angle).x), round(vector.rotated(angle).y)))
				playableCube.setTetrominoVector(tmp)
				
			for cube in playableTetromino.size():
				var newPosition = Vector3(origin.x + newTetrominoVector[cube].x, origin.y + newTetrominoVector[cube].y, 0)
				playableTetromino[cube].setPosition(newPosition)
				playableTetromino[cube].setColor()
				playableTetromino[cube].getCube().get_node("MeshInstance").get_material_override().albedo_color = playableTetromino[cube].getColor()
	else:
		# Farbe vom O-Cube muss separiert geändert werden
		for cube in playableTetromino:
			cube.setColor()
			cube.getCube().get_node("MeshInstance").get_material_override().albedo_color = cube.getColor()


func checkIfRowIsFull():
	var countRowFull = 0
	
	var y = 0
	while y < gridSize.y:
		# Es wird überprüft, ob die Reihe y voll ist und die selbe Farbe besitzt
		var rowFull = true
		for x in range(gridSize.x):
			if (getCubeInGame(Vector2(x, y))[1]):
				rowFull = false
				break
		
		if (rowFull):
			countRowFull += 1
			# Wenn Reihe voll, dann wird sie entfernt
			for x in range(gridSize.x):
				var cube = getCubeInGame(Vector2(x, y))[0]
				setCubeInGame(Vector2(x, y), null, true) # Platz wird wieder freigegeben
				cube.getCube().queue_free() # Cube wird aus dem Spiel entfernt
			
			# Wenn Reihe entfernt, dann werden alle darüberliegenden Blöcke nach unten versetzt
			for i in range(y + 1, gridSize.y):
				for x in gridSize.x:
					var cube = getCubeInGame(Vector2(x, i))
					if (!cube[1]):
						var position = cube[0].getPosition()
						cube[0].setPosition(Vector3(position.x, position.y - 1, 0))
						setCubeInGame(Vector2(position.x, position.y - 1), cube[0], false)
						setCubeInGame(Vector2(position.x, position.y), null, true)
		else:
			y += 1
	
	if (countRowFull > 0):
		setLevelPointsRows(countRowFull)
		MusicController.setEffectsSoundState("RowIsFull")


func checkIfAchievement():
	# Wird ein Achievement angezeigt, wird gewartet bis das nächste angezeigt werden kann
	if (!showAchievements and achievementView.rect_position.y >= OS.window_size.y + achievementView.rect_size.y + 20):
		var label = $Hud/AchievementTextureRect/HBoxContainer/AchievementLabel
		if (deletedRows > Globals.highscoreDeleteRows and achievements["highscoreDeleteRows"]):
			label.set_text("Neue maximale gelöschte Reihen")
			achievements["highscoreDeleteRows"] = false
			showAchievements = true
		elif (level > Globals.highscoreLevel and achievements["highscoreLevel"]):
			label.set_text("Neues Höchstlevel")
			achievements["highscoreLevel"] = false
			showAchievements = true
		elif (points > Globals.highscorePoints and achievements["highscorePoints"]):
			label.set_text("Neue Höchstpunktzahl")
			achievements["highscorePoints"] = false
			showAchievements = true
		elif (playtime > Globals.highscoreTime and achievements["highscoreTime"]):
			label.set_text("Neue Höchstzeit")
			achievements["highscoreTime"] = false
			showAchievements = true
	
		if (showAchievements):
			MusicController.setEffectsSoundState("Achievement")
			$TimerAchievement.set_one_shot(true)
			$TimerAchievement.set_wait_time(5)
			$TimerAchievement.start()


func setLabelPosition():
	yield(get_tree().create_timer(0.01), "timeout")
	$Hud/Lines.set_position(getCameraUnprojectPosition(Vector3(17.75, 6.5, 0)) - $Hud/Lines.get_rect().size / 2)
	$Hud/Level.set_position(getCameraUnprojectPosition(Vector3(12.25, 6.5, 0)) - $Hud/Level.get_rect().size / 2)
	$Hud/Points.set_position(getCameraUnprojectPosition(Vector3(15, 9.5, 0)) - $Hud/Points.get_rect().size / 2)


func setLevelPointsRows(countDeletedRows):
	# Gelöschte Reihen aktualisieren
	deletedRows += countDeletedRows
	$Hud/Lines.set_text(str(deletedRows))
	
	# Level aktualisieren
	level = 1 + floor(deletedRows / 10)
	$Hud/Level.set_text(str(level))
	
	# Punkte aktualisieren
	# Je nach Anzahl der gelöschten Reihen gibt es mehr Punkte
	var tmpPoints = [40 * level, 100 * level, 300 * level, 1200 * level]
	points = points + tmpPoints[countDeletedRows - 1]
		
	$Hud/Points.set_text(str(points))
	
	# Beschleunigung erhöhen
	if (level > 1 and timePeriod > 0.5):
		timePeriod = tmpTimePeriod - 0.05 * level
	# Max Beschleunigung begrenzen
	if (timePeriod < 0.5):
		timePeriod = 0.5
	
	setLabelPosition()
	
	# Server
	if (get_tree().network_peer.get_connection_status() == 2): # 2 = connected
		get_node("/root/Root/Server").sendData(points, level, deletedRows)


func setTime():
	var hours = floor(playtime / 3600)
	var minutes = floor( (playtime - 3600 * hours) / 60)
	var seconds = round(playtime - 3600 * hours - 60 * minutes)
	
	if (str(hours).length() != 2):
		hours = "0" + str(hours)
	if (str(minutes).length() != 2):
		minutes = "0" + str(minutes)
	if (str(seconds).length() != 2):
		seconds = "0" + str(seconds)
	
	$Hud/Time.set_text(str(hours) + ":" + str(minutes) + ":" + str(seconds))
	
	checkIfAchievement()


func changeGameState(state):
	gameState = state


func getCameraUnprojectPosition(vector):
	return $Camera.unproject_position(vector)


func _ready():
	randomize()
	randomNumberArr.shuffle()
	
	# Hintergrundmusik wird geändert
	MusicController.setBackgroundSoundState("Game")
	
	# Grid erzeugen
	for x in range(gridSize.x):
		cubesInGame.append([])
		for _y in range(gridSize.y):
			cubesInGame[x].append([null, true])
	
	# Next/Lager-Ansicht-Tetromino skalieren und hinzufügen
	var distanceBetweenTwoCubes = getCameraUnprojectPosition(Vector3(0.65, 0, 0)).x - getCameraUnprojectPosition(Vector3(0, 0, 0)).x
	var scale = distanceBetweenTwoCubes / cubeIn2D.get_children()[0].rect_size.x
	cubeIn2D.get_children()[0].rect_scale = Vector2(scale, scale)


func _process(delta):
	match gameState:
		READY:
			pass # Warte bis Hud gezeichnet wurde oder Upgrades durchgeführt wurden
		PLAYING:
			# Achievements-Timer fortsetzen
			$TimerAchievement.set_paused(false)
			
			# Wenn keine spielbarer Tetromino vorhanden ist, wird einer erzeugt
			if (createTetromino):
				# Der allererste Tetromino wird erzeugt...
				if(nextTetromino.size() == 0):
					createNewTetromino(true) # true, weil spielbar
				# ...ansonsten wird der Nextcube übernommen
				else:
					# nextTetrominoToPlayableTetromino() überprüft den GameOver-Status. Falls dieser eintrifft
					# darf kein nextTetromino erzeugt werden, da diese sich dann überlagern
					nextTetrominoToPlayableTetromino(nextCube)
				
				checkIfRowIsFull() # Überprüft unter anderem, ob ein Upgrade freigeschalten wird
				
				if (gameState != DEAD):
					# Nächster Tetromino wird erzeugt
					createNewTetromino(false) # false, weil nicht spielbar
					
					# NextTetrominoView erstellen
					createTetrominoView()
				
				else:
					# Spiel speichern
					get_node("/root/Root").save(points, deletedRows, playtime, level)
				
				createTetromino = !createTetromino
				speedModus = false
			
			# Nach jeder Sekunde wird ein Input erzeugt,
			# sodass der spielbare Tetromino um ein Feld sinkt
			timeForMoveCubeAuto += delta
			moveTetrominoAuto()
			
			# Spieltzeit wird aktualisiert und das zugehörige Label angepasst
			playtime += delta
			setTime()
			
			# Achievements werden angezeigt
			if (showAchievements):
				if (achievementView.rect_position.y > OS.window_size.y - achievementView.rect_size.y - 20):
					achievementView.rect_position.y -= 120 * delta
			else:
				if (achievementView.rect_position.y < OS.window_size.y + achievementView.rect_size.y + 20):
					achievementView.rect_position.y += 120 * delta
			
		PAUSED:
			# Achievements-Timer pausieren
			$TimerAchievement.set_paused(true)
			
			# Menü anzeigen
			$Hud/PausedGameOverTexturRect.show()
			
			$Hud/PausedGameOverTexturRect/VBoxContainer/PauseLabel.show()
			$Hud/PausedGameOverTexturRect/VBoxContainer/GameOverLabel.hide()
			
			$Hud/PausedGameOverTexturRect/VBoxContainer/HBoxContainer/ContinueAgainButton.set_text("Weiterspielen?")
		
		DEAD:
			$Hud/PausedGameOverTexturRect.show()
			
			$Hud/PausedGameOverTexturRect/VBoxContainer/PauseLabel.hide()
			$Hud/PausedGameOverTexturRect/VBoxContainer/GameOverLabel.show()
			
			$Hud/PausedGameOverTexturRect/VBoxContainer/HBoxContainer/ContinueAgainButton.set_text("Nochmal?")
		
		RELOAD:
			# Alles zurücksetzen
			timeForMoveCubeAuto = 0
			
			timePeriod = 1
			tmpTimePeriod = timePeriod
			
			for achievement in achievements:
				achievements[achievement] = true
			
			level = 1
			points = 0
			playtime = 0
			deletedRows = 0
			
			setLevelPointsRows(deletedRows)
			
			createTetromino = true
			speedModus = false
			
			deleteAllCubes()
			
			for cube in playableTetromino:
				cube.getCube().queue_free()
			playableTetromino.clear()
			
			for cube in nextTetromino:
				cube.getCube().queue_free()
			nextTetromino.clear()
			
			for cube in nextTetrominoView:
				cube.queue_free()
			nextTetrominoView.clear()
			
			$Hud/PausedGameOverTexturRect.hide()
			
			# GameState ändern
			gameState = PLAYING


func _input(event):
	match gameState:
		PLAYING:
			# Bewegung der Tetrominos (Tastatur)
			if (Globals.moveKeyboard):
				if (event.is_action_pressed("Left")):
					moveTetromino(Vector2(-1, 0))
				
				if (event.is_action_pressed("Right")):
					moveTetromino(Vector2(1, 0))
				
				if (event.is_action_pressed("Down")):
					moveTetromino(Vector2(0, -1))
					timeForMoveCubeAuto = 0
				
				if (event.is_action_pressed("RotateLeft")):
					rotateTetromino(PI/2)
				
				if (event.is_action_pressed("RotateRight")):
					rotateTetromino(-PI/2)
				
				if (event.is_action_pressed("Accelerate")):
					speedModus = !speedModus
				
				if (event.is_action_pressed("Pause")):
					gameState = PAUSED
			
			else:
			# Bewegung der Tetrominos (Controller)
				if (event.is_action_pressed("LeftController")):
					moveTetromino(Vector2(-1, 0))
				
				if (event.is_action_pressed("RightController")):
					moveTetromino(Vector2(1, 0))
				
				if (event.is_action_pressed("DownController")):
					moveTetromino(Vector2(0, -1))
					timeForMoveCubeAuto = 0
				
				if (event.is_action_pressed("RotateLeftController")):
					rotateTetromino(PI/2)
				
				if (event.is_action_pressed("RotateRightController")):
					rotateTetromino(-PI/2)
				
				if (event.is_action_pressed("AccelerateController")):
					speedModus = !speedModus
				
				if (event.is_action_pressed("PauseController")):
					gameState = PAUSED
		
		PAUSED:
			if (event.is_action_pressed("Pause")):
				$Hud/PausedGameOverTexturRect.hide()
				gameState = PLAYING
		
		DEAD:
			if (event.is_action_pressed("Pause")):
				# Zum Hauptmenü
				get_node("/root/Root").createThread("res://Szenen/Titlescreen.tscn")

func _on_TimerAchievement_timeout():
	showAchievements = false
