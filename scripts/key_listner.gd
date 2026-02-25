extends Sprite2D

@onready var falling_key = preload("res://falling_keys.tscn")
@export var key_name: String = ""

# This script is just for visual key indicators
# The rhythm manager handles spawning notes
