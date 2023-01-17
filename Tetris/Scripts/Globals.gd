extends Node

# Optionen
var moveKeyboard = true
var fullscreen = false
var resolutionIndex = 2
var borderless = false
var mute = false

# Offline-Game
var highscorePoints = 0
var highscoreDeleteRows = 0
var highscoreTime = 0
var highscoreLevel = 1
var framePicker = 0

# Online-Game
var network
var rooms = {}

# Cubes
var cubeList3D = [
	preload("res://Objects/Cubes3D/FrameCube.tscn"),
	preload("res://Objects/Cubes3D/HoleCube.tscn"),
	preload("res://Objects/Cubes3D/PlateCube.tscn"),
	preload("res://Objects/Cubes3D/StructureCube.tscn"),
	preload("res://Objects/Cubes3D/EdgyCube.tscn"),
	preload("res://Objects/Cubes3D/OrigamiCube.tscn"),
	preload("res://Objects/Cubes3D/XCube.tscn"),
	preload("res://Objects/Cubes3D/PrisonCube.tscn")
]

var cubeList2D = [
	preload("res://Image/CubeView/Cube.png"),
	preload("res://Image/CubeView/Cube2.png"),
	preload("res://Image/CubeView/Cube3.png"),
	preload("res://Image/CubeView/Cube4.png")
]

# Animationen, wenn eine Reihe Cubes entfernt wird
var animationName = "Shrink"

var RNG = getRNG()

func getRNG():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return rng

# Animation des Hintergrunds (Platform)
var platformTheme = "StarryNight"
var platformBackground = [
	preload("res://Image/Wallpapers/Nebula.png"),
	preload("res://Image/Wallpapers/Blocky.jpg"),
	preload("res://Image/Wallpapers/StarryNight.jpg")
]
