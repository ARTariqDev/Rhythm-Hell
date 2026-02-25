extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var title_label = $TitleLabel

func _ready():
	print("[MAIN_MENU] _ready() called")
	
	# Verify nodes exist
	if not start_button:
		print("[MAIN_MENU] ERROR: StartButton not found!")
		return
	if not quit_button:
		print("[MAIN_MENU] ERROR: QuitButton not found!")
		return
	
	print("[MAIN_MENU] Connecting button signals...")
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	print("[MAIN_MENU] Buttons connected successfully")

func _on_start_pressed():
	print("[MAIN_MENU] Start button pressed!")
	print("[MAIN_MENU] Changing scene to intro_level.tscn...")
	var result = get_tree().change_scene_to_file("res://intro_level.tscn")
	if result != OK:
		print("[MAIN_MENU] ERROR: Scene change failed with code: ", result)
	else:
		print("[MAIN_MENU] Scene change initiated")

func _on_quit_pressed():
	print("[MAIN_MENU] Quit button pressed!")
	get_tree().quit()
