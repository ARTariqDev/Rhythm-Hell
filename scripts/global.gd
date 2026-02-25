extends Node

# Global state for passing data between scenes
var last_rhythm_success: bool = false
var rhythm_stats: Dictionary = {}
var current_chest_id: int = -1
var maze_state: Dictionary = {}
var tutorial_shown: bool = false
