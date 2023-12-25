extends HBoxContainer

@onready var level_counter: Label = get_node("LevelCount")
var _current_level: int


func _ready() -> void:
	Events.update_level.connect(_On_Update_Level)
	
func _On_Update_Level(_new_level: int):
	_current_level = _new_level
	level_counter.text = str(_current_level)
