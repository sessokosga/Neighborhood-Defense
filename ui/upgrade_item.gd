extends Control
class_name UpgradeItem

enum Type {Range,Damage,FireRate,Target,Accuracy,AttackSpeed}

@onready var bars = $"%Bars"
@onready var add_btn : TextureButton = $Add

signal increased(item)

@export var type : Type
var bars_number :int :
	set(v):
		bars_number = v
		if not is_instance_valid(bars):
			return 
		for i in range(bars.get_child_count()):
			if i<bars_number:
				bars.get_child(i).show()
			else:
				bars.get_child(i).hide() 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bars_number = 0
	add_btn.disabled = true
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func freeze_increse()->void:
	add_btn.disabled = true

func unfreeze_increse()->void:
	add_btn.disabled = false


func _on_add_pressed() -> void:
	if bars_number < 10:
		bars_number += 1
		increased.emit(self)
