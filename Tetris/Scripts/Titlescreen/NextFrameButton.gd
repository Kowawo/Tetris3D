extends TextureButton


func _on_NextFrameButton_pressed():
	get_node("/root/SceneSwitcher").getCurrentScene().InkcubeIndex()
