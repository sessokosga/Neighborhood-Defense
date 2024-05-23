@tool
extends TextureButton
class_name LevelItem

var active_normal = preload("res://assets/Level Select/Artboard 3 copy 2.png")
var active_pressed = preload("res://assets/Level Select/Artboard 3 copy 5.png")
var active_focus = preload("res://assets/Level Select/Artboard 3 copy 2 focus.png")
var normal_normal = preload("res://assets/Level Select/Artboard 3.png")
var normal_pressed = preload("res://assets/Level Select/Artboard 3 copy 3.png")
var normal_focus = preload("res://assets/Level Select/Artboard 3 focus.png")

signal start(level)
@onready var stars_parent = $Starts
@onready var star_none = $Starts/None
@onready var stars_one = $Starts/One
@onready var stars_two = $Starts/Two
@onready var stars_three = $Starts/Three
@onready var lab_level = $Level

@export var level : int = 1 : 
	set(l):
		level = l
		if is_instance_valid(lab_level) == false:
			return
		lab_level.text = str(level)

@export var active :bool = false :
	set(b):
		active = b
		if is_instance_valid(stars_parent) == false:
			return
		if active:
			texture_normal = active_normal
			texture_pressed = active_pressed
			#texture_focused = active_focus
			stars_parent.hide()
		else:
			texture_normal = normal_normal
			texture_pressed = normal_pressed
			#texture_focused = normal_focus
			stars_parent.show()

@export var stars :int = 0 :
	set(s):
		stars = s
		if is_instance_valid(star_none) == false:
			return
		star_none.hide()
		stars_one.hide()
		stars_two.hide()
		stars_three.hide()
		match stars:
			0:
				star_none.show()
			1:
				stars_one.show()
			2:
				stars_two.show()
			3:
				stars_three.show()
				

var selected = false : 
	set(v):
		selected = v
		if not is_instance_valid(normal_focus) or _disabled:
			return
		if InputScheme.scheme == InputScheme.Schemes.Gamepad:
			if active:
				if selected :
					#texture_normal = active_focus
					scale = Vector2(1.2,1.2)
				else:
					#texture_normal = active_normal
					scale = initial_scale
			else:
				if selected:
					#texture_normal = normal_focus
					scale = Vector2(1.2,1.2)
				else:
					#texture_normal = normal_normal
					scale = initial_scale
			
var _disabled = false : 
	set(d):
		_disabled = d
		if is_instance_valid(lab_level) == false:
			return
		if _disabled:
			lab_level.hide()
			stars_parent.hide()
		else:
			lab_level.show()
			if not active:
				stars_parent.show()
				
var initial_scale = Vector2.ONE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stars = stars
	active = active
	level = level
	_disabled = disabled


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if disabled != _disabled:
		_disabled = disabled
		


func _on_pressed() -> void:
	start.emit(level)
