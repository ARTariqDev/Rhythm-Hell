extends AudioStreamPlayer

# Background music manager with looping

var intro_music: AudioStream
var maze_music: AudioStream
var rhythm_music: AudioStream

func _ready():
	# Try to load music files if they exist
	if ResourceLoader.exists("res://audio/intro_music.ogg"):
		intro_music = load("res://audio/intro_music.ogg")
	if ResourceLoader.exists("res://audio/maze_music.ogg"):
		maze_music = load("res://audio/maze_music.ogg")
	if ResourceLoader.exists("res://audio/rhythm_music.ogg"):
		rhythm_music = load("res://audio/rhythm_music.ogg")

func play_intro_music():
	if intro_music:
		stream = intro_music
		play()

func play_maze_music():
	if maze_music:
		stream = maze_music
		play()

func play_rhythm_music():
	if rhythm_music:
		stream = rhythm_music
		play()

func stop_music():
	stop()

func _on_finished():
	# Loop music
	if stream:
		play()
