extends Node2D

@onready var maze_generator = $MazeGenerator
@onready var player = $Player
@onready var monster = $Monster
@onready var rhythm_manager = $RhythmManager
@onready var lure_system = $LureSystem
@onready var diary_system = $DiarySystem
@onready var rhythm_ui = $RhythmGameUI
@onready var camera = $Camera2D
@onready var lose_screen = $LoseScreen
@onready var music = $MusicManager

var current_level: int = 1
var chests = []
var keys_collected: int = 0
var keys_needed: int = 0
var in_rhythm_challenge: bool = false
var current_chest_id: int = -1
var tutorial_overlay: CanvasLayer
var elapsed_time: float = 0.0
var timer_display: CanvasLayer
var timer_label: Label
var key_display_container: HBoxContainer
var exit_door: Area2D
var total_rhythm_score: int = 0
var max_possible_score: int = 0
var initial_monster_speed: float = 0.0
var tutorial_shown_once: bool = false
var victory_screen: CanvasLayer

func _ready():
	# Add tutorial overlay only once
	if not tutorial_shown_once:
		# Create tutorial overlay from script (not scene file)
		var tutorial_script = preload("res://scripts/tutorial_overlay.gd")
		tutorial_overlay = CanvasLayer.new()
		tutorial_overlay.set_script(tutorial_script)
		add_child(tutorial_overlay)
		tutorial_shown_once = true
	
	# Add victory screen
	var victory_scene = preload("res://victory_screen.tscn")
	victory_screen = victory_scene.instantiate()
	add_child(victory_screen)
	
	# Create elapsed timer label and key display as CanvasLayer
	if not timer_display:
		timer_display = CanvasLayer.new()
		
		# Timer label
		timer_label = Label.new()
		timer_label.position = Vector2(10, 10)
		timer_label.add_theme_font_size_override("font_size", 32)
		timer_label.add_theme_color_override("font_color", Color.WHITE)
		timer_label.add_theme_color_override("font_outline_color", Color.BLACK)
		timer_label.add_theme_constant_override("outline_size", 4)
		timer_display.add_child(timer_label)
		
		# Key display container
		key_display_container = HBoxContainer.new()
		key_display_container.position = Vector2(10, 50)
		key_display_container.add_theme_constant_override("separation", 10)
		timer_display.add_child(key_display_container)
		
		add_child(timer_display)
		print("[MAZE] Timer and key display created")
	
	# Connect signals
	rhythm_manager.rhythm_game_complete.connect(_on_rhythm_complete)
	lure_system.lure_placed.connect(_on_lure_placed)
	monster.monster_reached_player.connect(_on_monster_caught_player)
	diary_system.diary_closed.connect(_on_diary_closed)
	lose_screen.retry_pressed.connect(_on_lose_retry_pressed)
	lose_screen.menu_pressed.connect(_on_lose_menu_pressed)
	
	if music:
		music.play_maze_music()
	
	# Check if returning from rhythm challenge
	if Global.rhythm_stats.size() > 0:
		print("[MAZE] Detected return from rhythm challenge")
		print("[MAZE] Global stats size: ", Global.rhythm_stats.size())
		print("[MAZE] Current chest ID: ", Global.current_chest_id)
		print("[MAZE] Last success: ", Global.last_rhythm_success)
		handle_rhythm_challenge_return()
	else:
		print("[MAZE] Starting new level")
		print("[MAZE] Global.rhythm_stats is empty - NOT returning from challenge")
		start_level(current_level)

func _process(delta: float) -> void:
	# Update elapsed time
	if not in_rhythm_challenge:
		elapsed_time += delta
	
	# Update timer display
	if timer_label:
		var minutes = int(elapsed_time) / 60.0
		var seconds = int(elapsed_time) % 60
		timer_label.text = "Elapsed Time: %02d:%02d" % [minutes, seconds]
	
	# Camera follows player
	camera.global_position = player.global_position
	
	# Check if player is at exit with all keys
	if exit_door and keys_collected >= keys_needed:
		var dist = player.global_position.distance_to(exit_door.global_position)
		if dist < 60:
			if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_F):
				show_victory_screen()

