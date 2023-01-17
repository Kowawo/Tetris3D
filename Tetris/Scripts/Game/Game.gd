extends Spatial

enum { READY, PLAYING, PAUSED, DEAD, UPGRADE, RELOAD}
var gameState = READY

var gridSize = Vector2(10, 20)


# Klasse für Cubes
var TetrominoClass = preload("res://Scripts/TetrominoClass.gd")

# 2D-Cube (für die Ansicht)
var cubeIn2D = preload("res://Objects/Cubes2D/Cube2D.tscn").instance()


# Zeitbestimmung für die automatische Bewegung der Tetromino
var timePeriod = 1
var tmpTimePeriod = timePeriod # Um die Zeit der fallenden Tetromino richtig einzustellen
# Gilt timeForMoveCubeAuto > timePeriod wird der Tetromino um eins nach unten versetzt
var timeForMoveCubeAuto = 0


# Upgrades
onready var upgradeView = get_node("Hud/UpgradesTextureRect")
var showUpgrades = false
var upgradeLevel = 0
# Upgrades 1 - Variablen
var doublePoints = false
var gravityToNull = false
var nextTetrominoBomb = false
var storage = false
# Upgrades 2 - Variablen
var assistance = false
var sameColor = false
var closeAllGap = false
var extraLife = false


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

var storeCube
var storeTetromino = [] # Array mit dem eingelagerten Tetromino, welcher aus 4 Cubes besteht
var storeTetrominoView = [] # 2D-Ansicht

var assistanceCube
var assistanceTetromino = [] # Array mit dem Assistance-Tetromino, welcher aus 4 Cubes besteht

var deactivatedCubes = [] # Array mit allen Cubes, bei denen das Licht deaktiviert wurde



func randomInt(a, b):
	randomize()
	return rand_range(a, b)


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


func closeAllGaps():
	for x in gridSize.x:
		var y = 1
		while y < gridSize.y:
			var cube = getCubeInGame(Vector2(x, y))
			# Es befindet sich ein Cube auf diese Position
			if (!cube[1]):
				# Nun wird von unten nach oben ein freier Platz gesucht
				for i in range(y):
					var tmp = getCubeInGame(Vector2(x, i))
					# Der Platz ist frei und der Cube wird auf diese Position verschoben
					if (tmp[1]):
						cube[0].setPosition(Vector3(x, i, 0))
						setCubeInGame(Vector2(x, i), cube[0], false)
						setCubeInGame(Vector2(x, y), null, true)
						break
			y += 1


func newTetrominoPicker():
	tetrominoPicker = (tetrominoPicker + 1)  % randomNumberArr.size()
	if (tetrominoPicker == 0):
		randomNumberArr.shuffle()


func createNewTetromino(playable):
	var newCube = TetrominoClass.new(randomNumberArr[tetrominoPicker], sameColor)
	var omniLight = newCube.getCube().get_node("OmniLight")
	omniLight.set_param(0, 100)
	newCube.setScale(Vector3(0.475, 0.475, 0.15))
	newCube.setMeshColor(newCube.getColor())
	
	newTetrominoPicker()
	
	if (playable):
		playableCube = newCube
	else:
		nextCube = newCube
	
	for vector in newCube.getTetrominoVector():
		var cubeDuplicate = newCube.dup()
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
			# Besitzt der Spieler ein Extra-Leben, dann wird das Grid zurückgesetzt
			if (extraLife):
				deleteAllCubes()
				extraLife = false
			else:
				gameState = DEAD
			break
	
	if (gameState != DEAD):
		for cube in playableTetromino:
			get_node("CubesGrid").add_child(cube.getCube())
	
	# Lager wieder aktivieren, falls der Effekt zuvor aktiviert war
	if (storeTetromino.size() != 0):
		storage = true


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
		if (nextCube.getName() == "O-Tetromino" or nextCube.getName() == "I-Tetromino"):
			nextTetrominoView[i].position = getCameraUnprojectPosition(Vector3(14.9 + vector.x, 17 + vector.y, 0))
		else:
			nextTetrominoView[i].position = getCameraUnprojectPosition(Vector3(14.4 + vector.x, 16 + vector.y, 0))


