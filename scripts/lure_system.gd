extends CanvasLayer

signal lure_placed(position: Vector2)

@onready var lures_label = $LuresUI/LuresLabel if has_node("LuresUI/LuresLabel") else null
@onready var timer_label = $LuresUI/TimerLabel if has_node("LuresUI/TimerLabel") else null
@onready var warning_label = $WarningLabel if has_node("WarningLabel") else null

var lures_remaining: int = 3
var lure_duration: float = 60.0  # 1 minute
var current_lure_timer: float = 0.0
var is_lure_active: bool = false
var warning_shown: bool = false

func _ready():
	print("[LURE] Lure system initialized with ", lures_remaining, " lures")
	update_lures_display()
	if warning_label:
		warning_label.visible = false

func _process(delta: float) -> void:
	if is_lure_active:
		current_lure_timer -= delta
		update_timer_display()
		
		# Show warning when 10 seconds left
		if current_lure_timer <= 10.0 and not warning_shown:
			show_warning()
			warning_shown = true
		
		if current_lure_timer <= 0:
			lure_expired()

func use_lure(position: Vector2):
	print("[LURE] use_lure called at position: ", position)
	if lures_remaining <= 0:
		print("[LURE] No lures remaining!")
		return
	
	print("[LURE] Placing lure! Remaining: ", lures_remaining - 1)
	lures_remaining -= 1
	is_lure_active = true
	current_lure_timer = lure_duration
	warning_shown = false
	update_lures_display()
	print("[LURE] Emitting lure_placed signal")
	lure_placed.emit(position)

func lure_expired():
	print("[LURE] Lure expired!")
	is_lure_active = false
	if warning_label:
		warning_label.visible = false

func show_warning():
	print("[LURE] Warning - 10 seconds remaining!")
	if warning_label:
		warning_label.visible = true
		warning_label.text = "⚠ LURE EXPIRING IN 10 SECONDS! ⚠"
		
		# Flash the warning
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(warning_label, "modulate:a", 0.0, 0.5)
		tween.tween_property(warning_label, "modulate:a", 1.0, 0.5)

func update_lures_display():
	if lures_label:
		lures_label.text = "Lures: " + str(lures_remaining)
	print("[LURE] Display updated - Lures remaining: ", lures_remaining)

func update_timer_display():
	var minutes = int(current_lure_timer) / 60.0
	var seconds = int(current_lure_timer) % 60
	if timer_label:
		timer_label.text = "Lure Time: %02d:%02d" % [minutes, seconds]
