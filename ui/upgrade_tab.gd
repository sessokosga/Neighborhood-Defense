extends TextureButton
class_name UpgradeTab

signal toggl(tab)



@export var type:Tower.Type

@export var  initial_position : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if button_pressed:
		global_position = initial_position - Vector2(0,15)
	else:
		global_position = initial_position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		global_position.y = initial_position.y - 15
		z_index = 1
	else:
		global_position.y = initial_position.y
		z_index = 0
	
	toggl.emit(self)


func _on_pressed() -> void:
	button_pressed = true
		#disabled = true
	
				