func disableLightOfCubes():
	var i = 2 + deactivatedCubes.size()
	while (i <= level):
		var randomNumber = randomInt(0, $CubesGrid.get_child_count() - 1)
		var cube = $CubesGrid.get_children()[randomNumber]
		if (cube.get_node("OmniLight").visible):
			cube.get_node("OmniLight").hide()
			deactivatedCubes.append([cube, 0])
			i += 1
		if i == 11 or i > $CubesGrid.get_child_count():
			break


func turnLightOnOfCubes():
	var i = 0
	while (i < deactivatedCubes.size()):
		var cube = deactivatedCubes[i][0]
		
		if (deactivatedCubes[i][1] >= randomInt(0, 100)):
			cube.get_node("OmniLight").show()
			deactivatedCubes.remove(i)
		else:
			deactivatedCubes[i][1] += 10
			i += 1


func createAssistance():
	if (assistance and assistanceTetromino.size() == 0):
		assistanceCube = playableCube.dup()
		assistanceCube.setScale(Vector3(0.475, 0.475, 0))
		
		# Licht deaktivieren
		assistanceCube.getCube().get_node("OmniLight").hide()
		
		# Neues Material erzeugen
		var material = SpatialMaterial.new()
		material.albedo_color = assistanceCube.getColor()
		assistanceCube.getCube().get_node("MeshInstance").set_material_override(material)
		
		# Assistance-Tetromino hinzufügen
		for vector in assistanceCube.getTetrominoVector():
			var cubeDuplicate = assistanceCube.dup()
			get_node("AssistanceCube").add_child(cubeDuplicate.getCube())
			assistanceTetromino.append(cubeDuplicate)
	
	var originCube = playableTetromino[0]
	var tetrominoVector = playableCube.getTetrominoVector()
	# Neue Position für den Assistent-Origin-Cube
	var newPosition = Vector3(originCube.getPosition().x, 0, 0)
	
	# Von oben nach unten durchlaufen
	for y in range(originCube.getPosition().y, -1, -1):
		# Überprüfe, ob jeder Assistent-Cube einen freien Platz besitzt
		for vector in tetrominoVector:
			if (!getCubeInGame(Vector2(newPosition.x + vector.x, y + vector.y))[1] or y + vector.y < 0):
				# Kein freier Platz für einen Cube des Assistent-Tetrominos
				newPosition = Vector3(newPosition.x, y + 1, 0)
				break
		
		# Abbruchbedingung für die erste for-Schleife
		if (newPosition.y != 0):
			break
		
	# Assistance-Tetromino positionieren und MeshInstance-Albedo ändern
	for i in assistanceTetromino.size():
		assistanceTetromino[i].setPosition(Vector3(newPosition.x + tetrominoVector[i].x, newPosition.y + tetrominoVector[i].y, 0))
		assistanceTetromino[i].setMeshColor(originCube.getColor())


