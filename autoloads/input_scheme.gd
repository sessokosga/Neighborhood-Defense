extends Node

signal input_scheme_changed(scheme)

enum Schemes {KeyboardAndMouse, Gamepad, TouchScreen}
var scheme : Schemes = Schemes.KeyboardAndMouse

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("joypad_enabled"):
		#if 
		#scheme

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if scheme != Schemes.Gamepad:
			scheme = Schemes.Gamepad
			input_scheme_changed.emit(scheme)
	else:
		if scheme != Schemes.KeyboardAndMouse:
			scheme = Schemes.KeyboardAndMouse
			input_scheme_changed.emit(scheme)
		
