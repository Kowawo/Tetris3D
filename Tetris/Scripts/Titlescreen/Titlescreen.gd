extends Spatial


var time = 0
# Alle x-Sekunden wird ein Tetromino erzeugt
# Zeit richtet sich nach Ingame-FPS
var timePeriod = 3 

onready var particle = get_node("Particles2D")
var selectButton = false
var selectMultiplayer = false
var hoverButton = false
var endPosition = 0

var showOption = false
var showShop = false
var showStat = false

const TetrominoClass = preload("res://Scripts/TetrominoClass.gd")

var cubesInGames = []

var cubeIndex = 0
var cubes = [
	[
		"Würfel des Beginns",
		"Am Anfang gab es nur undurchdringbares Chaos. Mitten in diesem Chaos entwickelte sich aus dem Nichts ein Ei, aus dem Arceus schlüpfte. Das Chaos hinter sich lassend, hat es das Universum und die Welt geformt.",
		0 # Benötigte Punktzahl, um den Cube freizuschalten
	],
	[
		"Würfel der Zeit",
		"Am höchsten Punkt, der heute als Olympus Mons bekannt ist, erschuf Arceus zwei Eier. Aus einem dieser Eier schlüpfte Dialga, der Meister der Zeit. Das Rad der Zeit fing an sich zu bewegen.",
		50000 # Benötigte Punktzahl, um den Cube freizuschalten
	],
	[
		"Würfel der Dimension",
		"Aus dem anderen Ei schlüpfte Palkia, der Meister der Dimensionen und des Raumes. Der Raum dehnte sich aus.",
		100000 # Benötigte Punktzahl, um den Cube freizuschalten
	],
	[
		"Würfel der Antimaterie",
		"Arceus erschuf aber noch ein drittes Ei, aus dem Giratina schlüpfte, um das Dimensions-Trio zu komplettierte. Dieses Wesen verkörpert die Antimaterie und soll das Gegengewicht zu Dialgas und Palkias Raum-Zeit-Gefüge darstellen. Um jenes zu erreichen erschuf Giratina die Zerrwelt, in der weder Zeit, noch Raum richtig fließen.",
		175000
	],
	[
		"Würfel des Wissens",
		"Am Ende erschuf Arceus ein letztes Ei. Nachdem dies vollzogen war, zog sich Arceus in die von ihm erschaffene Halle des Beginns zu einen immerwährenden Schlaf zurück. Aus dem letzten Ei des Gottes schlüpften diesmal drei Wesen. Selfe war einer davon. Durch ihn erlangten die Lebewesen die Fähigkeit, Probleme zu lösen.",
		500000
	],
	[
		"Würfel der Gefühle",
		"Das zweite Wesen war Vesprit. Als Vesprit zum ersten Mal flog, lernten die Lebewesen Glück, Freude, Trauer und den Schmerz des Lebens kennen.",
		750000
	],
	[
		"Würfel der Willenskraft",
		"Das letzte Wesen war Tobutz. Durch Tobutz erlangten die Lebewesen die Entschlossenheit. Es war die Geburt der Willenskraft.",
		1000000
	],
	[
		"Der Covidiot",
		"Niemand weiß, warum er in diesem nicht artgerechtem Gefängnis gelandet ist. Man weiß nur, dass es mit einer Sache, die 2020 geschah, zu tun hat. Er ist stapelbar!",
		99999999
	],
]


# Um eine zufällige Position der Cubes zu ermöglichen
var rng = RandomNumberGenerator.new()
func randomNumber(a, b):
	rng.randomize()
	return rng.randf_range(a, b)


# Um die Cubes im Hintergrund zu platzieren
func placeTetromino(cube, x, y):
	for vector in cube.getTetrominoVector():
		var cubeDuplicate = cube.dup()
		cubeDuplicate.setPosition(Vector3(x + vector.x, y + vector.y, -3))
		cubesInGames.append(cubeDuplicate)
		self.add_child(cubeDuplicate.getCube())


