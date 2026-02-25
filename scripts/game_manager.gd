extends Node

# Global game state manager

var current_level: int = 1
var total_keys_collected: int = 0
var diary_entries_unlocked: int = 0
var high_score: int = 0

# Game settings
const MAX_LURES = 3
const LURE_DURATION = 60.0
const MONSTER_WARNING_TIME = 10.0

# Audio settings
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 1.0

func reset_game():
	current_level = 1
	total_keys_collected = 0
	diary_entries_unlocked = 0

func save_game():
	var save_dict = {
		"current_level": current_level,
		"total_keys_collected": total_keys_collected,
		"diary_entries_unlocked": diary_entries_unlocked,
		"high_score": high_score
	}
	
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	save_file.store_var(save_dict)
	save_file.close()

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return
	
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	var save_dict = save_file.get_var()
	save_file.close()
	
	current_level = save_dict.get("current_level", 1)
	total_keys_collected = save_dict.get("total_keys_collected", 0)
	diary_entries_unlocked = save_dict.get("diary_entries_unlocked", 0)
	high_score = save_dict.get("high_score", 0)
