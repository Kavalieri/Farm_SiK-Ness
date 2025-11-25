extends ParallaxLayer

@onready var sprite = $Background

func _ready():
	if sprite:
		# Enable texture repeat for infinite tiling
		sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		# Set a massive region to ensure it covers any screen size
		sprite.region_enabled = true
		sprite.region_rect = Rect2(0, 0, 100000, 100000)
		
		# Set mirroring to match the texture size (scaled)
		# This resets the coordinate system periodically to prevent float precision issues
		if sprite.texture:
			motion_mirroring = sprite.texture.get_size() * sprite.scale



