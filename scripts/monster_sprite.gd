extends Sprite2D

# Simple placeholder monster sprite generator
# Replace this with an actual sprite texture later

func _ready():
	# Create a creepy red/black monster placeholder
	var image = Image.create(96, 96, false, Image.FORMAT_RGBA8)
	
	# Fill with red
	for x in range(96):
		for y in range(96):
			# Create a rough monster shape
			var dist_from_center = Vector2(x - 48, y - 48).length()
			if dist_from_center < 40:
				image.set_pixel(x, y, Color(0.8, 0, 0, 1))
			
			# Add some "eyes"
			if (x > 25 and x < 35 and y > 30 and y < 45):
				image.set_pixel(x, y, Color(0, 0, 0, 1))
			if (x > 60 and x < 70 and y > 30 and y < 45):
				image.set_pixel(x, y, Color(0, 0, 0, 1))
	
	texture = ImageTexture.create_from_image(image)
