extends Button


var buttonDown = false
var speed = 0.5

func _process(delta):
	if (!buttonDown):
		var cube = self.get_children()[-1]
		cube.rotation.y += speed * delta

func _input(event):
	if (buttonDown):
		var cube = self.get_children()[-1]
		if (event is InputEventMouseMotion):
			var mouseMovement = event.relative
			cube.rotation.y += deg2rad(mouseMovement.x) * speed

func _on_Button_button_down():
	buttonDown = true

func _on_Button_button_up():
	buttonDown = false
