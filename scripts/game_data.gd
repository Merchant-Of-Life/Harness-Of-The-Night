extends Node
var game_mode: String = "quick"

func is_timed_mode() -> bool:
	return game_mode == "quick" or game_mode == "standard"
	
func get_target_duration() -> int:
	match game_mode:
		"quick":
			return 600
		"standard":
			return 1200
		_:
			return 0