func setStoreTetromino():
	# Der momentane Tetromino
	playableCube.setTetrominoVector(playableCube.getTetrominoOriginalVector())
	for i in playableTetromino.size():
			# wird unsichtbar gestellt
			playableTetromino[i].getCube().hide()
			# und auf die Startposition positioniert
			var vector = playableCube.getTetrominoVector()[i]
			playableTetromino[i].setPosition(Vector3(int(gridSize.x / 2) + vector.x, gridSize.y - 2 + vector.y, 0))
	
	# Überprüft, ob das Lager leer ist
	if (storeTetromino.size() == 0):
		# Wenn das Lager leer ist, wird der momentane spielbare Tetromino
		# ins Lager verfrachtet,
		storeCube = playableCube
		storeTetromino.append_array(playableTetromino)
		
		# und der nächste Tetromino spielbar
		createTetromino = true
		
		# Zusätzlich wird eine Ansicht hinzugefügt
		for vector in storeCube.getTetrominoOriginalVector():
			var cube = cubeIn2D.duplicate()
			get_node("StoreCubeView").add_child(cube)
			storeTetrominoView.append(cube)
		
	else:
		# sowie mit dem Cube im Lager getauscht
		var tmpCube = playableCube
		playableCube = storeCube
		storeCube = tmpCube
		
		# Lager-Tetromino sichtbar machen
		for cube in storeTetromino:
			cube.getCube().show()
		
		# und mit dem spielbare Tetromino mit dem eingelagerten Tetromino getauscht
		var tmpTetromino = playableTetromino
		playableTetromino = storeTetromino
		storeTetromino = tmpTetromino
		
	# Zusätzlich wird die aktuelle Ansicht aktualisiert
	Globals.cubeList2D.shuffle()
	for i in storeCube.getTetrominoOriginalVector().size():
		# Lager-Ansicht-Tetromino platzieren
		var cube = storeTetrominoView[i]
		var vector = storeCube.getTetrominoOriginalVector()[i]
		
		# Farbe wechseln
		storeTetrominoView[i].get_node("TextureRect").set_texture(Globals.cubeList2D[i])
		
		if (storeCube.getName() == "O-Tetromino" or storeCube.getName() == "I-Tetromino"):
			cube.position = getCameraUnprojectPosition(Vector3(-5.9 + vector.x, 17 + vector.y, 0))
		else:
			cube.position = getCameraUnprojectPosition(Vector3(-6.5 + vector.x, 16 + vector.y, 0))
	
	# Zudem wird die Lagerung solange blockiert, bis der nächste Tetromino platziert wurde
	# da somit das dauerhafte Wechseln zwischen dem Lager-Tetromino und dem spielbaren Tetromino
	# verhindert wird
	storage = false # wird wieder in der Funktion nextTetrominoToPlayableTetromino aktiviert


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
		if (nextTetrominoBomb):
			# Ist das Upgrade aktiviert, dann werden die Zeilen und die Reihen
			# inklusive Tetromino aus dem Spiel entfernt
			# Zusätzlich gib es pro entfernten Cube 100 Punkte
			var countDeletedCubes = 0
			for cube in playableTetromino:
				position = cube.getPosition()
				for y in gridSize.y:
					var tmpCube = getCubeInGame(Vector2(position.x, y))
					if (!tmpCube[1]):
						tmpCube[0].getCube().queue_free()
						setCubeInGame(Vector2(position.x, y), null, true)
						countDeletedCubes += 1
				for x in gridSize.x:
					var tmpCube = getCubeInGame(Vector2(x, position.y))
					if (!tmpCube[1]):
						tmpCube[0].getCube().queue_free()
						setCubeInGame(Vector2(x, position.y), null, true)
						countDeletedCubes += 1
				countDeletedCubes += 1
			
			# Spielbarer Cube löschen
			for cube in playableTetromino:
				cube.getCube().queue_free()
				countDeletedCubes += 1
			
			closeAllGaps()
			nextTetrominoBomb = false
			
			# Punkte werden korrigiert
			points = points + 100 * countDeletedCubes
			$Hud/Points.set_text(str(points))
			setLabelPosition()
		else:
			# Wenn das Upgrade nicht aktiviert ist, dann wird das Tetromino normal platziert
			for cube in playableTetromino:
				position = cube.getPosition()
				setCubeInGame(position, cube, false)
		
		createTetromino = !createTetromino


func moveTetrominoAuto(delta):
	timeForMoveCubeAuto += delta
	if (!gravityToNull and timeForMoveCubeAuto >= timePeriod):
		moveTetromino(Vector2(0, -1))
		timeForMoveCubeAuto = 0
	elif(speedModus):
		for _i in range(ceil(50 / (1 / delta))):
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
	
	var indexInkDek = -1 if angle > 0 else 1
	
	# Bei dem I-Tetromino muss der Ursprung verändert werden, um die spieltreue
	# Rotierung zu erhalten
	if (tetrominoName == "I-Tetromino"):
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
	
	
	if (tetrominoName != "O-Tetromino"): # O-Tetromino muss nicht gedreht werden
		if (rotateAllowed(origin, newTetrominoVector)):
			if (tetrominoName != "I-Tetromino"):
				playableCube.setTetrominoVector(newTetrominoVector)
			else:
				# Die ursprünglichen Vektoren für den I-Tetromino müssen separiert rotiert werden
				# da der Ursprung beim erzeugen nicht im richtigen Ursprung liegt
				var tmp = []
				for vector in playableCube.getTetrominoVector():
					tmp.append(Vector2(round(vector.rotated(angle).x), round(vector.rotated(angle).y)))
				playableCube.setTetrominoVector(tmp)
				
			for cube in playableTetromino.size():
				var newPosition = Vector3(origin.x + newTetrominoVector[cube].x, origin.y + newTetrominoVector[cube].y, 0)
				playableTetromino[cube].setPosition(newPosition)
				playableTetromino[cube].setColor(indexInkDek)
				playableTetromino[cube].getCube().get_node("MeshInstance").get_material_override().albedo_color = playableTetromino[cube].getColor()
	else:
		# Farbe vom O-Tetromino muss separiert geändert werden
		for cube in playableTetromino:
			cube.setColor(indexInkDek)
			cube.getCube().get_node("MeshInstance").get_material_override().albedo_color = cube.getColor()


