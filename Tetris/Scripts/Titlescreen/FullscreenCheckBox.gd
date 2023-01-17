extends CheckBox


func _ready():
	self.pressed = Globals.fullscreen
	OS.window_fullscreen = Globals.fullscreen

func _on_CheckBox_pressed():
	OS.window_fullscreen = !OS.window_fullscreen
	Globals.fullscreen = !Globals.fullscreen
	
	var optionButtonResolution = get_node("../../../../../VBoxContainer3/HBoxContainer/HBoxContainer/OptionButton")
	if (!Globals.fullscreen):
		# Nach dem Fullscreen deaktiviert wird, wird der Bildschrim auf die Auflösung 1440x810 zurückgesetzt
		optionButtonResolution._on_OptionButton_item_selected(2)
		Globals.resolutionIndex = 2
	else:
		# Wenn Fullscreen aktiviert wird, muss die Auflösung angepasst werden
		
		# Es wird geschaut, ob die Auflösung gespeichert ist, ansonsten wird sie
		# hinzugefügt und ausgewählt
		var addItem = true
		for index in optionButtonResolution.get_item_count():
			var resolution = optionButtonResolution.get_item_text(index)
			var newResolution = str(OS.window_size.x) + "x" + str(OS.window_size.y)
			
			if (resolution == newResolution):
				optionButtonResolution.select(index)
				Globals.resolutionIndex = index
				addItem = false
				break
		
		if (addItem):
			optionButtonResolution.add_item(str(OS.window_size.x) + "x" + str(OS.window_size.y))
			optionButtonResolution.select(optionButtonResolution.get_item_count() - 1)
			Globals.resolutionIndex = optionButtonResolution.get_item_count() - 1
