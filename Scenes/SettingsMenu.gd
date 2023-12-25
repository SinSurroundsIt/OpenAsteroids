extends CenterContainer

@onready var main_menu_button: Button = get_node("PanelContainer/MarginContainer/VBoxContainer/MenuButton")
@onready var music_slider: HSlider = get_node("PanelContainer/MarginContainer/VBoxContainer/MusicVolumeSlider")
@onready var sfx_slider: HSlider = get_node("PanelContainer/MarginContainer/VBoxContainer/SFXVolumeSlider")
@onready var ui_slider: HSlider = get_node("PanelContainer/MarginContainer/VBoxContainer/UIVolumeSlider")


func _ready():
	Events.settings_menu.connect(_Switch_To_This_Menu)
	main_menu_button.pressed.connect(_Main_Menu)
	music_slider.drag_ended.connect(_Update_Music)
	sfx_slider.drag_ended.connect(_Update_SFX)
	ui_slider.drag_ended.connect(_Update_UI)
	
	music_slider.value = GameSettings.music_volume
	sfx_slider.value = GameSettings.sfx_volume
	ui_slider.value = GameSettings.ui_volume


func _Switch_To_This_Menu():
	visible = true


func _Main_Menu():
	visible = false
	Events.main_menu.emit()


func _Update_Music(changed: bool):
	if changed:
		GameSettings.music_volume = music_slider.value


func _Update_SFX(changed: bool):
	if changed:
		GameSettings.sfx_volume_volume = sfx_slider.value


func _Update_UI(changed: bool):
	if changed:
		GameSettings.ui_volume = ui_slider.value
