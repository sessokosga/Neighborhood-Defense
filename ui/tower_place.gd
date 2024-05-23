extends Area2D
class_name TowerPlace

@onready var collision_shape : CollisionShape2D = $CollisionShape2D

var hovered = false
var joy_hovered = false
var size : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Hovered.hide()
	size = $TextureRect.size
	pass # Replace with function body.

func is_hovered()->bool:
	var rect = Rect2(global_position,collision_shape.shape.get_rect().size)
	return joy_hovered or rect.has_point(get_global_mouse_position()-Vector2(30-86,80-60))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_hovered():
		hovered = true 
		$Hovered.show()
	else:
		hovered = false
		$Hovered.hide()
		
	

func _on_body_entered(body) -> void:
	if body is Pointer:
		body.position = position
		print("hello")


func _on_area_entered(area: Area2D) -> void:
	if area is Pointer:
		joy_hovered = true 
		#area.global_position = global_position +Vector2(-12,59)


func _on_area_exited(area: Area2D) -> void:
	if area is Pointer:
		joy_hovered = false 
