extends Node2D

@onready var rhythm_manager = $RhythmManager
@onready var jumpscare = $JumpscareLayer
@onready var title_card = $TitleCardLayer
@onready var fade_overlay = $FadeOverlay
@onready var lose_screen = $LoseScreen
@onready var music = $MusicManager

var intro_complete: bool = false
var max_combo: int = 0
var tutorial_audio: AudioStreamPlayer
var corrupt_audio: AudioStreamPlayer
var tutorial_stream: AudioStream
var corrupt_stream: AudioStream
var hell_mode_triggered: bool = false

func _ready():
	# Start the intro rhythm game
	rhythm_manager.rhythm_game_complete.connect(_on_intro_rhythm_complete)
	rhythm_manager.combo_changed.connect(_on_combo_changed)
	lose_screen.retry_pressed.connect(_on_retry_pressed)
	lose_screen.menu_pressed.connect(_on_menu_pressed)
	
	# Load audio files
	if ResourceLoader.exists("res://audio/tutorial.mp3"):
		tutorial_stream = load("res://audio/tutorial.mp3")
	if ResourceLoader.exists("res://audio/corrupt.mp3"):
		corrupt_stream = load("res://audio/corrupt.mp3")
	
	# Create audio players
	tutorial_audio = AudioStreamPlayer.new()
	add_child(tutorial_audio)
	tutorial_audio.finished.connect(_on_tutorial_audio_finished)
	
	corrupt_audio = AudioStreamPlayer.new()
	add_child(corrupt_audio)
	corrupt_audio.finished.connect(_on_corrupt_audio_finished)
	
	# Generate REGULAR sequence (enough notes for 25 seconds)
	# With spawn_interval of 1.0, we need ~25 notes for 25 seconds
	rhythm_manager.generate_challenge_sequence(30)
	rhythm_manager.start_rhythm_game()
	
	# Play tutorial music
	if tutorial_stream:
		tutorial_audio.stream = tutorial_stream
		tutorial_audio.play()
		print("[INTRO] Tutorial music playing, full length: ", tutorial_stream.get_length(), " seconds")
		
		# Stop tutorial after 25 seconds
		var tutorial_duration = 25.0
		get_tree().create_timer(tutorial_duration).timeout.connect(func():
			if tutorial_audio and tutorial_audio.playing:
				tutorial_audio.stop()
				print("[INTRO] Tutorial audio stopped at 25 seconds")
		)
		
		# Calculate when to trigger hell mode (2 seconds before 25 second mark)
		var hell_trigger_time = tutorial_duration - 2.0
		if hell_trigger_time > 0:
			get_tree().create_timer(hell_trigger_time).timeout.connect(trigger_hell_mode)
	else:
		# Fallback if no audio
		if music:
			music.play_rhythm_music()

func _on_combo_changed(combo: int):
	max_combo = max(max_combo, combo)

func trigger_hell_mode():
	if hell_mode_triggered:
		return
	hell_mode_triggered = true
	print("[INTRO] Hell mode triggered!")
	
	# Play corrupt sound effect
	if corrupt_stream:
		corrupt_audio.stream = corrupt_stream
		corrupt_audio.play()
		print("[INTRO] Playing corrupt sound effect")
	
	# Generate hell mode sequence
	rhythm_manager.generate_note_sequence()
	
	# Speed up existing notes
	rhythm_manager.current_fall_speed = 10.0

func _on_tutorial_audio_finished():
	print("[INTRO] Tutorial audio finished")

func _on_corrupt_audio_finished():
	print("[INTRO] Corrupt audio finished, proceeding to title sequence")
	# Proceed to jumpscare and title after corrupt sound
	proceed_to_jumpscare()

func _on_intro_rhythm_complete(_success: bool):
	if not is_inside_tree():
		return
	
	# If player somehow completes everything, proceed
	if hell_mode_triggered:
		proceed_to_jumpscare()

func _on_retry_pressed():
	# Don't actually retry - proceed to jumpscare
	lose_screen.visible = false
	proceed_to_jumpscare()

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")

func proceed_to_jumpscare():
	if music:
		music.stop_music()
	if tutorial_audio:
		tutorial_audio.stop()
	if corrupt_audio and not corrupt_audio.playing:
		# If corrupt hasn't played yet, play it now
		if corrupt_stream:
			corrupt_audio.stream = corrupt_stream
			corrupt_audio.play()
			await corrupt_audio.finished
	start_jumpscare_sequence()

func start_jumpscare_sequence():
	if not is_inside_tree():
		return
		
	# Stop corrupt audio if still playing
	if corrupt_audio and corrupt_audio.playing:
		corrupt_audio.stop()
		
	# Fade to black
	fade_to_black()
	await get_tree().create_timer(2.0).timeout
	
	# Show jumpscare video (trimmed to skip first 5 seconds)
	if jumpscare:
		jumpscare.show_jumpscare(func():
			# After video finishes, show title and transition
			if title_card:
				title_card.show_title()
			await get_tree().create_timer(3.0).timeout
			start_main_game()
		)

func fade_to_black():
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, 1.5)

func start_main_game():
	# Load the maze level
	get_tree().change_scene_to_file("res://levels/maze_level.tscn")
