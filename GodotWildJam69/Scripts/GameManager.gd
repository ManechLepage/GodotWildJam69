extends Node2D

@onready var player = %Player
@onready var scene_transitions:AnimationPlayer = %SceneTransitions
@onready var level_label = %LevelLabel
@onready var void_animation_timer = $VoidAnimationTimer

@export var levels:Array[PackedScene]

@export_group("Transition Colors")
@export var restart_color:Color
@export var skip_and_previous_color:Color
@export var complete_color:Color
@export var death_color:Color

var tile_map:TileMap
var current_level:int
var is_playing_animation:bool
var void_levels:Array[Array]
var current_void_step:int

func _ready():
	current_level = 0
	load_level(current_level)

func _process(delta):
	if is_playing_animation:
		if scene_transitions.current_animation_position / scene_transitions.current_animation_length > 0.5:
			load_level_after_animation(current_level)
			is_playing_animation = false

func load_level(level_index):
	scene_transitions.play("Fade_in")

func load_level_after_animation(level_index):
	if tile_map:
		tile_map.queue_free()
	tile_map = levels[level_index].instantiate()
	add_child(tile_map)
	player.position = tile_map.map_to_local(tile_map.initial_player_position)
	level_label.text = "Level " + get_level_name(level_index + 1)

func get_level_name(level_index:int):
	if level_index < 10:
		return "0" + str(level_index)
	else:
		return str(level_index)

func _input(event):
	if not is_playing_animation:
		if event.is_action_pressed("up"):
			move_player(Vector2i(0, -1))
			update_void()
			if is_player_dead():
				load_level(current_level)
		if event.is_action_pressed("down"):
			move_player(Vector2i(0, 1))
			update_void()
			if is_player_dead():
				load_level(current_level)
		if event.is_action_pressed("left"):
			move_player(Vector2i(-1, 0))
			update_void()
			if is_player_dead():
				load_level(current_level)
		if event.is_action_pressed("right"):
			move_player(Vector2i(1, 0))
			update_void()
			if is_player_dead():
				load_level(current_level)
	
	if event.is_action_pressed("restart"):
		update_transition_color(restart_color)
		load_level(current_level)

func move_player(direction:Vector2i):
	var player_pos = tile_map.local_to_map(player.position)
	var next_player_pos = player_pos + direction
	var next_tile:TileData = tile_map.get_cell_tile_data(1, next_player_pos)
	var can_move = false
	if not next_tile:
		can_move = true
	elif next_tile.get_custom_data("pushable"):
		var move = move_cell(next_player_pos, direction, [])
		if move[0]:
			push_cell(move[1], direction)
			can_move = true
	if can_move:
		player.position = tile_map.map_to_local(next_player_pos)
	rotate_player(direction)
	if is_player_on_goal():
		level_completed()
	if is_player_dead():
		update_transition_color(death_color)
		load_level(current_level)

func move_cell(tile_position:Vector2i, direction:Vector2i, tiles_to_push:Array):
	var next_tile:TileData = tile_map.get_cell_tile_data(1, tile_position + direction)
	tiles_to_push.append(tile_position)
	if next_tile:
		if next_tile.get_custom_data("pushable"):
			var move = move_cell(tile_position + direction, direction, tiles_to_push)
			return [move[0], move[1]]
		else:
			return [false, tiles_to_push]
	return [true, tiles_to_push]

func push_cell(tile_positions:Array, direction:Vector2i):
	tile_positions.reverse()
	for tile_position in tile_positions:
		tile_map.set_cell(1, tile_position + direction, 1, tile_map.get_cell_atlas_coords(1, tile_position))
		tile_map.erase_cell(1, tile_position)
		tile_map.erase_cell(2, tile_position + direction)
		print(tile_map.get_used_cells(2))

func rotate_player(direction:Vector2i):
	if direction.y == -1:
		player.rotation_degrees = 270
	if direction.y == 1:
		player.rotation_degrees = 90
	if direction.x == -1:
		player.rotation_degrees = 180
	if direction.x == 1:
		player.rotation_degrees = 0

func update_void():
	var void_cells = tile_map.get_used_cells(2)
	var new_cells:Array
	
	for cell in void_cells:
		var neighbours = tile_map.get_surrounding_cells(cell)
		for cell_neighbour in neighbours:
			if not tile_map.get_cell_tile_data(2, cell_neighbour):
				var resistance = 0
				if tile_map.get_cell_tile_data(1, cell_neighbour):
					resistance = tile_map.get_cell_tile_data(1, cell_neighbour).get_custom_data("void_resistance")
				elif tile_map.get_cell_tile_data(3, cell_neighbour):
					resistance = tile_map.get_cell_tile_data(3, cell_neighbour).get_custom_data("void_resistance")
				else:
					resistance = 1
				if check_for_void(cell_neighbour, resistance):
					new_cells.append(cell_neighbour)
	tile_map.set_cells_terrain_connect(2, tile_map.get_used_cells(2), 0, 0)
	void_levels.append(new_cells)

func check_for_void(cell_position:Vector2i, resistance:int):
	if resistance == 0:
		tile_map.set_cell(2, cell_position, 2, Vector2i(3, 3))
		update_void()
		return true
	if resistance == 1:
		tile_map.set_cell(2, cell_position, 2, Vector2i(3, 3))
		return true

func update_transition_color(color:Color):
	scene_transitions.get_child(0).color = color

func is_player_on_goal():
	return tile_map.get_cell_tile_data(0, tile_map.local_to_map(player.position)).get_custom_data("is_goal")

func is_player_dead():
	return tile_map.get_cell_tile_data(2, tile_map.local_to_map(player.position))

func _on_previous_button_pressed():
	if current_level > 0:
		current_level -= 1
		update_transition_color(skip_and_previous_color)
		load_level(current_level)

func _on_skip_button_pressed():
	if current_level + 1 < len(levels):
		current_level += 1
		update_transition_color(skip_and_previous_color)
		load_level(current_level)

func _on_scene_transitions_animation_started(anim_name):
	is_playing_animation = true

func level_completed():
	current_void_step = len(void_levels)
	void_animation_timer.wait_time = 0.25 / current_void_step
	void_animation_timer.start()

func next_void_step_in_animation():
	for cell in void_levels[current_void_step]:
		tile_map.erase_cell(2, cell)
	current_void_step -= 1
	if current_void_step < 0:
		void_levels = []
		if current_level + 1 < len(levels):
			current_level += 1
			update_transition_color(complete_color)
			load_level(current_level)
	else:
		void_animation_timer.start()
