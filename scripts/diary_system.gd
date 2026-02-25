extends CanvasLayer

var diary_panel: Panel
var diary_text: RichTextLabel
var close_button: Button

var diary_entries = [
	"Day 1: I don't remember how I got here. The walls shift and change. She's always watching...",
	"Day 7: The music helps. When I focus on the rhythm, I can almost forget she's there.",
	"Day 15: I found a pattern. The chests hold keys. But each one requires... a performance.",
	"Day 23: She was my wife. At least, I think she was. Before... whatever happened.",
	"Day 31: The lures work. Temporarily. She's drawn to sound, to movement. But I have so few left.",
	"Day 42: I'm getting faster. The rhythm becomes second nature when death chases you.",
	"Day 50: Is there an exit? Or is this hell eternal? Rhythm Hell, she called it once.",
	"Day 63: I saw her face today. For a moment, I recognized her. Then the monster returned.",
	"Day 77: Maybe if I collect all the keys, I can escape. Or maybe I'll just find more doors.",
	"Day 100: The music never stops. Neither does she. But neither do I."
]

var unlocked_entries: int = 0

signal diary_closed()

func _ready():
	# Allow processing when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Try to use existing scene nodes first, otherwise create them
	if has_node("DiaryPanel"):
		diary_panel = get_node("DiaryPanel")
		diary_text = get_node("DiaryPanel/DiaryText")
		close_button = get_node("DiaryPanel/CloseButton")
	else:
		# Create diary panel if it doesn't exist
		diary_panel = Panel.new()
		diary_panel.size = Vector2(600, 400)
		diary_panel.position = Vector2(
			(get_viewport().get_visible_rect().size.x - 600) / 2,
			(get_viewport().get_visible_rect().size.y - 400) / 2
		)
		add_child(diary_panel)
		
		# Create diary text
		diary_text = RichTextLabel.new()
		diary_text.bbcode_enabled = true
		diary_text.size = Vector2(560, 320)
		diary_text.position = Vector2(20, 20)
		diary_panel.add_child(diary_text)
		
		# Create close button
		close_button = Button.new()
		close_button.text = "Close"
		close_button.size = Vector2(100, 40)
		close_button.position = Vector2(250, 350)
		diary_panel.add_child(close_button)
	
	# Set properties regardless of whether nodes existed or were created
	diary_panel.visible = false
	diary_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	close_button.process_mode = Node.PROCESS_MODE_ALWAYS
	close_button.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Connect signal if not already connected
	if not close_button.pressed.is_connected(_on_close_pressed):
		close_button.pressed.connect(_on_close_pressed)

func show_new_entry(entry_id: int):
	if entry_id < diary_entries.size():
		unlocked_entries = max(unlocked_entries, entry_id + 1)
		show_diary(entry_id)

func show_diary(entry_id: int):
	diary_panel.visible = true
	diary_text.text = "=== Diary Scrap ===\n\n" + diary_entries[entry_id]
	get_tree().paused = true

func _on_close_pressed():
	diary_panel.visible = false
	get_tree().paused = false
	diary_closed.emit()
