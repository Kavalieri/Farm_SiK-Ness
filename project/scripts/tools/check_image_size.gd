extends SceneTree

func _init():
	var path = "res://assets/pieces/plus/shiping.png"
	
	var img = Image.load_from_file(path)
	if img:
		print("Image size: ", img.get_size())
	else:
		print("Failed to load image at: ", path)
	
	quit()
