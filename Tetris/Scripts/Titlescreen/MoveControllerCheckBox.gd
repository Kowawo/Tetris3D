extends CheckBox


func _ready():
	if (Globals.moveKeyboard):
		self.pressed = false

func _on_CheckBox_pressed():
	if (pressed):
		Globals.moveKeyboard = !Globals.moveKeyboard
		get_node("../../HBoxContainer2/CheckBox2").pressed = false
	else:
		pressed = true
