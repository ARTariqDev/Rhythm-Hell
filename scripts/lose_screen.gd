extends CanvasLayer

signal retry_pressed()
signal menu_pressed()

@onready var title_label = $Panel/TitleLabel
@onready var stats_label = $Panel/StatsLabel
@onready var retry_button = $Panel/ButtonContainer/RetryButton
@onready var menu_button = $Panel/ButtonContainer/MenuButton

var accuracy: float = 0.0
var combo: int = 0
var notes_hit: int = 0
var notes_missed: int = 0

func _ready():
	# Allow processing when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func show_lose_screen(stats: Dictionary):
	visible = true
	get_tree().paused = true
	
	accuracy = stats.get("accuracy", 0.0)
	combo = stats.get("max_combo", 0)
	notes_hit = stats.get("notes_hit", 0)
	notes_missed = stats.get("notes_missed", 0)
	
	title_label.text = "YOU FAILED"
	stats_label.text = "Accuracy: %.1f%%\nBest Combo: %d\nHits: %d\nMisses: %d" % [accuracy, combo, notes_hit, notes_missed]

func _on_retry_pressed():
	get_tree().paused = false
	visible = false
	retry_pressed.emit()

func _on_menu_pressed():
	get_tree().paused = false
	visible = false
	menu_pressed.emit()
