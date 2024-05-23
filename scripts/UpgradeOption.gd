extends Node
class_name UpgradeOption

var damage = 0
var range = 0
var velocity = 0
var target = 0
var attack_speed = 0
var accuracy = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func save()->Dictionary:
	var res ={
		damage = damage,
		range = range,
		velocity = velocity,
		target = target,
		attack_speed = attack_speed,
		accuracy = accuracy
	}
	return res

func load(data:Dictionary)->void:
	if data == {}:
		return
	damage = data.damage
	range = data.range
	velocity = data.velocity
	target = data.target
	attack_speed = data.attack_speed
	accuracy = data.accuracy