func start_level(level: int):
	current_level = level
	keys_collected = 0
	elapsed_time = 0.0
	total_rhythm_score = 0
	max_possible_score = 0
	print("[MAZE] Starting level ", level, " - Timer reset")
	
	# Generate maze
	maze_generator.generate_maze(level)
	keys_needed = maze_generator.chest_positions.size()
	
	# Place player at start
	player.add_to_group("player")
	player.set_position_on_grid(Vector2i(1, 1), maze_generator)
	player.keys_needed = keys_needed
	
	# Place monster at top right
	var monster_start = Vector2i(maze_generator.maze_width - 2, 1)
	monster.global_position = maze_generator.get_world_position(monster_start)
	monster.maze_generator = maze_generator
	initial_monster_speed = monster.move_speed
	
	# Create exit door at maze exit
	create_exit_door()
	
	# Create chests
	create_chests()
	
	# Start monster chase after a brief delay
	print("[MAZE] Starting level ", level)
	print("[MAZE] Player at: ", player.global_position)
	print("[MAZE] Monster at: ", monster.global_position)
	if is_inside_tree():
		await get_tree().create_timer(3.0).timeout
		monster.start_chase(player)
		print("[MAZE] Monster chase started!")

func create_chests():
	# Clear existing chests
	for chest in chests:
		chest.queue_free()
	chests.clear()
	
	# Create new chests
	var chest_scene = preload("res://objects/chest.tscn")
	var colors = [Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW, Color.MAGENTA, Color.CYAN]
	
	for i in range(maze_generator.chest_positions.size()):
		var chest_pos = maze_generator.chest_positions[i]
		var chest = chest_scene.instantiate()
		chest.chest_id = i
		chest.chest_color = colors[i % colors.size()]
		chest.global_position = maze_generator.get_world_position(chest_pos)
		chest.chest_activated.connect(_on_chest_activated)
		add_child(chest)
		chests.append(chest)

func _on_chest_activated(chest_id: int):
	if in_rhythm_challenge:
		return
	
	current_chest_id = chest_id
	start_rhythm_challenge()

func start_rhythm_challenge():
	in_rhythm_challenge = true
	player.disable_movement()
	
	# Make monster VERY slow during rhythm challenge
	monster.move_speed = initial_monster_speed * 0.15  # 85% slower!
	print("[MAZE] Monster slowed to ", monster.move_speed, " during rhythm challenge")
	
	# Save maze state
	Global.maze_state = {
		"level": current_level,
		"keys_collected": keys_collected,
		"keys_needed": keys_needed,
		"player_position": player.global_position,
		"monster_position": monster.global_position,
		"total_rhythm_score": total_rhythm_score,
		"max_possible_score": max_possible_score,
		"elapsed_time": elapsed_time,
		"unlocked_chests": []
	}
	
	# Save which chests are already unlocked
	for i in range(chests.size()):
		if chests[i].is_unlocked:
			Global.maze_state.unlocked_chests.append(i)
	
	# Save current chest ID for when we return
	Global.current_chest_id = current_chest_id
	
	print("[MAZE] Saved maze state - Keys: ", keys_collected, " Chest: ", current_chest_id)
	
	# Transition to rhythm challenge scene
	get_tree().change_scene_to_file("res://rhythm_challenge.tscn")
	print("[MAZE] Scene change to rhythm challenge initiated")

