class_name Zombie
extends CharacterBody2D

signal died(type,reward)

@onready var health_bar : TextureProgressBar = $HealthBar
@onready var animation : AnimatedSprite2D = $Animation
@onready var hit_box : CollisionShape2D = $Collision

enum State {Dead, Alive}
enum Animations {Back, Dead, Side, Front}
enum Type {One, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten}

var type : Type : 
	set(tp):
		type = tp
		init_zombie()
var health : int
var max_health : int 
var state: State 
var speed : float 
var direction : Vector2 = Vector2.ZERO
var target : Vector2

func init_zombie()->void:
	match type:
		Type.One:
			animation.sprite_frames = load("res://scenes/zombies_animations/zombie_1.tres")
			max_health = 15
			health = max_health
			speed = .5
			
		Type.Two:
			animation.sprite_frames = load("res://scenes/zombies_animations/zombie_2.tres")
			max_health = 20
			health = max_health
			speed = 1
			
		Type.Three:
			animation.sprite_frames = load("res://scenes/zombies_animations/zombie_3.tres")
			max_health = 25
			health = max_health
			speed = 1.5
			
		Type.Four:
			animation.sprite_frames = load("res://scenes/zombies_animations/zombie_4.tres")
			max_health = 25
			health = max_health
			speed = 2
			
		Type.Five:
			animation.sprite_frames = load("res://scenes/zombies_animations/zombie_5.tres")
			max_health = 30
			health = max_health
			speed = 2.5
			
		Type.Six:
			animation.sprite_frames = load("res://scenes/zombies_animations/zombie_6.tres")
			max_health = 35
			health = max_health
			speed = 3
			
		Type.Seven:
			animation.sprite_frames = load("res://scenes/zombies_animations/zombie_7.tres")
			max_health = 40
			health = max_health
			speed = 3.5
			
		Type.Eight:
			animation.sprite_frames = load("res://scenes/zombies_animations/zombie_8.tres")
			max_health = 45
			health = max_health
			speed = 4
			
		Type.Nine:
			animation.sprite_frames = load("res://scenes/zombies_animations/zombie_9.tres")
			max_health = 50
			health = max_health
			speed = 4.5
			
		Type.Ten:
			animation.sprite_frames = load("res://scenes/zombies_animations/zombie_10.tres")
			max_health = 60
			health = max_health
			speed = 5
			
		

func _ready() -> void:
	state = State.Alive
	animation.animation_finished.connect(_on_animation_finished)
	
func _process(delta: float) -> void:
	if state == State.Alive:
		position += direction * speed

func apply_damage(damage:int)->void:
	if health > 0:
		health -= damage
		health_bar.value = health * health_bar.max_value / max_health
		if health <= 0:
			health_bar.hide()
			animation.play("dead")
			AudioPlayer.play_sfx(AudioPlayer.SFX.ZombieExplosion)
			speed = 0
			died.emit(type,max_health)

func _on_animation_finished()->void:
	if animation.animation == "dead":
		state = State.Dead
		queue_free()
		
func play_animation(anim:Animations)->bool:
	match anim:
		Animations.Front:
			animation.play("front")
		Animations.Back:
			animation.play("back")
		Animations.Side:
			animation.play("side")
		_:
			push_error("Animation ",anim," not found")
	return true
		
