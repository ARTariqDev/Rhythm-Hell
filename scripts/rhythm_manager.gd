extends Node

signal note_hit(accuracy: float)
signal note_missed()
signal combo_changed(new_combo: int)
signal rhythm_game_complete(success: bool)
signal score_updated(score: int)

@export var spawn_interval: float = 1.0
@export var speed_ramp_time: float = 15.0  # Time before speed increases
@export var speed_multiplier: float = 100.0  # How much faster it gets

var current_combo: int = 0
var max_combo: int = 0
var total_notes_hit: int = 0
var total_notes_missed: int = 0
var game_active: bool = false
var spawn_timer: float = 0.0
var game_timer: float = 0.0
var current_fall_speed: float = 3.5
var notes_spawned: int = 0
var max_notes: int = 20  # Notes before arrow spam
var current_score: int = 0

var note_lanes = {
	"rhythm_left": -165,
	"rhythm_down": -50,
	"rhythm_up": 66,
	"rhythm_right": 176
}

var note_sequence = []  # Pre-defined sequence of notes
var sequence_index: int = 0

func _ready():
	randomize()
	generate_note_sequence()

func generate_note_sequence():
	# Generate a sequence of notes for the rhythm game
	var keys = ["rhythm_down", "rhythm_left", "rhythm_right", "rhythm_up"]
	
	# First 20 notes - normal gameplay
	for i in range(20):
		var note_data = {
			"key": keys[randi() % keys.size()],
			"is_hold": false,
			"hold_duration": 0.0
		}
		note_sequence.append(note_data)
	
	# Then 400+ notes for HELL MODE - mix of all types
	for i in range(400):
		# Ensure good mix by cycling through keys
		var note_data = {
			"key": keys[i % keys.size()],  # Cycle through all types
			"is_hold": false,
			"hold_duration": 0.0
		}
		note_sequence.append(note_data)
		# Also add some random ones
		if randf() < 0.5:
			var extra_note = {
				"key": keys[randi() % keys.size()],
				"is_hold": false,
				"hold_duration": 0.0
			}
			note_sequence.append(extra_note)

# Generate feasible rhythm challenge sequence (no hell mode)
func generate_challenge_sequence(note_count: int):
	note_sequence.clear()
	var keys = ["rhythm_down", "rhythm_left", "rhythm_right", "rhythm_up"]
	var last_key = ""
	var same_key_count = 0
	
	for i in range(note_count):
		var available_keys = keys.duplicate()
		
		# Avoid more than 3 of the same key in a row
		if same_key_count >= 3:
			available_keys.erase(last_key)
		
		# Pick a random key from available
		var chosen_key = available_keys[randi() % available_keys.size()]
		
		# Track consecutive keys
		if chosen_key == last_key:
			same_key_count += 1
		else:
			same_key_count = 1
			last_key = chosen_key
		
		var note_data = {
			"key": chosen_key,
			"is_hold": false,
			"hold_duration": 0.0
		}
		note_sequence.append(note_data)
	
	print("[RHYTHM] Generated challenge sequence with ", note_count, " notes")

func start_rhythm_game():
	game_active = true
	spawn_timer = 0.0
	game_timer = 0.0
	current_combo = 0
	total_notes_hit = 0
	total_notes_missed = 0
	notes_spawned = 0
	sequence_index = 0
	current_fall_speed = 3.5
	# Note: generate_note_sequence() or generate_challenge_sequence() should be called BEFORE start_rhythm_game()

func stop_rhythm_game(success: bool):
	game_active = false
	print("[RHYTHM] stop_rhythm_game called with success: ", success)
	print("[RHYTHM] Emitting rhythm_game_complete signal...")
	rhythm_game_complete.emit(success)
	print("[RHYTHM] Signal emitted!")