func handle_rhythm_challenge_return():
	print("[MAZE] Handling rhythm challenge return")
	
	# Restore state
	current_chest_id = Global.current_chest_id
	var success = Global.last_rhythm_success
	var stats = Global.rhythm_stats
	var maze_state = Global.maze_state
	
	print("[MAZE] Success: ", success, " Chest ID: ", current_chest_id)
	
	# Restore the maze level first
	if maze_state.size() > 0:
		current_level = maze_state.get("level", 1)
		keys_collected = maze_state.get("keys_collected", 0)
		keys_needed = maze_state.get("keys_needed", 0)
		elapsed_time = maze_state.get("elapsed_time", 0.0)
		total_rhythm_score = maze_state.get("total_rhythm_score", 0)
		max_possible_score = maze_state.get("max_possible_score", 0)
		
		print("[MAZE] Restoring maze - Level: ", current_level, " Keys: ", keys_collected)
		
		# Generate the same maze
		maze_generator.generate_maze(current_level)
		
		# Recreate chests
		create_chests()
		
		# Recreate exit door
		create_exit_door()
		
		# Restore key sprites
		for i in range(keys_collected):
			if i < chests.size():
				add_key_sprite(chests[i].chest_color)
		
		# Restore player position
		player.add_to_group("player")
		player.global_position = maze_state.get("player_position", Vector2.ZERO)
		player.keys_collected = keys_collected
		player.keys_needed = keys_needed
		
		# Restore monster position and speed
		monster.global_position = maze_state.get("monster_position", Vector2.ZERO)
		monster.maze_generator = maze_generator
		initial_monster_speed = monster.move_speed  # Save the base speed
		monster.start_chase(player)
		
		# Restore unlocked chests
		var unlocked = maze_state.get("unlocked_chests", [])
		for chest_idx in unlocked:
			if chest_idx < chests.size():
				chests[chest_idx].unlock()
				chests[chest_idx].visible = false  # Hide collected chests
	
	# Clear global state
	Global.rhythm_stats = {}
	Global.current_chest_id = -1
	Global.maze_state = {}
	
	# Force camera to player position immediately
	if camera:
		camera.global_position = player.global_position
		camera.reset_smoothing()
	
	# Hide tutorial overlay if it's showing
	if has_node("TutorialOverlay"):
		var tutorial = get_node("TutorialOverlay")
		tutorial.visible = false
	
	if success:
		# Restore normal monster speed and increase it per key
		monster.move_speed = initial_monster_speed * (1.0 + (keys_collected * 0.1))
		print("[MAZE] Monster speed increased to ", monster.move_speed)
		
		# Add score to total
		total_rhythm_score += stats.get("score", 0)
		max_possible_score += stats.get("max_possible_score", 1500)  # Use actual max from rhythm game
		
		# Unlock chest and give key
		if current_chest_id >= 0 and current_chest_id < chests.size():
			var chest = chests[current_chest_id]
			chest.unlock()
			keys_collected += 1
			player.keys_collected = keys_collected
			
			# Add key sprite to display
			add_key_sprite(chest.chest_color)
			
			# Hide the chest after collecting
			chest.visible = false
			
			print("[MAZE] Key collected! Keys: ", keys_collected, "/", keys_needed)
			
			# Show diary entry on success
			if diary_system and current_chest_id < 10:
				await get_tree().create_timer(0.5).timeout
				print("[MAZE] Showing diary for chest ", current_chest_id)
				diary_system.show_diary(current_chest_id)
	else:
		# Restore normal monster speed on failure
		monster.move_speed = initial_monster_speed * (1.0 + (keys_collected * 0.1))
		# Failed - show game over
		print("[MAZE] Rhythm challenge failed - game over")
		lose_screen.show_lose_screen(stats)
	
	in_rhythm_challenge = false
	player.enable_movement()

func _on_rhythm_complete(success: bool):
	rhythm_ui.visible = false
	
	if success:
		# Unlock chest and give key
		chests[current_chest_id].unlock()
		keys_collected += 1
		player.keys_collected = keys_collected
		var stats = {
			"accuracy": rhythm_manager.get_accuracy(),
			"max_combo": rhythm_manager.max_combo,
			"notes_hit": rhythm_manager.total_notes_hit,
			"notes_missed": rhythm_manager.total_notes_missed
		}
		lose_screen.show_lose_screen(stats)

func _on_lose_retry_pressed():
	in_rhythm_challenge = false
	player.enable_movement()

func _on_lose_menu_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
		# Failed - show jumpscare and game over
	show_jumpscare()
	if is_inside_tree():
		await get_tree().create_timer(2.0).timeout
		restart_level()

func _on_diary_closed():
	in_rhythm_challenge = false
	player.enable_movement()
	# Force camera back to player
	if camera:
		camera.global_position = player.global_position
		camera.reset_smoothing()
	# Force camera back to player
	if camera:
		camera.global_position = player.global_position
		camera.reset_smoothing()

