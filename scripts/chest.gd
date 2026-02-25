extends Area2D

@export var chest_id: int = 0
@export var chest_color: Color = Color.RED

var is_unlocked: bool = false
var sprite: Sprite2D

signal chest_activated(chest_id: int)

func _ready():
	# Create visual representation
	sprite = Sprite2D.new()
	sprite.texture = create_chest_texture()
	sprite.modulate = chest_color
	add_child(sprite)
	
	# Setup collision detection for player
	# Player is on layer 2, so we need to detect layer 2
	collision_layer = 0  # Chest doesn't collide with anything
	collision_mask = 2   # Detect player on layer 2
	
	# Setup collision shape
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(48, 48)
	collision.shape = shape
	add_child(collision)
	
	body_entered.connect(_on_body_entered)

func create_chest_texture() -> Texture2D:
	# Create a simple colored square as placeholder
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(chest_color)
	return ImageTexture.create_from_image(image)

func _on_body_entered(body):
	if body.is_in_group("player") and not is_unlocked:
		chest_activated.emit(chest_id)

func unlock():
	is_unlocked = true
	sprite.modulate = Color(0.5, 0.5, 0.5)  # Gray out when unlocked

func hide_chest():
	visible = false
