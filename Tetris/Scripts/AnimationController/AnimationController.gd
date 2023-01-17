extends Node

# Ressource
var MoveLightClass = preload("res://Scripts/MoveLightClass.gd")
var MoveLightObject = preload("res://Objects/MoveLight.tscn")

# Dieses Skript ist für visuelle Effekte

# Animationen des Hintergrunds (Platform)
var platformTheme = Globals.platformTheme
var shaderMaterial
var time = 0

var shader_params = {
	# Farbe des Meshes
	"albedo" : Color(1.0, 1.0, 1.0, 1.0),
	# Texture des Meshes
	"texture_albedo" : null,
	# Parameter
	"specular": 0.0,
	"metallic": 0.0,
	"roughness" : 0.0,
	# Lichtaustrahlung der Texture
	"texture_emission": null,
	"emission_energy": 0.0
}

func _on_Platform_ready():
	var platform = get_node("../Platform")
	var mesh = platform.get_mesh()
	shaderMaterial = mesh.get_material()
	
	setTextureTheme()

# Setzt den Hintergrund und zugehörige Parameter
func setTextureTheme():
	var texture
	match platformTheme:
		"Nebula":
			texture = Globals.platformBackground[0]
			setParams(0.0, 0.0, 0.0, 0.0, 0.0)
		"Blocky":
			texture = Globals.platformBackground[1]
			setParams(1.0, 0.0, 0.75, 0.2, 0.0)
		"StarryNight":
			texture = Globals.platformBackground[2]
			setParams(0.0, 0.0, 0.0, 0.0, 0.0)
	
	# Textur als Shaderparameter übernehmen
	shader_params["texture_albedo"] = texture
	shader_params["texture_emission"] = texture
	
	# Shader aktualisieren
	uploadParamsToShader(shader_params, shaderMaterial)

func setParams(specular, metallic, roughness, emission_energy, intensity):
	shader_params["specular"] = specular
	shader_params["metallic"] = metallic
	shader_params["roughness"] = roughness
	shader_params["emission_energy"] = emission_energy
	shader_params["intensity"] = intensity

# Gibt alle neuen Werte in den Shader
func uploadParamsToShader(params, material):
	for parameter in params.keys():
		material.set_shader_param(parameter, params[parameter])

func _process(delta):
	match platformTheme:
		"StarryNight":
			# Lichtpulseffekt
			shader_params["intensity"] = 0 * sin(0.05 * time)
			shader_params["emission_energy"] = 0.2  * abs(sin(time)) + 0.1
		"Blocky":
			# Blockiger Lichtpulseffekt
			if (abs(floor(time) - time) <= 0.002):
				shader_params["emission_energy"] = fmod(shader_params["emission_energy"] + Globals.RNG.randf_range(0.1, 0.3) , 1)   
		"Nebula":
			# schwacher Lichtpulseffekt
			shader_params["intensity"] = 0 * sin(0.05 * time)
			shader_params["emission_energy"] = 0.2  * abs(sin(time)) + 0.1
	
	# Übernehme shaderparameter
	if (shaderMaterial != null):
		uploadParamsToShader(shader_params, shaderMaterial)
	
	# update time and shader
	time += delta


# Animation für die Cubes
var cubes = []
var index = 0
var animationName = ""

signal animationCompleted

func animate(cube):
	match animationName:
		"Shrink":
			cube.getCube().scale -= Vector3(0.05, 0.05, 0.05)
		"Rotate":
			cube.getCube().rotation_degrees.z += 3
		
	if (cube.getCube().rotation_degrees.z >= 360 or cube.getCube().scale.x <= 0):
		cube.getCube().queue_free()
		cubes.erase(cube)
		index -= 1

func animateCubes(cubeArray, name):
	cubes = cubeArray
	animationName = name
	$AnimationTimerCube.start()

func _on_AnimationTimerCube_timeout():
	if (!cubes.empty()):
		for i in cubes.size():
			if (i <= index):
				animate(cubes[i])
			else:
				index = min(index + 1, cubes.size() - 1)
				break
	else:
		$AnimationTimerCube.stop()
		emit_signal("animationCompleted")

func lightSplineAnimate():
	var lightObject = MoveLightClass.new(self)
	get_node("Lights").add_child(lightObject.light)
	
	var tween = $AnimationLightTween.duplicate()
	self.add_child(tween)
	
	tween.interpolate_method(lightObject, "placeLight", 0, 10, 20, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0)
	tween.start()
	
	yield(tween, "tween_completed")
	tween.queue_free()
	lightObject.light.queue_free()
	lightObject.queue_free()
