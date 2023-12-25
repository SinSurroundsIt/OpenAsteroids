extends HBoxContainer

var _score: int

@onready var _score_label: Label = get_node("Label")
# Called when the node enters the scene tree for the first time.
func _ready():
	Events.update_score.connect(_Update_Score)
	pass # Replace with function body.


func _Update_Score(new_count: int):
	_score = new_count
	_score_label.text = str(_score)
