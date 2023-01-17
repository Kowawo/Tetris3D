extends TextureButton


func _on_LastFrameButton_pressed():
	get_node("/root/SceneSwitcher").getCurrentScene().DekcubeIndex()
