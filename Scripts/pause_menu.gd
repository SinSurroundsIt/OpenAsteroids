extends ColorRect

@onready var animator: AnimationPlayer = get_node("AnimationPlayer")
@onready var resume_button: Button = get_node("CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ResumeButton")
@onready var menu_button: Button = get_node("CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MenuButton")
@onready var quit_button: Button = get_node("CenterContainer/PanelContainer/MarginContainer/VBoxContainer/QuitButton")

var _current_scene = null
var s = null

func _ready() -> void:
	var _root = get_tree().root
	_current_scene = _root.get_child(_root.get_child_count() - 1)
	s = ResourceLoader.load("res://Scenes/main_menu.tscn")
	
	resume_button.pressed.connect(_Unpause)
	menu_button.pressed.connect(_To_Main_Menu)
	quit_button.pressed.connect(get_tree().quit)
	Events.game_state_changed.connect(_Game_State_Update)
	_Pause()
	
func _Game_State_Update(paused: bool):
	if paused == true: _Pause()
	else: _Unpause() 

func _Unpause():
	animator.play("Unpause")
	print("Unpause")
	get_tree().paused = false
	queue_free()
	
func _Pause():
	animator.play("Pause")
	print("Pause")
	get_tree().paused = true
	
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
