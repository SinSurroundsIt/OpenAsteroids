extends Node

const HIGH_SCORE_FILE_PATH = "user://highscore.save"
var _high_score_name: String = "Nullson"
var _high_score: int = -1

#On ready, loads the highscores from disk.
func _ready():
	_Load_Score()


func _Save_Score(_username: String, _new_score: int):
	if (_new_score > _high_score):
		var _score_file = FileAccess.open(HIGH_SCORE_FILE_PATH, FileAccess.WRITE)
		var _score_data: Dictionary = {"name": _username, "score": _new_score}
		var _json_string = JSON.stringify(_score_data)
		_score_file.store_line(_json_string)
		_score_file.close()
	
func _Load_Score():
	if not FileAccess.file_exists(HIGH_SCORE_FILE_PATH):
		return #No such file
	
	var _save_game = FileAccess.open(HIGH_SCORE_FILE_PATH, FileAccess.READ)
	
	while _save_game.get_position() < _save_game.get_length():
		var _json_string = _save_game.get_line()
		var json = JSON.new()
		
		var _parse_result = json.parse(_json_string)
		if not _parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", _json_string, " at line ", json.get_error_line())
			continue
			
		var _score_data = json.get_data()
		
		_high_score_name = _score_data["name"]
		_high_score = _score_data["score"]
	
	_save_game.close()
