extends CharacterBody2D

@export var speed: float = 200.0

var can_move: bool = true
var current_grid_pos: Vector2i
var keys_collected: int = 0
var keys_needed: int = 0

signal chest_reached(chest_id: int)
signal exit_reached()

func _ready():
	current_grid_pos = Vector2i(1, 1)
	
	# Set collision layers
	# Layer 1: Walls
	# Layer 2: Player & Monster (so they collide with walls but not each other)
	collision_layer = 2  # Player on layer 2
	collision_mask = 1   # Only collide with walls (layer 1)

func _process(_delta: float) -> void:
	if not can_move:
		return
	
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
	
	move_and_slide()

func set_position_on_grid(grid_pos: Vector2i, maze_gen):
	current_grid_pos = grid_pos
	global_position = maze_gen.get_world_position(grid_pos)

func disable_movement():
	can_move = false
	velocity = Vector2.ZERO

func enable_movement():
	can_move = true
