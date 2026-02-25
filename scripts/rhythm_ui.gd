extends CanvasLayer

@onready var combo_label = $ComboLabel
@onready var accuracy_label = $AccuracyLabel
@onready var score_label = $ScoreLabel

var current_combo: int = 0
var current_accuracy: float = 0.0
var current_score: int = 0

func _ready():
	update_display()

func update_combo(combo: int):
	current_combo = combo
	update_display()
	
	# Combo flash effect
	if combo > 0:
		var tween = create_tween()
		tween.tween_property(combo_label, "scale", Vector2(1.3, 1.3), 0.1)
		tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.1)

func update_accuracy(accuracy: float):
	current_accuracy = accuracy
	update_display()

func update_score(score: int):
	current_score = score
	update_display()

func update_display():
	combo_label.text = "Combo: x%d" % current_combo
	accuracy_label.text = "%.1f%%" % current_accuracy
	score_label.text = "Score: %d" % current_score
	
	# Color combo based on value
	if current_combo >= 20:
		combo_label.add_theme_color_override("font_color", Color(1, 0.8, 0, 1))  # Gold
	elif current_combo >= 10:
		combo_label.add_theme_color_override("font_color", Color(0.8, 0.3, 1, 1))  # Purple
	elif current_combo >= 5:
		combo_label.add_theme_color_override("font_color", Color(0, 1, 1, 1))  # Cyan
	else:
		combo_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))  # White

func show_judgment(position: Vector2, text: String, color: Color):
	var label = Label.new()
	label.text = text
	label.position = position
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", color)
	label.z_index = 100
	add_child(label)
	
	# Animate and fade out
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", position.y - 50, 0.5)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.finished.connect(func(): label.queue_free())
