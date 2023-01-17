extends Control

export var velocity = 5 # x Pixel per Frame

# Wege der einzelnen Partikel
var pathForParticels = [
	[
		# Erstes Partikel
		Vector3(-0.5, -0.5, 0), # Startposition
		Vector3(-0.5, 19.5, 0),
		Vector3(20.5, 19.5, 0),
		0
	],
	[
		# Zweites Partikel
		Vector3(-0.5, -0.5, 0), # Startposition
		Vector3(9.5, -0.5, 0),
		Vector3(9.5, 13.5, 0),
		Vector3(9.5, 19.5, 0),
		0
	],
	[
		# Drittes Partikel
		Vector3(9.5, -0.5, 0),  # Startposition
		Vector3(20.5, -0.5, 0),
		Vector3(20.5, 13.5, 0),
		0
	],
	[
		# Viertes Partikel
		Vector3(9.5, 13.5, 0), # Startposition
		Vector3(20.5, 13.5, 0),
		Vector3(20.5, 19.5, 0),
		0
	],
	[
		# Fünftes Partikel (für Lager)
		Vector3(-11.5, 13.5, 0), # Startposition
		Vector3(-11.5, 19.5, 0),
		Vector3(-0.5, 19.5, 0),
		0
	],
	[
		# Sechstes Partikel (für Lager)
		Vector3(-11.5, 13.5, 0), # Startposition
		Vector3(-0.5, 13.5, 0),
		Vector3(-0.5, 19.5, 0),
		0
	]
]


var particlesInGame = []
var intPosition = 0

var drawStorage = false

onready var camera = get_node("../Camera")
onready var particle2D = get_node("../Particles/Particles2D")

var color = Color(255,255,255)


# Gibt die Position von dem 3-Dimensionalen Raum in die 2-Dimensionale Ansicht zurück
func getCameraUnprojectPosition(vector):
	return camera.unproject_position(vector)

func createParticle(vector):
	var newParticle = particle2D.duplicate()
	newParticle.position = getCameraUnprojectPosition(vector)
	particlesInGame.append(newParticle)
	newParticle.set_visible(true)
	get_node("../Particles").add_child(newParticle)

func createStorage():
	MusicController.setEffectsSoundState("ParticleDrawing")
	createParticle(Vector3(-11.5, 13.5, 0))
	createParticle(Vector3(-11.5, 13.5, 0))
	drawStorage = true
	set_process(true)


func _draw():
	for particle in particlesInGame.size():
		for i in range(pathForParticels[particle][-1]):
			if (pathForParticels[particle][-1] == i + 1):
				var fromVector = getCameraUnprojectPosition(pathForParticels[particle][i])
				var toVector = particlesInGame[particle].position
				draw_line(fromVector, toVector, color, 3)
			else:
				var fromVector = getCameraUnprojectPosition(pathForParticels[particle][i])
				var toVector = getCameraUnprojectPosition(pathForParticels[particle][i + 1])
				draw_line(fromVector, toVector, color, 3)


func _ready():
	MusicController.setEffectsSoundState("ParticleDrawing")
	particle2D.position = getCameraUnprojectPosition(Vector3(-0.5, -0.5, 0))
	particlesInGame.append(particle2D)