func checkIfRowIsFull():
	# Aktiviert das Licht der Cubes
	turnLightOnOfCubes()
	
	var countRowFull = 0
	var countSameColor = 0
	
	var y = 0
	while y < gridSize.y:
		# Es wird überprüft, ob die Reihe y voll ist und die selbe Farbe besitzt
		var rowFull = true
		var sameColorInRow = true
		for x in range(gridSize.x):
			if (getCubeInGame(Vector2(x, y))[1] or !getCubeInGame(Vector2(x, y))[0].getCube().get_node("OmniLight").visible):
				rowFull = false
				break # Falls kein Cube sich auf dieser Position befindet können wir direkt abbrechen
			if (x > 0 and getCubeInGame(Vector2(x, y))[0].getColor() != getCubeInGame(Vector2(x - 1, y))[0].getColor()):
				sameColorInRow = false
		
		if (rowFull):
			countRowFull += 1
			
			# Wenn Reihe voll, dann wird sie entfernt
			var animationCubes = []
			for x in range(gridSize.x):
				animationCubes.append(getCubeInGame(Vector2(x, y))[0])
				setCubeInGame(Vector2(x, y), null, true) # Platz wird wieder freigegeben
			
			# Animation
			gameState = READY
			$AnimationController.animateCubes(animationCubes, Globals.animationName)
			MusicController.setEffectsSoundState("RowIsFull")
			yield($AnimationController, "animationCompleted")
			gameState = PLAYING
			
			# Wenn Reihe entfernt, dann werden alle darüberliegenden Blöcke nach unten versetzt
			for i in range(y + 1, gridSize.y):
				for x in gridSize.x:
					var cube = getCubeInGame(Vector2(x, i))
					if (!cube[1]):
						var position = cube[0].getPosition()
						cube[0].setPosition(Vector3(position.x, position.y - 1, 0))
						setCubeInGame(Vector2(position.x, position.y - 1), cube[0], false)
						setCubeInGame(Vector2(position.x, position.y), null, true)
			
			if (sameColorInRow):
				countSameColor += 1
		else:
			y += 1
	
	if (countSameColor > 0):
		upgradeLevel = countSameColor
		showUpgrades = checkIfUpgrade()
	
	if (countRowFull > 0):
		setLevelPointsRows(countRowFull)
	
	# Deaktiviere das Licht der Cubes je nach Level
	disableLightOfCubes()


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


func checkIfUpgrade():
	match upgradeLevel:
		1:
			if (doublePoints or assistance):
				return false
		2:
			if (storage or sameColor):
				return false
		3:
			if (gravityToNull or nextTetrominoBomb):
				return false
		4:
			if (extraLife or closeAllGap):
				return false
	return true