func _on_lure_placed(lure_position: Vector2):
	monster.lure_to_position(lure_position, 60.0)
	
	# Create visual indicator for lure
	var lure_sprite = Sprite2D.new()
	lure_sprite.position = lure_position
	add_child(lure_sprite)
	
	# Create a simple circle shape for the lure
	var lure_texture = create_lure_texture()
	lure_sprite.texture = lure_texture
	lure_sprite.modulate = Color(1.0, 0.8, 0.2)  # Yellow-orange color
	
	# Add pulsing animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(lure_sprite, "scale", Vector2(1.2, 1.2), 0.5)
	tween.tween_property(lure_sprite, "scale", Vector2(1.0, 1.0), 0.5)
	
	# Remove lure sprite after 60 seconds
	await get_tree().create_timer(60.0).timeout
	if is_instance_valid(lure_sprite):
		var fade_tween = create_tween()
		fade_tween.tween_property(lure_sprite, "modulate:a", 0.0, 0.5)
		await fade_tween.finished
		lure_sprite.queue_free()

func create_lure_texture() -> ImageTexture:
	# Create a simple circular texture for the lure
	var size = 32
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	
	var center = Vector2(size / 2, size / 2)
	var radius = size / 2 - 2
	
	for x in range(size):
		for y in range(size):
			var dist = Vector2(x, y).distance_to(center)
			if dist <= radius:
				var alpha = 1.0 - (dist / radius) * 0.3
				image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	
	return ImageTexture.create_from_image(image)

func _on_monster_caught_player():
	# Game over
	show_jumpscare()
	if is_inside_tree():
		await get_tree().create_timer(2.0).timeout
		restart_level()

func show_jumpscare():
	var jumpscare = $JumpscareLayer
	jumpscare.show_jumpscare(func():
		# After jumpscare video, show lose screen
		lose_screen.show_lose(elapsed_time)
	)

func restart_level():
	get_tree().reload_current_scene()

func level_complete():
	# Move to next level
	current_level += 1
	start_level(current_level)

func create_exit_door():
	# Remove old exit door if exists
	if exit_door:
		exit_door.queue_free()
	
	exit_door = Area2D.new()
	exit_door.global_position = maze_generator.get_world_position(maze_generator.exit_position)
	
	# Visual representation - glowing door
	var sprite = Sprite2D.new()
	var image = Image.create(64, 96, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 1.0, 0.5, 0.8))  # Bright green
	sprite.texture = ImageTexture.create_from_image(image)
	exit_door.add_child(sprite)
	
	# Add prompt label
	var prompt_label = Label.new()
	prompt_label.text = "Press F to Exit"
	prompt_label.position = Vector2(-50, -60)
	prompt_label.add_theme_font_size_override("font_size", 20)
	prompt_label.add_theme_color_override("font_color", Color.YELLOW)
	prompt_label.add_theme_color_override("font_outline_color", Color.BLACK)
	prompt_label.add_theme_constant_override("outline_size", 3)
	exit_door.add_child(prompt_label)
	
	# Add glowing effect
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(sprite, "modulate:a", 0.5, 1.0)
	tween.tween_property(sprite, "modulate:a", 1.0, 1.0)
	
	# Collision shape
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(64, 96)
	collision.shape = shape
	exit_door.add_child(collision)
	
	add_child(exit_door)
	print("[MAZE] Exit door created at: ", exit_door.global_position)

func add_key_sprite(color: Color):
	if not key_display_container:
		return
	
	# Create a small colored square to represent the key
	var key_rect = ColorRect.new()
	key_rect.custom_minimum_size = Vector2(32, 32)
	key_rect.color = color
	key_display_container.add_child(key_rect)
	print("[MAZE] Added key sprite with color: ", color)

func show_victory_screen():
	print("[MAZE] Victory! Showing victory screen")
	var lures_used = 3 - lure_system.lures_remaining
	victory_screen.show_victory(elapsed_time, lures_used, total_rhythm_score, max_possible_score)

func _input(event):
	# Allow player to place lures with L key
	if event is InputEventKey and event.pressed and event.keycode == KEY_L and not in_rhythm_challenge:
		print("[MAZE] L key pressed! Attempting to place lure...")
		print("[MAZE] Lures remaining: ", lure_system.lures_remaining)
		# Place lure at player's current position
		var lure_pos = player.global_position
		print("[MAZE] Placing lure at player position: ", lure_pos)
		lure_system.use_lure(lure_pos)
