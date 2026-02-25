extends CanvasLayer

@onready var title_label = $TitleLabel

func _ready():
	visible = false
	title_label.modulate.a = 0.0

func show_title():
	visible = true
	
	# Fade in title
	var tween = create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 1.0)
