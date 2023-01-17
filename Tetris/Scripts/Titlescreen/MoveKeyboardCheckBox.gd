extends CheckBox


func _ready():
	if (Globals.moveKeyboard):
		self.pressed = true

func _on_CheckBox2_pressed():
	if (pressed):
		Globals.moveKeyboard = !Globals.moveKeyboard
		get_node("../../HBoxContainer/CheckBox").pressed = false
	else:
		pressed = true
