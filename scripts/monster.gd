extends CharacterBody2D

@export var move_speed: float = 120.0  # Slower for more tension

var is_chasing: bool = false
var is_lured: bool = false
var lure_position: Vector2
var lure_timer: float = 0.0
var maze_generator: Node2D
var player_ref: CharacterBody2D = null
var sprite: Sprite2D
var current_path: Array = []
var path_update_timer: float = 0.0
var path_update_interval: float = 0.5  # Recalculate path every 0.5 seconds

signal monster_reached_player()

func _ready():
	print("[MONSTER] Monster spawned at: ", global_position)
	
	# Set collision layers
	# Layer 1: Walls
	# Layer 2: Player & Monster (so they collide with walls but not each other)
	# Layer 3: Chests
	collision_layer = 2  # Monster on layer 2
	collision_mask = 1   # Only collide with walls (layer 1)
	
	# Create collision shape for walls
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 20.0  # Small collision radius
	collision.shape = shape
	add_child(collision)
	
	# Create Area2D for player detection
	var detection_area = Area2D.new()
	detection_area.collision_layer = 0  # Don't report collisions
	detection_area.collision_mask = 2   # Detect player (layer 2)
	var detection_shape = CollisionShape2D.new()
	var detection_circle = CircleShape2D.new()
	detection_circle.radius = 40.0  # Detection radius
	detection_shape.shape = detection_circle
	detection_area.add_child(detection_shape)
	detection_area.body_entered.connect(_on_player_detected)
	add_child(detection_area)
	
	# Create distinct visual - small dark circle
	sprite = Sprite2D.new()
	var image = Image.create(48, 48, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.1, 0.0, 0.0, 1.0))  # Dark red
	sprite.texture = ImageTexture.create_from_image(image)
	add_child(sprite)
	
	# Add eyes for monster
	var eye_left = Sprite2D.new()
	var eye_right = Sprite2D.new()
	var eye_img = Image.create(10, 10, false, Image.FORMAT_RGBA8)
	eye_img.fill(Color.RED)
	eye_left.texture = ImageTexture.create_from_image(eye_img)
	eye_right.texture = ImageTexture.create_from_image(eye_img)
	eye_left.position = Vector2(-10, -5)
	eye_right.position = Vector2(10, -5)
	sprite.add_child(eye_left)
	sprite.add_child(eye_right)

func _process(delta: float) -> void:
	if is_lured:
		lure_timer -= delta
		if lure_timer <= 0:
			print("[MONSTER] Lure expired, resuming chase")
			is_lured = false
			if player_ref:
				is_chasing = true
				current_path.clear()  # Force path recalculation
		# Move to lure using pathfinding
		path_update_timer += delta
		if path_update_timer >= path_update_interval:
			current_path = maze_generator.find_path(global_position, lure_position)
			path_update_timer = 0.0
			print("[MONSTER] Path to lure: ", current_path.size(), " waypoints")
		follow_path(delta)
		
	elif is_chasing and player_ref:
		# Update path periodically to chase player
		path_update_timer += delta
		if path_update_timer >= path_update_interval or current_path.is_empty():
			current_path = maze_generator.find_path(global_position, player_ref.global_position)
			path_update_timer = 0.0
			if int(Engine.get_frames_drawn()) % 120 == 0:  # Log every 2 seconds
				print("[MONSTER] Pathfinding - Path length: ", current_path.size())
		
		follow_path(delta)

func _on_player_detected(body: Node2D):
	if body == player_ref and not is_lured:
		print("[MONSTER] Caught player!")
		monster_reached_player.emit()
		is_chasing = false

func follow_path(_delta: float):
	if current_path.is_empty():
		return
	
	# Move towards first waypoint in path
	var target = current_path[0]
	var direction = (target - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()
	
	# If reached waypoint, remove it from path
	if global_position.distance_to(target) < 10:
		current_path.remove_at(0)

func start_chase(player: CharacterBody2D):
	player_ref = player
	is_chasing = true
	is_lured = false
	current_path.clear()
	print("[MONSTER] Started chasing player with pathfinding")

func lure_to_position(pos: Vector2, duration: float):
	print("[MONSTER] Lured to position: ", pos, " for ", duration, " seconds")
	is_lured = true
	is_chasing = false
	lure_position = pos
	lure_timer = duration
	current_path.clear()  # Clear path to recalculate