func _process(delta):
	for particle in particlesInGame.size():
		# Bewegung Hoizontal
		if (particlesInGame[particle].position.x < getCameraUnprojectPosition(pathForParticels[particle][pathForParticels[particle][-1]]).x):
			particlesInGame[particle].position.x += velocity * 60 * delta
		else:
			particlesInGame[particle].position.x = getCameraUnprojectPosition(pathForParticels[particle][pathForParticels[particle][-1]]).x
		
		# Bewegung Vertikal
		if (particlesInGame[particle].position.y > getCameraUnprojectPosition(pathForParticels[particle][pathForParticels[particle][-1]]).y):
			particlesInGame[particle].position.y -= velocity * 60 * delta
		else:
			particlesInGame[particle].position.y = getCameraUnprojectPosition(pathForParticels[particle][pathForParticels[particle][-1]]).y
		
		update() # Ruft _draw() auf
		
		# Nächste Position
		if (particlesInGame[particle].position == getCameraUnprojectPosition(pathForParticels[particle][pathForParticels[particle][-1]])):
			if (pathForParticels[particle].size() - 2 != pathForParticels[particle][-1]):
				pathForParticels[particle][-1] += 1
				# Zweites Partikel wird erzeugt, sobald das erste Partikel die erste Position erreicht
				if (particle == 0 and pathForParticels[particle][-1] == 1):
					createParticle(pathForParticels[particle + 1][0])
				# Drittes Partikel wird erzeugt, sobald das zweite Partikel die zweite Position erreicht
				if (particle == 1 and pathForParticels[particle][-1] == 2):
					createParticle(pathForParticels[particle + 1][0])
				# Viertes Partikel wird erzeugt, sobald das zweite Partikel die dritte Position erreicht
				if (particle == 1 and pathForParticels[particle][-1] == 3):
					createParticle(pathForParticels[particle + 2][0])
			else:
				# Wenn ein Partikel seine Endposition erreicht hat, wird es unsichtbar
				particlesInGame[particle].hide()
	
	# Sind alle Partikel an ihrer Zielposition wird der GameState geändert sowie
	# das framebasierte Aufrufen von _process deaktiviert, um Performance zu sparen
	
	# Überprüfen, ob alle Partikel an ihre Zielposition sind
	var changeGameState = true
	for particle in particlesInGame:
		if (particle.is_visible()):
			changeGameState = false
	
	if (changeGameState):
		# Zeige alle Labels an
		$NextCubeHeadline.set_position(getCameraUnprojectPosition(Vector3(15, 18.5, 0)) - $NextCubeHeadline.get_rect().size / 2)
		$NextCubeHeadline.show()
		
		$PointsHeadline.set_position(getCameraUnprojectPosition(Vector3(15, 10.5, 0)) - $PointsHeadline.get_rect().size / 2)
		$PointsHeadline.show()
		$Points.set_position(getCameraUnprojectPosition(Vector3(15, 9.5, 0)) - $Points.get_rect().size / 2)
		$Points.show()
		
		$LevelHeadline.set_position(getCameraUnprojectPosition(Vector3(12.25, 7.5, 0)) - $LevelHeadline.get_rect().size / 2)
		$LevelHeadline.show()
		$Level.set_position(getCameraUnprojectPosition(Vector3(12.25, 6.5, 0)) - $Level.get_rect().size / 2)
		$Level.show()
		
		$LinesHeadline.set_position(getCameraUnprojectPosition(Vector3(17.75, 7.5, 0)) - $LinesHeadline.get_rect().size / 2)
		$LinesHeadline.show()
		$Lines.set_position(getCameraUnprojectPosition(Vector3(17.75, 6.5, 0)) - $Lines.get_rect().size / 2)
		$Lines.show()
		
		$TimeHeadline.set_position(getCameraUnprojectPosition(Vector3(15, 4.5, 0)) - $TimeHeadline.get_rect().size / 2)
		$TimeHeadline.show()
		$Time.set_position(getCameraUnprojectPosition(Vector3(15, 3.5, 0)) - $Time.get_rect().size / 2)
		$Time.show()
		
		$PausedGameOverTexturRect.set_position(getCameraUnprojectPosition(Vector3(4.5, 9.5, 0)) - $PausedGameOverTexturRect.get_rect().size / 2)
		
		if (get_parent().name != "MultiplayerGame"):
			$SameColorLabel.set_position(getCameraUnprojectPosition(Vector3(-6, 6, 0)) - $SameColorLabel.get_rect().size / 2)
			$GravityToNullLabel.set_position(getCameraUnprojectPosition(Vector3(-6, 10, 0)) - $GravityToNullLabel.get_rect().size / 2)
		
		if (drawStorage):
			$StorageHeadline.set_position(getCameraUnprojectPosition(Vector3(-6, 18.5, 0)) - $StorageHeadline.get_rect().size / 2)
			$StorageHeadline.show()
		
		get_owner().changeGameState(1) # 1 = PLAYING
		MusicController.stopEffect("ParticleDrawing")
		set_process(false)
