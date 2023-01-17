extends Button


func _ready():
	if (Globals.framePicker == 0):
		self.set_disabled(true)
		self.set_text("Ausgewählt")

func _on_SelectFrameButton_pressed():
	MusicController.setEffectsSoundState("ButtonPressed")
	
	self.set_disabled(true)
	self.set_text("Ausgewählt")
	get_node("/root/SceneSwitcher").getCurrentScene().setFramePicker()
	
	get_node("/root/SceneSwitcher/CurrentNode/Titlescreen/ShopHud/VBoxContainer/HBoxContainer/HBoxContainer/Button").speed = 10
	yield(get_tree().create_timer(0.5), "timeout")
	get_node("/root/SceneSwitcher/CurrentNode/Titlescreen/ShopHud/VBoxContainer/HBoxContainer/HBoxContainer/Button").speed = 0.5
