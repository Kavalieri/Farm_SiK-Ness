extends ParallaxLayer

@onready var sprite = $Background

func _ready():
	if sprite and sprite.texture:
		var size = sprite.texture.get_size()
		motion_mirroring = size
		
		# Ensure the sprite covers the viewport if it's too small?
		# If the texture is small, we might need to scale it up or tile it manually.
		# But assuming the texture is meant to be the background, let's just set mirroring.
		
		# Also, to prevent "seeing behind", we can add a ColorRect as a fallback
		# But ParallaxBackground should handle it if mirroring is correct.
