extends ColorRect

@onready var animator: AnimationPlayer = get_node("AnimationPlayer")
@onready var resume_button: Button = get_node("CCont/PCont/MCont/VBoxTop/NewGameBox/NewGameButton")
@onready var score_name: TextEdit = get_node("CCont/PCont/MCont/VBoxTop/NewGameBox/NameField")
@onready var menu_button: Button = get_node("CCont/PCont/MCont/VBoxTop/HBoxContainer/MenuButton")
@onready var quit_button: Button = get_node("CCont/PCont/MCont/VBoxTop/HBoxContainer/QuitButton")
@onready var high_score_name_label: Label = get_node("CCont/PCont/MCont/VBoxTop/CurrentHighScoreVBox/HBoxContainer/HighScoreName")
@onready var high_score_score_label: Label = get_node("CCont/PCont/MCont/VBoxTop/CurrentHighScoreVBox/HBoxContainer/HighScoreScore")

var _current_scene = null
var s = null

var _b_high_score: bool = false
var _current_score: int = 0

func _ready() -> void:
	var _root = get_tree().root
	_current_scene = _root.get_child(_root.get_child_count() - 1)
	s = ResourceLoader.load("res://Scenes/main_menu.tscn")
	
	resume_button.pressed.connect(_On_New_Game_Pressed)
	menu_button.pressed.connect(_To_Main_Menu)
	quit_button.pressed.connect(get_tree().quit)
	Events.game_over.connect(_Game_Over)
	high_score_name_label.text = HighScore._high_score_name
	high_score_score_label.text = str(HighScore._high_score)
	_Pause()

func _Unpause():
	animator.play("Unpause")
	
func _Pause():
	animator.play("Pause")
	
func _To_Main_Menu():
	print("To Main Menu")
	_Unpause()
	call_deferred("_Call_Deferred_Switch_Scene")
	queue_free()
	
func _Call_Deferred_Switch_Scene():
	_current_scene.queue_free()
	_current_scene = s.instantiate()
	get_tree().root.add_child(_current_scene)
	get_tree().current_scene = _current_scene
	
func _Game_Over(_score: int):
	_current_score = _score
	if _current_score > HighScore._high_score:
		_b_high_score = true
		score_name.visible = true
		resume_button.text = "SAVE / NEW GAME"
	else:
		_b_high_score = false
		score_name.visible = false
		resume_button.text = "NEW GAME"

func _On_New_Game_Pressed():
	_New_Game(_b_high_score, score_name.text, _current_score)
	_Unpause()
	queue_free()
	
func _New_Game(_b_high_score: bool, _score_name: String, _score: int):
	if _b_high_score:
		Events.save_score.emit(_score_name, _score)
		Events.new_game.emit()
	else:
		Events.new_game.emit()
	
