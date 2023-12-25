extends CenterContainer

@onready var main_menu_button: Button = get_node("PanelContainer/MarginContainer/VBoxContainer/MenuButton")


func _ready():
	Events.controls_menu.connect(_Switch_To_This_Menu)
	main_menu_button.pressed.connect(_Main_Menu)


func _Switch_To_This_Menu():
	visible = true


func _Main_Menu():
	visible = false
	Events.main_menu.emit()