# Animation für den Übergang in die nächste Szene
func animationForNextScene(multiplayer = false):
	$Hud.set_size(OS.window_size)
	$Hud.set_position(Vector2(0, 0))
	$Hud.set_frame_color(Color(0, 0, 0, 0))
	
	for child in $Hud/VBoxContainer.get_children():
		if (child.name == "TitleRect"):
			child.rect_position = Vector2(OS.window_size.x / 2, OS.window_size.y / 2)
		else:
			child.hide()
	showOption = false
	showShop = false
	# Falls die Statistiken angezeigt werden, muss zusätzlich der TextureButton geflippt werden
	if (showStat):
		showStat = false
		$HighscoreHud/ShowCloseStatsTextureButton.set_flip_v(false)
	
	selectButton = true
	if (multiplayer):
		selectMultiplayer = true


# Optionen anzeigen lassen
func showOptions():
	showOption = !showOption
	showShop = false


# Tastaturbelegung anzeigen
func showKeyboardLayouts():
	if (showStat):
		showStat = false
		$HighscoreHud/ShowCloseStatsTextureButton.set_flip_v(false)


# Statistiken anzeigen
func showStats():
	showStat = !showStat


# Shop anzeigen lassen
func showShops():
	showShop = !showShop
	showOption = false


func InkcubeIndex():
	cubeIndex = (cubeIndex + 1) % Globals.cubeList3D.size()
	updateShop()

func DekcubeIndex():
	cubeIndex = (cubeIndex - 1) % Globals.cubeList3D.size()
	updateShop()

func setFramePicker():
	Globals.framePicker = cubeIndex

func updateShop():
	var newCube = Globals.cubeList3D[cubeIndex].instance()
	newCube.translation = Vector3(20, 4, -2)
	newCube.rotation_degrees.y = 60
	newCube.rotation_degrees.x = 180
	
	newCube.scale = Vector3(0.5, 0.5, 0.5)
	newCube.get_node("OmniLight").set_color(Color8(32, 210, 244))
	newCube.get_node("MeshInstance").get_active_material(0).albedo_color = (Color8(32, 210, 244))

	var oldcubes = $ShopHud/VBoxContainer/HBoxContainer/HBoxContainer/Button.get_children()
	if (oldcubes.size() > 0):
		oldcubes[-1].queue_free()
	
	$ShopHud/VBoxContainer/HBoxContainer/HBoxContainer/Button.add_child(newCube)
	$ShopHud/VBoxContainer/CubeLabel.set_text(cubes[cubeIndex][0])
	$ShopHud/VBoxContainer/HBoxContainer/VBoxContainer/VBoxContainer/PropertiesLabel.bbcode_text = cubes[cubeIndex][1]
	
	if (Globals.highscorePoints >= cubes[cubeIndex][2]):
		if (Globals.framePicker != cubeIndex):
			$ShopHud/VBoxContainer/HBoxContainer/VBoxContainer/VBoxContainer2/SelectFrameButton.set_disabled(false)
			$ShopHud/VBoxContainer/HBoxContainer/VBoxContainer/VBoxContainer2/SelectFrameButton.set_text("Auswählen")
		else:
			$ShopHud/VBoxContainer/HBoxContainer/VBoxContainer/VBoxContainer2/SelectFrameButton.set_disabled(true)
			$ShopHud/VBoxContainer/HBoxContainer/VBoxContainer/VBoxContainer2/SelectFrameButton.set_text("Ausgewählt")
	else:
		$ShopHud/VBoxContainer/HBoxContainer/VBoxContainer/VBoxContainer2/SelectFrameButton.set_disabled(true)
		$ShopHud/VBoxContainer/HBoxContainer/VBoxContainer/VBoxContainer2/SelectFrameButton.set_text("Wird ab " + str(cubes[cubeIndex][2]) + " Punkte freigeschaltet")


# Animation mit dem 2DPartikel wird abgespielt, sobald die Maus eine Zone eines Buttons betritt
func mouseEnteredInButton(rect):
	if (!hoverButton):
		particle.global_position = Vector2(0, rect.position.y + rect.size.y / 2)
		endPosition = rect.size.x + 20
		hoverButton = true
		particle.show()


# Animation mit dem 2DPartikel wird abgespielt, sobald die Maus eine Zone eines Buttons verlässt
func mouseExitedFromButton():
	hoverButton = false
	particle.hide()


