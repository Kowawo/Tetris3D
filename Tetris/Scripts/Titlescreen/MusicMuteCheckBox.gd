extends CheckBox


func _ready():
	if (Globals.mute):
		self.pressed = true
		if (!MusicController.getMute()):
			MusicController.setMute()

func _on_MusicMuteCheckBox_pressed():
	MusicController.setMute()
	Globals.mute = !Globals.mute
