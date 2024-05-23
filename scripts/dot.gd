extends TextureButton
class_name Dot

signal toggl(dot)



func _on_toggled(toggled_on: bool) -> void:
	toggl.emit(self)
