extends CenterContainer

@onready var play_button: Button = get_node("PanelContainer/MarginContainer/VBoxContainer/PlayButton")
@onready var settings_button: Button = get_node("PanelContainer/MarginContainer/VBoxContainer/SettingsButton")
@onready var controls_button: Button = get_node("PanelContainer/MarginContainer/VBoxContainer/ControlsButton")
@onready var credits_button: Button = get_node("PanelContainer/MarginContainer/VBoxContainer/CreditsButton")
@onready var quit_button: Button = get_node("PanelContainer/MarginContainer/VBoxContainer/QuitButton")

var current_scene = null
var s = null

# Called when the node enters the scene tree for the first time.
func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	s = ResourceLoader.load("res://Scenes/level.tscn")
	
	#connect to all of the button signals
	play_button.pressed.connect(_Play_Game)
	settings_button.pressed.connect(_Settings_Menu)
	controls_button.pressed.connect(_Controls_Menu)
	credits_button.pressed.connect(_Credits_Menu)
	quit_button.pressed.connect(get_tree().quit)
	
	#connect to the menu signals to allow for easy switching.
	Events.main_menu.connect(_Switch_To_This_Menu)
		
	
func _Play_Game():
	call_deferred("_Call_Deferred_Switch_Scene")

func _Settings_Menu():
	visible = false
	Events.settings_menu.emit()

func _Controls_Menu():
	visible = false
	Events.controls_menu.emit()


func _Credits_Menu():
	visible = false
	Events.credits_menu.emit()


func _Call_Deferred_Switch_Scene():
	current_scene.queue_free()
	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
	current_scene.request_ready()
	
func _Switch_To_This_Menu():
	visible = true
