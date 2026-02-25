extends CanvasLayer

var video_player: VideoStreamPlayer
var jumpscare_finished_callback: Callable

func _ready():
	visible = false
	
	# Create video player
	video_player = VideoStreamPlayer.new()
	video_player.expand = true
	video_player.finished.connect(_on_video_finished)
	
	# Get viewport size and fill it
	var viewport_size = get_viewport().get_visible_rect().size
	video_player.custom_minimum_size = viewport_size
	video_player.size = viewport_size
	video_player.position = Vector2.ZERO
	
	# Anchor to fill screen
	video_player.anchor_left = 0
	video_player.anchor_top = 0
	video_player.anchor_right = 1
	video_player.anchor_bottom = 1
	video_player.offset_left = 0
	video_player.offset_top = 0
	video_player.offset_right = 0
	video_player.offset_bottom = 0
	
	add_child(video_player)
	
	# Try loading jumpscare video - try multiple formats
	var video_loaded = false
	var formats = ["ogv", "mp4", "webm"]
	for format in formats:
		var path = "res://jumpscares/jumpscare." + format
		if ResourceLoader.exists(path):
			var video_stream = load(path)
			video_player.stream = video_stream
			print("[JUMPSCARE] Video loaded successfully from: ", path)
			video_loaded = true
			break
	
	if not video_loaded:
		print("[JUMPSCARE] ERROR: No video file found in jumpscares folder!")
		print("[JUMPSCARE] Tried: .ogv, .mp4, .webm")
		print("[JUMPSCARE] Please convert jumpscare.mp4 to jumpscare.ogv using:")
		print("[JUMPSCARE]   ffmpeg -i jumpscare.mp4 -c:v libtheora -c:a libvorbis jumpscare.ogv")

func show_jumpscare(callback: Callable = Callable()):
	visible = true
	jumpscare_finished_callback = callback
	
	if video_player and video_player.stream:
		print("[JUMPSCARE] Starting video playback")
		video_player.play()
		video_player.paused = true
		video_player.stream_position = 5.0  # Skip first 5 seconds
		video_player.paused = false
		print("[JUMPSCARE] Video playing from 5 seconds, visible:", video_player.visible)
	else:
		print("[JUMPSCARE] No video available, skipping")
		# If no video, just call callback immediately
		if jumpscare_finished_callback.is_valid():
			jumpscare_finished_callback.call()

func _on_video_finished():
	print("[JUMPSCARE] Video finished")
	visible = false
	if jumpscare_finished_callback.is_valid():
		jumpscare_finished_callback.call()
