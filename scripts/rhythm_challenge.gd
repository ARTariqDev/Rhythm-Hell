extends Node2D

@onready var rhythm_manager = $RhythmManager
@onready var background = $Background
@onready var music = $MusicManager
@onready var rhythm_ui = $RhythmUI

var chest_id: int = 0
var camera: Camera2D

func _ready():
	# Add camera to center the view
	camera = Camera2D.new()
	camera.position = Vector2.ZERO
	camera.enabled = true
	add_child(camera)
	
	# Adjust background for wider, shorter view
	background.offset_left = -640
	background.offset_right = 640
	background.offset_top = -360
	background.offset_bottom = 360
	
	# Set up the scene
	rhythm_manager.rhythm_game_complete.connect(_on_rhythm_complete)
	
	# Connect rhythm UI signals
	if rhythm_ui:
		rhythm_manager.combo_changed.connect(rhythm_ui.update_combo)
		rhythm_manager.score_updated.connect(rhythm_ui.update_score)
		rhythm_manager.note_hit.connect(func(_acc): rhythm_ui.update_accuracy(rhythm_manager.get_accuracy()))
		rhythm_manager.note_missed.connect(func(): rhythm_ui.update_accuracy(rhythm_manager.get_accuracy()))
	
	if music:
		music.play_rhythm_music()
	
	# Generate NEW feasible challenge sequence (15 notes)
	rhythm_manager.generate_challenge_sequence(15)
	rhythm_manager.max_notes = 15
	rhythm_manager.start_rhythm_game()
	print("[CHALLENGE] Started rhythm challenge with fresh sequence")

func _on_rhythm_complete(success: bool):
	print("[CHALLENGE] Rhythm complete callback triggered! Success: ", success)
	
	if music:
		music.stop_music()
	
	# Store result and return to maze
	Global.last_rhythm_success = success
	Global.rhythm_stats = {
		"accuracy": rhythm_manager.get_accuracy(),
		"max_combo": rhythm_manager.max_combo,
		"notes_hit": rhythm_manager.total_notes_hit,
		"notes_missed": rhythm_manager.total_notes_missed,
		"score": rhythm_manager.get_score(),
		"max_possible_score": rhythm_manager.get_max_possible_score()
	}
	
	print("[CHALLENGE] Global state set - Stats size: ", Global.rhythm_stats.size())
	print("[CHALLENGE] Changing scene to maze...")
	
	var result = get_tree().change_scene_to_file("res://levels/maze_level.tscn")
	if result != OK:
		print("[CHALLENGE] ERROR: Scene change failed with code: ", result)
	else:
		print("[CHALLENGE] Scene change initiated successfully")
