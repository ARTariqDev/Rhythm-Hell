extends CanvasLayer

var tutorial_panel: Panel
var tutorial_label: Label
var continue_button: Button

var tutorial_messages = [
	"Welcome to Rhythm Hell!\n\nUse Arrow Keys or WASD to navigate the maze.\nAvoid the monster at all costs.",
	"You have 3 LURES to distract the monster.\n\nPress L to place a lure at your current position.\nThe monster will go to the lure for 60 seconds.",
	"Collect keys from colored CHESTS.\n\nWhen you touch a chest, you'll enter a rhythm challenge.\nHit the arrows perfectly to unlock it!",
	"Find DIARY ENTRIES scattered around.\n\nThey reveal the dark history of this place.\nRead them all to understand what happened here.",
	"Your goal: Collect all keys and escape.\n\nStay alive. Stay vigilant.\nGood luck..."
]

var current_message_index: int = 0
var shown_this_session: bool = false

func _ready():
	# Allow processing when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Create tutorial panel
	tutorial_panel = Panel.new()
	tutorial_panel.size = Vector2(700, 300)
	tutorial_panel.position = Vector2(
		(get_viewport().get_visible_rect().size.x - 700) / 2,
		(get_viewport().get_visible_rect().size.y - 300) / 2
	)
	add_child(tutorial_panel)
	
	# Create tutorial label
	tutorial_label = Label.new()
	tutorial_label.size = Vector2(660, 220)
	tutorial_label.position = Vector2(20, 20)
	tutorial_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tutorial_panel.add_child(tutorial_label)
	
	# Create continue button
	continue_button = Button.new()
	continue_button.text = "Continue"
	continue_button.size = Vector2(120, 40)
	continue_button.position = Vector2(290, 250)
	continue_button.process_mode = Node.PROCESS_MODE_ALWAYS
	continue_button.mouse_filter = Control.MOUSE_FILTER_STOP
	continue_button.pressed.connect(_on_continue_pressed)
	tutorial_panel.add_child(continue_button)
	
	if shown_this_session:
		visible = false
		return
	
	show_current_message()

func show_current_message():
	if current_message_index < tutorial_messages.size():
		tutorial_label.text = tutorial_messages[current_message_index]
		get_tree().paused = true
	else:
		finish_tutorial()

func _on_continue_pressed():
	current_message_index += 1
	if current_message_index < tutorial_messages.size():
		show_current_message()
	else:
		finish_tutorial()

func finish_tutorial():
	shown_this_session = true
	get_tree().paused = false
	visible = false
