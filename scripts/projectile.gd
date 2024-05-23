class_name Projectile
extends Area2D

enum Type {Arrow, Bullet, Lighter, Bomb}

@export var velocity:float = 20
@export var type :Type
@export var damage : int =1
var direction:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * velocity

func body_entered(body: Node2D)->void:
	if body is Zombie:
		body.apply_damage(damage)
		velocity = 0
		hide()
		queue_free()
