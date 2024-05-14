extends Control

@onready var menu_click = %MenuClick

@onready var level_ui = %LevelUI
@onready var game_manager = $"../.."
@onready var player = %Player
@onready var music = $"../../Music"
@onready var text = $"../../Text"

func _on_play_button_pressed():
	menu_click.play_click()
	visible = false
	text.visible = true
	text.beginning()

func start_game():
	level_ui.visible = true
	player.visible = true
	text.visible = false
	game_manager.start_game()

func start_end_scene():
	player.visible = false
	level_ui.visible = false
	text.visible = true
	text.end()
