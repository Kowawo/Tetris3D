extends Node

var dummylight = preload("res://Objects/MoveLight.tscn").instance()

var colors = [
	Color8(78, 253, 84),  # Green Color(0.31, 0.99, 0.33)
	Color8(254, 1, 154),  # Pink Color(1.0, 0, 0.6)
	Color8(207, 255, 4),  # Yellow Color(0.81, 1.0, 0.01)
	Color8(32, 210, 244)  # Blue Color(0.12, 0.82, 0.96)
]

var sizeWindow = OS.window_size

var light
var setOfPoints
var params
var functionY
var functionX
var sizeOfParams
var lightParent

class_name MoveLight

func _init(parent):
	self.light = createLight()
	
	functionX = getRandomSize()
	functionY = getRandomSize()
	
	self.sizeOfParams = getRandomSize()
	self.setOfPoints = getSetOfPoints()
	self.params = getParams(self.setOfPoints)
	self.lightParent = parent

func getRandomSize():
	var RNG = RandomNumberGenerator.new()
	RNG.randomize()
	return RNG.randi_range(0, 3)
	
func createLight():
	var RNG = RandomNumberGenerator.new()
	RNG.randomize()
	
	var omniLight = dummylight.duplicate()
	
	omniLight.get_node("Particles2D").color = colors[RNG.randi_range(0, 3)]
	return omniLight

func getSetOfPoints():
	var RNG = RandomNumberGenerator.new()
	RNG.randomize()
	
	var set = []
	var center = Vector3(0,0,0)
	var offset = Vector3(0,0,0)
	for i in range(self.sizeOfParams):
		var point = Vector3(
			stepify(RNG.randf_range(center.x - offset.x, center.x + offset.x), 2),
			stepify(RNG.randf_range(center.y - offset.y, center.y + offset.y), 2),
			stepify(RNG.randf_range(center.z - offset.z, center.z + offset.z), 2)
		)
		set.append(point)
		set[i] = point
	return set

func getParams(points):
	# print(points, "\n\n")
	var matrix = getVDM(points.size())
	var solvableLES = makeLESsolvable(matrix, points)
	var result = getLESResult(solvableLES[0], solvableLES[1])
	# print(result, "\n\n\n")
	return result

func getVDM(size):
	var matrix = []
	for i in range(size):
		var vdmrow = []
		for k in range(size):
			vdmrow.append(pow(i, k))
		matrix.append(vdmrow)
	return matrix

func makeLESsolvable(matrix, solutionVec):
	for diagonalIndex in range(matrix.size()):
		var value = matrix[diagonalIndex][diagonalIndex]
		for row in range(diagonalIndex + 1, matrix.size()):
			var factor = matrix[row][diagonalIndex] / value
			for column in range(matrix.size()):
				matrix[row][column] = matrix[row][column] - factor * matrix[diagonalIndex][column]
			solutionVec[row] -= float(factor) * solutionVec[diagonalIndex]
	for reverseDiagonalIndex in range(matrix.size() - 1, -1, -1):
		var value = matrix[reverseDiagonalIndex][reverseDiagonalIndex]
		for row in range(reverseDiagonalIndex):
			var factor = matrix[row][reverseDiagonalIndex] / value
			for column in range(matrix.size()):
				matrix[row][column] = matrix[row][column] - factor * matrix[reverseDiagonalIndex][column]
			solutionVec[row] -= float(factor) * solutionVec[reverseDiagonalIndex]
	return [matrix, solutionVec]

func getLESResult(matrix, solutionVec):
	var result = []
	for i in range(matrix.size()):
		result.append(solutionVec[i] / matrix[i][i])
	return result

func normalDistribute(X, variance, t):
	var sigma = sqrt(variance)
	var result = 1 / (sqrt(2 * PI) * sigma) * exp(- 0.5 * (pow((t - X) / sigma, 2)))
	return result

func getPositionX(index, x):
	match index:
		0:
			return sizeWindow.x/2*sin(PI/5*(x-2.5))+sizeWindow.x/2
		1:
			return sizeWindow.x/2*cos(PI/5*(x-2.5))+sizeWindow.x/2
		2:
			return sizeWindow.x/2*sin(PI/5*(x-2.5))+sizeWindow.x/2
		3:
			return -sizeWindow.x/2*cos(PI/5*(x-2.5))+sizeWindow.x/2

func getPositionY(index, x):
	match index:
		0:
			return sizeWindow.y/2*sin(2*PI/2.5*(x-0.625))+sizeWindow.y/2
		1:
			return sizeWindow.y/2*cos(2*PI/2.5*(x-0.625))+sizeWindow.y/2
		2:
			return -sizeWindow.y/2*sin(2*PI/2.5*(x-0.625))+sizeWindow.y/2
		3:
			return -sizeWindow.y/2*cos(2*PI/2.5*(x-0.625))+sizeWindow.y/2

func placeLight(t):
	var currentPos = Vector2(0,0)
	
	currentPos.x = getPositionX(functionX, t)
	currentPos.y = getPositionY(functionY, t)
	
	if (t < 2):
		self.light.get_node("Particles2D").color = Color(
			self.light.get_node("Particles2D").color.r,
			self.light.get_node("Particles2D").color.g,
			self.light.get_node("Particles2D").color.b,
			sin(PI/4 * t)
		)
	if (t > 8):
		self.light.get_node("Particles2D").color = Color(
			self.light.get_node("Particles2D").color.r,
			self.light.get_node("Particles2D").color.g,
			self.light.get_node("Particles2D").color.b,
			-sin(PI/4*(t-2))
		)
	self.light.get_node("Particles2D").position = currentPos
