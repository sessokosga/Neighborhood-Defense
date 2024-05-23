extends Area2D
class_name Pointer
var screen
var size 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen = get_window().size
	size = Vector2i(36,27)
	reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func reset():
	global_position = (screen - size)/2
	hide()
