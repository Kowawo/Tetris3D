extends TextureButton


func _on_ShowCloseStatsTextureButton_pressed():
	self.set_flip_v(!self.is_flipped_v())
	get_node("/root/SceneSwitcher/CurrentNode/Titlescreen").showStats()
