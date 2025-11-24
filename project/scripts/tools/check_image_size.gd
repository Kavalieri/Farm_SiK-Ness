extends SceneTree

func _init():
	var args = OS.get_cmdline_args()
	var path = "res://assets/background/horizontal-green-background.png"
	
	var img = Image.load_from_file(path)
	if img:
		print("Image size: ", img.get_size())
	else:
		print("Failed to load image at: ", path)
	
	quit()
