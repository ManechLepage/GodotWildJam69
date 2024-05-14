extends AudioStreamPlayer

@export var clicks:Array[AudioStream]

func play_click():
	stream = clicks.pick_random()
	play()