func setLabelPosition():
	yield(get_tree(), "idle_frame")
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
	
	if (doublePoints):
		points = points + tmpPoints[countDeletedRows - 1] * 2
	else:
		points = points + tmpPoints[countDeletedRows - 1]
		
	$Hud/Points.set_text(str(points))
	
	# Beschleunigung erhöhen
	if (level > 1 and timePeriod > 0.3):
		timePeriod = tmpTimePeriod - 0.05 * level
	# Max Beschleunigung begrenzen
	if (timePeriod < 0.3):
		timePeriod = 0.3
	
	setLabelPosition()


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
	
	for i in range(level - get_node("AnimationController/Lights").get_child_count()):
		$AnimationController.lightSplineAnimate()
		if i == 9:
			break
	
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
			
			# Upgrades-Timer fortsetzen
			$Hud/GravityToNullLabel/TimerGravityToNull.set_paused(false)
			$Hud/SameColorLabel/TimerSameColor.set_paused(false)
			
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
				
				# Überprüft unter anderem, ob ein Upgrade freigeschalten wird
				checkIfRowIsFull()
				
				if (gameState != DEAD):
					# Nächster Tetromino wird erzeugt
					createNewTetromino(false) # false, weil nicht spielbar
					
					# NextTetrominoView erstellen
					createTetrominoView()
				
				else:
					# Spiel speichern
					get_node("/root/SceneSwitcher").save(points, deletedRows, playtime, level)
				
				createTetromino = !createTetromino
				speedModus = false
			
			# Nach jeder Sekunde wird ein Input erzeugt,
			# sodass der spielbare Tetromino um ein Feld sinkt
			moveTetrominoAuto(delta)
			
			# Spieltzeit wird aktualisiert und das zugehörige Label angepasst
			playtime += delta
			setTime()
			
			# Wenn der Assistent aktiviert wird dieser platziert
			createAssistance()
			
			# Achievements werden angezeigt
			if (showAchievements):
				if (achievementView.rect_position.y > OS.window_size.y - achievementView.rect_size.y - 20):
					achievementView.rect_position.y -= 120 * delta
			else:
				if (achievementView.rect_position.y < OS.window_size.y + achievementView.rect_size.y + 20):
					achievementView.rect_position.y += 120 * delta
			
			# Upgrades werden angezeigt
			if (showUpgrades):
				gameState = UPGRADE
			
		PAUSED:
			# Achievements-Timer pausieren
			$TimerAchievement.set_paused(true)
			
			# Upgrades-Timer pausieren
			$Hud/GravityToNullLabel/TimerGravityToNull.set_paused(true)
			$Hud/SameColorLabel/TimerSameColor.set_paused(true)
			
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
			
			_on_GravityToNullTextureProgress_value_changed(100)
			_on_SameColorTextureProgress_value_changed(100)
			
		UPGRADE:
			# Achievements-Timer pausieren
			$TimerAchievement.set_paused(true)
			
			# Upgrades-Timer pausieren
			$Hud/GravityToNullLabel/TimerGravityToNull.set_paused(true)
			$Hud/SameColorLabel/TimerSameColor.set_paused(true)
			
			# Array von den linken TextureButtons initialisieren
			var upgrade1path = "Hud/UpgradesTextureRect/HBoxContainer/HBoxContainer1/VBoxContainer/"
			var upgrade1TextureButtons = [
				get_node(upgrade1path + "Upgrade1"),
				get_node(upgrade1path + "Upgrade2"),
				get_node(upgrade1path + "Upgrade3"),
				get_node(upgrade1path + "Upgrade4")
			]
			# Zugehöriges Label
			var upgrade1Label = get_node(upgrade1path + "Upgrade1Label")
			
			# Array von den rechten TextureButtons initialisieren
			var upgrade2path = "Hud/UpgradesTextureRect/HBoxContainer/HBoxContainer2/VBoxContainer/"
			var upgrade2TextureButtons = [
				get_node(upgrade2path + "Upgrade1"),
				get_node(upgrade2path + "Upgrade2"),
				get_node(upgrade2path + "Upgrade3"),
				get_node(upgrade2path + "Upgrade4")
			]
			# Zugehöriges Label
			var upgrade2Label = get_node(upgrade2path + "Upgrade2Label")
			
			# Es werden nur die nötigen TexturButtons angezeigt, die restlichen werden unsichtbar
			for i in range(len(upgrade1TextureButtons)):
				var boolean = (i == upgradeLevel - 1)
				upgrade1TextureButtons[i].visible = boolean
				upgrade2TextureButtons[i].visible = boolean
			
			match upgradeLevel:
				1:
					upgrade1Label.set_bbcode("[center]Doppelte Punkte für immer! [wave amp=50 freq=10]Wuhu[/wave][/center]")
					upgrade2Label.set_bbcode("[center]Eine Hilfestellung, die dein Leben vereinfacht.[/center]")
				2:
					upgrade1Label.set_bbcode("[center]Die Tetrominos bewegen sich nur noch durch deine Kräfte![/center]")
					upgrade2Label.set_bbcode("[center]Blau ist meine Lieblingsfarbe.[/center]")
				3:
					upgrade1Label.set_bbcode("[center]Es macht [shake rate=10 level=10]boom[/shake]![/center]")
					upgrade2Label.set_bbcode("[center]Ich hasse Lücken...du auch?[/center]")
				4:
					upgrade1Label.set_bbcode("[center]Bekomme einen Speicher für einen Tetromino.[/center]")
					upgrade2Label.set_bbcode("[center]Die Katze besitzt sieben. Du nun zwei. [tornado radius=5 freq=2]Meow[/tornado][/center]")
			
			upgradeView.show()
			gameState = READY # Warten bis der Spieler ein Upgrade wählt
		
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
			
			for cube in storeTetromino:
				cube.getCube().queue_free()
			storeTetromino.clear()
			
			for cube in storeTetrominoView:
				cube.queue_free()
			storeTetrominoView.clear()
			
			for cube in assistanceTetromino:
				cube.getCube().queue_free()
			assistanceTetromino.clear()
			
			# Upgrades 1 - Variablen
			doublePoints = false
			storage = false
			gravityToNull = false
			extraLife = false
			
			# Upgrades 2 - Variablen
			assistance = false
			sameColor = false
			nextTetrominoBomb = false
			closeAllGap = false
			
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
				
				if (event.is_action_pressed("Storage") and storage):
					setStoreTetromino()
				
				if (event.is_action_pressed("LevelUp")):
					level = level + 1
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
				
				if (event.is_action_pressed("StorageController") and storage):
					setStoreTetromino()
		
		PAUSED:
			if (event.is_action_pressed("Pause")):
				$Hud/PausedGameOverTexturRect.hide()
				gameState = PLAYING
		
		DEAD:
			if (event.is_action_pressed("Pause")):
				# Zum Hauptmenü
				get_node("/root/Root").createThread("res://Szenen/Titlescreen.tscn")


