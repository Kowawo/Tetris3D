extends OptionButton


func _ready():
	add_items()
	self.selected = Globals.resolutionIndex
	var resolution = self.get_item_text(Globals.resolutionIndex).split("x")
	OS.window_size = Vector2(int(resolution[0]),int(resolution[1]))
	get_viewport().size = Vector2(int(resolution[0]),int(resolution[1]))


func add_items():
	self.add_item("1920x1080")
	self.add_item("1680x945")
	self.add_item("1440x810")
	
	# Ist Fullscreen aktiviert und eine andere Auflösung als die oben hinzugefügten dann
	# wird die Auflösung hinzugefügt
	if (Globals.fullscreen):
		var addItem = true
		for index in self.get_item_count():
			var resolution = self.get_item_text(index)
			var newResolution = str(OS.window_size.x) + "x" + str(OS.window_size.y)
			
			if (resolution == newResolution):
				addItem = false
				break
		
		if (addItem):
			self.add_item(str(OS.window_size.x) + "x" + str(OS.window_size.y))

func _on_OptionButton_item_selected(index):
	var resolution = self.get_item_text(index).split("x")
	OS.window_size = Vector2(int(resolution[0]),int(resolution[1]))
	get_viewport().size = Vector2(int(resolution[0]),int(resolution[1]))
	
	OS.set_window_position(OS.get_screen_size(0) * 0.5 - OS.get_window_size() * 0.5)
	
	self.selected = index
	Globals.resolutionIndex = index
