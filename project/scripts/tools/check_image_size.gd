extends SceneTree

func _init():
	var img = Image.load_from_file("res://assets/tiles/1x1-tile.png")
	if img:
		print("1x1-tile.png size: ", img.get_size())
	else:
		print("Failed to load 1x1-tile.png")
	
	img = Image.load_from_file("res://assets/background/vertical.png")
	if img:
		print("vertical.png size: ", img.get_size())
	
	quit()