# Upgrades
func _on_Upgrade1_pressed():
	match upgradeLevel:
		1:
			# Wird in der Funktion setLevelPointsRows durchgeführt
			doublePoints = true
			gameState = PLAYING
		2:
			# Wird in der Funktion _process durchgeführt
			if (!gravityToNull):
				gravityToNull = true
				
				# Timer setzen
				$Hud/GravityToNullLabel/TimerGravityToNull.start()
				
				# ProgressBar sichtbar machen
				$Hud/GravityToNullLabel.show()
			else:
				$Hud/GravityToNullLabel/GravityToNullTextureProgress.value = 0
			gameState = PLAYING
		3:
			# Wird in der Funktion moveCube durchgeführt
			nextTetrominoBomb = true
			gameState = PLAYING
		4:
			# Wird in der Funktion storeCubes durchgeführt
			storage = true
			$Hud.createStorage()
			gameState = READY # Warten bis Storage gezeichnet wurde
	
	showUpgrades = false
	upgradeView.hide()


func _on_Upgrade2_pressed():
	match upgradeLevel:
		1:
			# Wird in der Funktion _process durchgeführt
			assistance = true
		2:
			if (!sameColor):
				# Tetrominos werden nun beim Erzeugen eine Einheitsfarbe (Blau) besitzen
				sameColor = true
				
				# Farbe des spielbaren Tetromino ändern
				for cube in playableTetromino:
					cube.setTetrominoColor(Color8(32, 210, 244)) # Blau
					cube.setMeshColor(Color8(32, 210, 244))
					cube.setColor()
				
				# Farbe des nächsten Tetromino ändern
				for cube in nextTetromino:
					cube.setTetrominoColor(Color8(32, 210, 244)) # Blau
					cube.setMeshColor(Color8(32, 210, 244))
					cube.setColor()
				
				# Timer setzen
				$Hud/SameColorLabel/TimerSameColor.start()
				
				# ProgressBar sichtbar machen
				$Hud/SameColorLabel.show()
			else:
				$Hud/SameColorLabel/SameColorTextureProgress.value = 0
		3:
			closeAllGap = true
			closeAllGaps()
		4:
			# Wird in der Funktion nextCubeToPlayableCube durchgeführt
			extraLife = true
			gameState = PLAYING
	
	showUpgrades = false
	upgradeView.hide()
	gameState = PLAYING


func _on_TimerGravityToNull_timeout():
	$Hud/GravityToNullLabel/GravityToNullTextureProgress.value += 0.2

func _on_GravityToNullTextureProgress_value_changed(value):
	if (value == 100):
		$Hud/GravityToNullLabel/TimerGravityToNull.stop()
		$Hud/GravityToNullLabel/GravityToNullTextureProgress.value = 0
		$Hud/GravityToNullLabel.hide()
		gravityToNull = false

func _on_TimerSameColor_timeout():
	$Hud/SameColorLabel/SameColorTextureProgress.value += 0.2

func _on_SameColorTextureProgress_value_changed(value):
	if (value == 100):
		$Hud/SameColorLabel/TimerSameColor.stop()
		$Hud/SameColorLabel/SameColorTextureProgress.value = 0
		$Hud/SameColorLabel.hide()
		sameColor = false

func _on_TimerAchievement_timeout():
	showAchievements = false
