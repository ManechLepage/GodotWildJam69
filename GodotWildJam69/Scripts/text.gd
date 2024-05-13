extends CanvasLayer

@onready var start_symbol = $MarginContainer/MarginContainer/HBoxContainer/StartSymbol
@onready var label = $MarginContainer/MarginContainer/HBoxContainer/Label2
@onready var end_symbol = $MarginContainer/MarginContainer/HBoxContainer/EndSymbol
@onready var animation_player = $AnimationPlayer

@export var beginning_textures:Array[Texture]

var text_queue:Array[StringName]

var is_start:bool = false
var is_end:bool = false

func _ready():
	hide_textbox()

func hide_textbox():
	$MarginContainer.visible = false
	start_symbol.text = ""
	label.text = ""
	end_symbol.text = ""

func show_textbox():
	$MarginContainer.visible = true
	start_symbol.text = "*"
	end_symbol.text = "*"

func beginning():
	is_start = true
	change_image(beginning_textures[0])
	text_queue.append("One thousand years ago, a strange matter called void started to take entire worlds.")
	text_queue.append("It was destroying one world at a time.")

	text_queue.append("Your city is now next in line.")
	text_queue.append("Thousands of people are dying a minute.")
	
	text_queue.append("The only way to escape is to go up the tower of the gods.")
	text_queue.append("A legend says that the tower reaches all the way up to heaven.")
	text_queue.append("The legend also says that climbing this tower is no easy task.")
	
	add_next_text()

func end():
	is_end = true
	text_queue.append("You did it! You reached the top of the tower of the gods.")
	text_queue.append("You are now safe from the void.")
	text_queue.append("For now...")
	
	add_next_text()

func add_next_text():
	if len(text_queue) > 0:
		add_text(text_queue[0])
		text_queue.remove_at(0)
		if is_start:
			if len(text_queue) == 4:
				change_image(beginning_textures[1])
			if len(text_queue) == 2:
				change_image(beginning_textures[2])
		elif is_end:
			change_image(beginning_textures[3])
	elif is_start:
		is_start = false
		get_tree().get_first_node_in_group("main_menu").start_game()

func add_text(text):
	label.text = text
	show_textbox()
	animation_player.get_animation_library_list()
	animation_player.queue("text_animation")
	animation_player.play()

func change_image(image:Texture):
	$Image/TextureRect.texture = image

func _input(event):
	if event.is_action_pressed("click"):
		add_next_text()