func _process(delta: float) -> void:
	if not game_active:
		return
		
	game_timer += delta
	spawn_timer += delta
	
	# After max_notes, spawn BATCHES of arrows for hell mode
	var current_spawn_interval = spawn_interval
	var batch_size = 1
	if notes_spawned >= max_notes:
		current_spawn_interval = 0.3  # Spawn batch every 0.3 seconds
		batch_size = 15  # Spawn 15 arrows at once!
	
	# Spawn notes at intervals
	if spawn_timer >= current_spawn_interval and sequence_index < note_sequence.size():
		# Spawn a batch of notes
		for i in range(batch_size):
			if sequence_index < note_sequence.size():
				spawn_note(note_sequence[sequence_index])
				sequence_index += 1
				await get_tree().process_frame  # Small delay between spawns in batch
		spawn_timer = 0.0
	
	# Check for completion - all notes processed
	var total_processed = total_notes_hit + total_notes_missed
	if total_processed >= note_sequence.size():
		# Success if we hit most notes (less than 10 misses)
		var success = total_notes_missed < 10
		print("[RHYTHM] All notes processed: ", total_processed, "/", note_sequence.size(), " - Success: ", success)
		stop_rhythm_game(success)
		return  # Don't continue processing after completion
	
	# Check for game over conditions (early failure)
	if total_notes_missed >= 10:  # Fail after 10 misses
		print("[RHYTHM] Too many misses: ", total_notes_missed)
		stop_rhythm_game(false)
		return

func spawn_note(note_data):
	var key = note_data.get("key", "button_D") if typeof(note_data) == TYPE_DICTIONARY else note_data
	var is_hold = note_data.get("is_hold", false) if typeof(note_data) == TYPE_DICTIONARY else false
	var hold_dur = note_data.get("hold_duration", 1.0) if typeof(note_data) == TYPE_DICTIONARY else 1.0
	
	print("[RHYTHM] Spawning note - Key: ", key, " | Is Hold: ", is_hold)
	
	var note_scene = preload("res://falling_keys.tscn")
	var note_inst = note_scene.instantiate()
	
	# Set properties BEFORE adding to tree so _ready() has them
	note_inst.global_position = Vector2(note_lanes[key], -360)
	note_inst.fall_speed = current_fall_speed
	note_inst.expected_key = key
	note_inst.is_hold_note = is_hold
	note_inst.hold_duration = hold_dur
	
	# Now add to tree
	get_tree().get_root().add_child(note_inst)
	
	print("[RHYTHM] Note spawned at position: ", note_inst.global_position, " expecting key: ", key)
	
	# Set the correct arrow direction based on key
	# Check the actual sprite setup
	var arrow_frames = {
		"rhythm_down": 5,  # Down arrow
		"rhythm_left": 4,  # Left arrow
		"rhythm_right": 7,  # Right arrow
		"rhythm_up": 6   # Up arrow
	}
	
	# Wait for node to be ready
	await get_tree().process_frame
	
	if note_inst.has_node("arrow_sprite"):
		note_inst.get_node("arrow_sprite").frame = arrow_frames.get(key, 4)
	elif note_inst.arrow_sprite:
		note_inst.arrow_sprite.frame = arrow_frames.get(key, 4)
	
	print("[RHYTHM] Note setup complete, processing enabled")
	notes_spawned += 1
	
	# Connect signals for hit detection
	if note_inst.has_signal("note_hit"):
		note_inst.note_hit.connect(_on_note_hit)
	if note_inst.has_signal("note_missed"):
		note_inst.note_missed.connect(_on_note_missed)
	if note_inst.has_signal("hold_completed"):
		note_inst.hold_completed.connect(_on_note_hit)
	if note_inst.has_signal("hold_broken"):
		note_inst.hold_broken.connect(_on_note_missed)

func _on_note_hit(accuracy: float):
	print("[RHYTHM] Note hit received! Accuracy: ", accuracy, " | Combo: ", current_combo + 1)
	current_combo += 1
	max_combo = max(max_combo, current_combo)
	total_notes_hit += 1
	
	# Calculate score with combo multiplier
	var points = int(100 * accuracy * (1.0 + current_combo * 0.1))
	current_score += points
	
	note_hit.emit(accuracy)
	combo_changed.emit(current_combo)
	score_updated.emit(current_score)

func _on_note_missed():
	print("[RHYTHM] Note missed! Combo reset. Misses: ", total_notes_missed + 1)
	current_combo = 0
	total_notes_missed += 1
	note_missed.emit()
	combo_changed.emit(0)

func get_accuracy() -> float:
	var total = total_notes_hit + total_notes_missed
	if total == 0:
		return 0.0
	return float(total_notes_hit) / float(total) * 100.0

func get_score() -> int:
	return current_score

func get_max_possible_score() -> int:
	# Calculate max score assuming perfect accuracy (1.0) and full combo
	# Each note: 100 * 1.0 * (1.0 + combo * 0.1)
	var total = 0
	var note_count = note_sequence.size()
	for i in range(note_count):
		var combo_multiplier = 1.0 + i * 0.1
		var points = int(100 * 1.0 * combo_multiplier)
		total += points
	return total
