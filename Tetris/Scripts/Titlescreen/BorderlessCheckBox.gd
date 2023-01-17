extends CheckBox


func _ready():
	self.pressed = Globals.borderless
	OS.window_borderless = Globals.borderless

func _on_CheckBox_pressed():
	OS.window_borderless = !OS.window_borderless
	Globals.borderless = !Globals.borderless
