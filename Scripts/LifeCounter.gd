extends HBoxContainer

var _life_count: int

@onready var _life_label: Label = get_node("Label")
# Called when the node enters the scene tree for the first time.
func _ready():
	Events.new_lives.connect(_Update_Lives)
	pass # Replace with function body.


func _Update_Lives(new_count: int):
	_life_count = new_count
	_life_label.text = str(_life_count)
