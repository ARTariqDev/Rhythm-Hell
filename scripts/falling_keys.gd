extends Node2D

signal note_hit(accuracy: float)
signal note_missed()
signal hold_completed(accuracy: float)
signal hold_broken()

@export var fall_speed: float = 3.5
var expected_key: String = ""
var is_hold_note: bool = false
var hold_duration: float = 1.0
var hit_zone_y: float = 280.0
var perfect_threshold: float = 30.0
var good_threshold: float = 80.0
var miss_threshold: float = 150.0

var has_been_hit: bool = false
var is_holding: bool = false
var hold_timer: float = 0.0
var can_be_hit: bool = false

var arrow_sprite: Sprite2D
var hold_tube: ColorRect

func _ready():
	print("[NOTE] Note ready! Expected key: ", expected_key)
	setup_visuals()
	set_process(true)
	set_process_input(true)
	set_process_unhandled_input(true)

func setup_visuals():
	# Create colored background to show the note
	var bg = ColorRect.new()
	bg.size = Vector2(80, 80)
	bg.position = Vector2(-40, -40)
	
	# Color based on expected key for easy identification
	match expected_key:
		"rhythm_down":
			bg.color = Color(1, 0, 0, 1.0)  # Red
		"rhythm_left":
			bg.color = Color(0, 0, 1, 1.0)  # Blue
		"rhythm_right":
			bg.color = Color(0, 1, 0, 1.0)  # Green
		"rhythm_up":
			bg.color = Color(1, 1, 0, 1.0)  # Yellow
		_:
			bg.color = Color(1, 1, 1, 1.0)  # White
	
	add_child(bg)
	
	# Add a text label showing which key
	var label = Label.new()
	match expected_key:
		"rhythm_down":
			label.text = "↓"
		"rhythm_left":
			label.text = "←"
		"rhythm_right":
			label.text = "→"
		"rhythm_up":
			label.text = "↑"
	label.position = Vector2(-20, -20)
	label.add_theme_font_size_override("font_size", 48)
	add_child(label)
	
	# Create arrow sprite
	arrow_sprite = Sprite2D.new()
	if ResourceLoader.exists("res://art/Arrows (1).webp"):
		arrow_sprite.texture = load("res://art/Arrows (1).webp")
		arrow_sprite.hframes = 4
		arrow_sprite.vframes = 3
		arrow_sprite.visible = true  # Show arrow sprite
	add_child(arrow_sprite)
	
	# Hide colored boxes when using arrow sprite
	bg.visible = false
	label.visible = false
	
	# Create hold tube if it's a hold note
	if is_hold_note:
		hold_tube = ColorRect.new()
		hold_tube.size = Vector2(48, hold_duration * fall_speed * 60.0)
		hold_tube.position = Vector2(-24, 32)
		hold_tube.color = Color(0.3, 0.8, 1.0, 0.6)
		add_child(hold_tube)
		move_child(hold_tube, 0)  # Behind arrow

func _unhandled_input(event):
	if expected_key == "":
		return
	
	if event.is_action_pressed(expected_key):
		print("[NOTE] Key pressed: ", expected_key, " | Can hit: ", can_be_hit, " | Already hit: ", has_been_hit, " | Distance: ", abs(global_position.y - hit_zone_y))
		
	if event.is_action_pressed(expected_key) and can_be_hit and not has_been_hit:
		print("[NOTE] HIT DETECTED!")
		if is_hold_note:
			start_hold()
		else:
			check_hit()
		get_viewport().set_input_as_handled()
	
	if event.is_action_released(expected_key) and is_holding:
		end_hold(false)
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	global_position.y += fall_speed * delta * 60.0
	
	# Check if in hit zone
	var distance = abs(global_position.y - hit_zone_y)
	var old_can_hit = can_be_hit
	can_be_hit = distance <= miss_threshold
	
	if can_be_hit and not old_can_hit:
		print("[NOTE] Entered hit zone! Key: ", expected_key, " | Pos: ", global_position.y, " | Distance: ", distance)
	
	# Handle hold notes
	if is_holding:
		hold_timer += delta
		if hold_timer >= hold_duration:
			end_hold(true)
			return
	
	# Check if note was missed
	if global_position.y > hit_zone_y + miss_threshold and not has_been_hit:
		print("[NOTE] Passed hit zone! Missed. Key: ", expected_key, " | Pos: ", global_position.y)
		has_been_hit = true
		note_missed.emit()
		queue_free()

func check_hit():
	if has_been_hit:
		return
	
	var distance = abs(global_position.y - hit_zone_y)
	var accuracy = calculate_accuracy(distance)
	
	print("[NOTE] Check hit - Distance: ", distance, " | Accuracy: ", accuracy)
	
	if accuracy > 0:
		has_been_hit = true
		note_hit.emit(accuracy)
		print("[NOTE] Note hit signal emitted with accuracy: ", accuracy)
		show_hit_feedback(accuracy)
		if is_inside_tree():
			await get_tree().create_timer(0.1).timeout
			queue_free()
	else:
		has_been_hit = true
		note_missed.emit()
		print("[NOTE] Note missed - too far from hit zone")
		queue_free()

func start_hold():
	var distance = abs(global_position.y - hit_zone_y)
	var accuracy = calculate_accuracy(distance)
	
	if accuracy > 0:
		is_holding = true
		has_been_hit = true
		hold_timer = 0.0
		arrow_sprite.modulate = Color(0, 1, 1, 1)
	else:
		has_been_hit = true
		note_missed.emit()
		queue_free()

func end_hold(completed: bool):
	if not is_holding:
		return
	
	is_holding = false
	
	if completed:
		var accuracy = hold_timer / hold_duration
		hold_completed.emit(accuracy)
		show_hit_feedback(1.0)
	else:
		hold_broken.emit()
		show_hit_feedback(0.3)
	
	if is_inside_tree():
		await get_tree().create_timer(0.1).timeout
		queue_free()

func calculate_accuracy(distance: float) -> float:
	if distance <= perfect_threshold:
		return 1.0  # Perfect
	elif distance <= good_threshold:
		return 0.7  # Good
	elif distance <= miss_threshold:
		return 0.3  # Okay
	else:
		return 0.0  # Miss

func show_hit_feedback(accuracy: float):
	if accuracy >= 0.9:
		arrow_sprite.modulate = Color(0, 1, 0, 1)  # Green for perfect
	elif accuracy >= 0.6:
		arrow_sprite.modulate = Color(1, 1, 0, 1)  # Yellow for good
	else:
		arrow_sprite.modulate = Color(1, 0.5, 0, 1)  # Orange for okay
