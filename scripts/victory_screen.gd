extends CanvasLayer

@onready var time_label = $Panel/MarginContainer/VBoxContainer/TimeLabel
@onready var lures_label = $Panel/MarginContainer/VBoxContainer/LuresLabel
@onready var score_label = $Panel/MarginContainer/VBoxContainer/ScoreLabel
@onready var continue_button = $Panel/MarginContainer/VBoxContainer/ContinueButton

var elapsed_time: float = 0.0
var lures_used: int = 0
var total_score: int = 0
var max_possible_score: int = 0

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	continue_button.pressed.connect(_on_continue_pressed)

func show_victory(time: float, lures: int, score: int, max_score: int):
	elapsed_time = time
	lures_used = lures
	total_score = score
	max_possible_score = max_score
	
	var minutes = int(elapsed_time) / 60.0
	var seconds = int(elapsed_time) % 60
	
	time_label.text = "Time: %02d:%02d" % [minutes, seconds]
	lures_label.text = "Lures Used: %d / 3" % lures_used
	score_label.text = "Total Score: %d / %d (%.1f%%)" % [total_score, max_possible_score, (float(total_score) / max_score * 100.0) if max_score > 0 else 0.0]
	
	visible = true
	get_tree().paused = true

func _on_continue_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
