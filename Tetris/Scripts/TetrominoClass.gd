extends Node


class_name Tetromino
# Cubes
var cubeList = Globals.cubeList3D

# Spielbare Tetromino als Vektorschreibweise
var tetrominos = [
	[Vector2(0, 0), Vector2(-1, 0), Vector2(0, -1), Vector2(-1, -1)], # O-Tetromino
	[Vector2(0, 0), Vector2(1, 0), Vector2(-1, 0), Vector2(-2, 0)],   # I-Tetromino
	[Vector2(0, 0), Vector2(1, 0), Vector2(-1, 0), Vector2(-1, 1)],   # J-Tetromino
	[Vector2(0, 0), Vector2(1, 0), Vector2(-1, 0), Vector2(1, 1)],    # L-Tetromino
	[Vector2(0, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(1, 1)],    # S-Tetromino
	[Vector2(0, 0), Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1)],    # T-Tetromino
	[Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 1)]     # Z-Tetromino
]

var names = [
	"O-Tetromino",
	"I-Tetromino",
	"J-Tetromino",
	"L-Tetromino",
	"S-Tetromino",
	"T-Tetromino",
	"Z-Tetromino"
]

var colors = [
	Color8(78, 253, 84),  # Green Color(0.31, 0.99, 0.33)
	Color8(254, 1, 154),  # Pink Color(1.0, 0, 0.6)
	Color8(207, 255, 4),  # Yellow Color(0.81, 1.0, 0.01)
	Color8(32, 210, 244)  # Blue Color(0.12, 0.82, 0.96)
]


var cube

var tetrominoOriginalVector
var tetrominoVector
var tetrominoName

var origin = Vector2(0, 0)

var cubeColor = []
var colorPicker = 0


# Konstruktor
func _init(tetrominoPicker, sameColor = false):
	self.cube = cubeList[Globals.framePicker].instance()
	self.tetrominoName = names[tetrominoPicker]
	self.tetrominoVector = tetrominos[tetrominoPicker]
	self.tetrominoOriginalVector = tetrominos[tetrominoPicker]
	
	# Ist der generierte Cube der I-Cube wird der Ursprung (für die Rotation) geändert
	if (self.tetrominoName == "I-Tetromino"):
		self.origin = Vector2(-0.5, -0.5)
	
	if (sameColor):
		self.cubeColor = [colors[3], colors[3], colors[3], colors[3]]
	else:
		self.cubeColor = colors
		self.cubeColor.shuffle()
	
	self.setColor()


# Setter-Methoden
func setCube(newCube):
	self.cube = newCube

func setTetrominoVector(array):
	self.tetrominoVector = array

func setName(newTetrominoName):
	self.tetrominoName = newTetrominoName

func setOrigin(vector):
	self.origin = vector

func setTetrominoColor(color):
	self.cubeColor = [color, color, color, color]

func setColor(indexInkDek = 0):
	colorPicker = fposmod((colorPicker + indexInkDek), len(colors))
	self.cube.get_node("OmniLight").set_color(self.cubeColor[colorPicker])

func setMeshColor(color):
	self.cube.get_node("MeshInstance").get_material_override().albedo_color = color

func setPosition(vector):
	self.cube.translation = vector

func setScale(vector):
	self.cube.scale = vector

# Getter-Methoden
func getCube():
	return self.cube

func getTetrominoOriginalVector():
	return self.tetrominoOriginalVector

func getTetrominoVector():
	return self.tetrominoVector

func getName():
	return self.tetrominoName

func getOrigin():
	return self.origin

func getColor():
	return self.cube.get_node("OmniLight").get_color()

func getPosition():
	return self.cube.translation

# Methoden
func dup():
	var dupCube = get_script().new(0)
	
	dupCube.tetrominoName = self.tetrominoName
	dupCube.cube = self.cube.duplicate()
	dupCube.cubeColor = self.cubeColor.duplicate()
	dupCube.tetrominoVector = self.tetrominoVector.duplicate()
	
	return dupCube