func _ready():
	# Musik setzen
	MusicController.setBackgroundSoundState("Titlescreen")
	
	# Ersten Frame für Shop platzieren
	updateShop()
	
	# Aktualisiere Highscores
	$HighscoreHud/HBoxContainer/VBoxContainer/HighscorePointsEditLabel.set_text(str(Globals.highscorePoints))
	
	var playtime = Globals.highscoreTime
	
	var hours = floor(playtime / 3600)
	var minutes = floor( (playtime - 3600 * hours) / 60)
	var seconds = round(playtime - 3600 * hours - 60 * minutes)
	
	if (str(hours).length() != 2):
		hours = "0" + str(hours)
	if (str(minutes).length() != 2):
		minutes = "0" + str(minutes)
	if (str(seconds).length() != 2):
		seconds = "0" + str(seconds)
	
	$HighscoreHud/HBoxContainer/VBoxContainer4/HighscoreTimeEditLabel.set_text(str(hours) + ":" + str(minutes) + ":" + str(seconds))
	$HighscoreHud/HBoxContainer/VBoxContainer2/HighscoreLevelEditLabel.set_text(str(Globals.highscoreLevel))
	$HighscoreHud/HBoxContainer/VBoxContainer3/HighscoreDeletedRowsEditLabel.set_text(str(Globals.highscoreDeleteRows))


func _process(delta):
	# Erzeugt einen Hintergrund mit fallenden Figuren
	time += delta
	if (time >= timePeriod or cubesInGames.size() == 0):
		var cube = TetrominoClass.new(randomNumber(0, 6))
		cube.setScale(Vector3(0.475, 0.475, 0.15))
		cube.setMeshColor(cube.getColor())
		placeTetromino(cube, randomNumber(-8, 8), 12)
		time = 0
	
	for cube in cubesInGames:
		var newPosition = cube.getPosition()
		newPosition.y -= 1.3 * delta
		cube.setPosition(newPosition)
	
	for cube in cubesInGames:
		if (cube.getPosition().y < -15):
			cube.getCube().queue_free()
			cubesInGames.erase(cube)
	
	# Sobald ein Button mit dem Mauszeiger betreten wird
	# bewegt sich das Partikel über den gewählten Button
	if (hoverButton):
		if (particle.position.x + 600 * delta < endPosition):
			particle.position.x += 600 * delta
		else:
			particle.position.x = endPosition
			hoverButton = false
	
	# Sobald ein Button (Start oder Multiplayer) angeklickt wurde geht das Partikel
	# in die Bildschirmmitte und wird durch ein temporäres ersetzt
	# Anschließend wird die zugehörige Szene geladen
	if (selectButton):
		if (particle.position.x < OS.window_size.x / 2):
			particle.position.x += 600 * delta
		else:
			var tmpParticle = particle.duplicate()
			tmpParticle.amount = 10
			tmpParticle.process_material.gravity.x = 0
			tmpParticle.preprocess = 0
			self.add_child(tmpParticle)
			
			particle.one_shot = true
			var path = "res://Szenen/Multiplayer/MultiplayerScreen.tscn" if selectMultiplayer else "res://Szenen/Game.tscn"
			
			get_node("/root/SceneSwitcher").createThread(path)
			
			selectButton = false
		particle.show()
	
	# Zeige die einzelnen Menüs an
	if (showOption):
		if (get_node("OptionenHud").rect_position.x > OS.window_size.x - get_node("OptionenHud").rect_size.x - 50):
			get_node("OptionenHud").rect_position.x -= 600 * delta
	else:
		if (get_node("OptionenHud").rect_position.x < OS.window_size.x):
			get_node("OptionenHud").rect_position.x += 600 * delta
	
	if (showShop):
		if (get_node("ShopHud").rect_position.y > OS.window_size.y - get_node("ShopHud").rect_size.y):
			get_node("ShopHud").rect_position.y -= 600 * delta
	else:
		if (get_node("ShopHud").rect_position.y < OS.window_size.y):
			get_node("ShopHud").rect_position.y += 600 * delta
	
	if (showStat):
		if (get_node("HighscoreHud").rect_position.y < 0):
			get_node("HighscoreHud").rect_position.y += 120 * delta
	else:
		if (get_node("HighscoreHud").rect_position.y > -get_node("HighscoreHud").rect_size.y):
			get_node("HighscoreHud").rect_position.y -= 120 * delta

