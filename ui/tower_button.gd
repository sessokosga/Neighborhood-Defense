class_name TowerButton
extends TextureButton

signal add_tower(tower_type,cost)
signal dragged(tower_button)
signal canceled()


#@onready var space = $Space

@export var type : Tower.Type = Tower.Type.Archer
@export var cost : int = 200

var reset_zone : Rect2
var is_button_down = false
var was_button_down = false
var reset_enabled = false

var text_normal : Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_normal = texture_normal
	is_button_down = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Handle mouse input
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if get_global_rect().has_point(get_global_mouse_position()):
			if not is_button_down:
				is_button_down = true
				texture_normal = texture_pressed
				dragged.emit(self)
		else:
			if is_button_down:
				reset()
				add_tower.emit(type,cost)
	
	if is_button_down:
		if get_global_mouse_position().y > 200 :
			reset_enabled = true
		if reset_zone.has_point(get_global_mouse_position()) and reset_enabled:
			reset()
			canceled.emit()

func set_active_status(is_active:bool):
	if is_active:
		is_button_down = true
		texture_normal = texture_pressed
	else:
		reset_enabled = true
		reset()

func reset()->void:
	is_button_down = false
	reset_enabled = false
	texture_normal = text_normal
	
