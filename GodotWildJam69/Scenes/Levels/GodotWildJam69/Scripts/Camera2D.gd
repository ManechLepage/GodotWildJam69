extends Camera2D

var random_strength:float
@export var shake_fade:float = 10.0
@export var random_door_strength:float = 15.0
@export var random_teleport_strength:float = 5.0

var rng = RandomNumberGenerator.new()

var shake_strength = 0.0

func apply_door_shake():
	random_strength = random_door_strength
	shake_strength = random_strength

func apply_teleport_shake():
	random_strength = random_teleport_strength
	shake_strength = random_strength

func random_offset():
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		
		offset = random_offset()
