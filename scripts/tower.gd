class_name Tower
extends Area2D

const RADIUS_ARCHER = 150
const RADIUS_SNIPER = 150
const RADIUS_BOMBER = 150
const RADIUS_ELECTRIC = 150
const RANGE_COLOR = Color("0099b344")
const MAX_LEVEL = 5

enum Type {Archer,Sniper, Electric, Bomber }
enum AnimationsBomber {LevelOneIdle, LevelOneShoot, LevelTwoIdle, LevelTwoShoot, LevelThreeIdle, LevelThreeShoot,
						LevelFourIdle, LevelFourShoot, LevelFiveIdle, LevelFiveShoot}
enum Animations {Idle, ShootBotOne, ShootBotTwo, ShootSide, ShootTopOne, ShootTopTwo}

@onready var soldier :AnimatedSprite2D = $Soldier
@onready var building :AnimatedSprite2D = $Building
@onready var range : CollisionShape2D = $"%TowerRange"
@onready var range_mouse : CollisionShape2D = $RangeMouse
@onready var bullet_position : Sprite2D = $Soldier/Bullet
@onready var arrow_position : Sprite2D = $Soldier/Arrow
@export var is_display_only = false

var arrow_node = preload("res://scenes/arrow.tscn")
var bullet_node = preload("res://scenes/bullet.tscn")
var lighter_node = preload("res://scenes/lighter.tscn")
var bomb_node = preload("res://scenes/bomb.tscn")
var level : int = 1

const BOMBER_SHOOTING_ANIMATION = [
	"level_1_shoot",
	"level_2_shoot",
	"level_3_shoot",
	"level_4_shoot",
	"level_5_shoot",
]


var show_range = true
var type : Type :
	set(tp):
		type = tp
		_init_tower()
var target_zombie : Zombie = null
var target_queue : Array = []
var shoot_frequency : float = 15.0/60.0
var shoot_timer:float =0
var roation_speed = 1
var upgrades : Upgrades

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	upgrades = Upgrades.new()
	upgrades.load(PlayerData.retreive_upgrades())

func _init_tower()->void:
	match type:
		Type.Sniper:
			building.show()
			building.sprite_frames = load("res://scenes/towers_animations/sniper_tower.tres")
			soldier.sprite_frames = load("res://scenes/towers_animations/sniper.tres")
			soldier.play("idle")
			building.play("level_1")
			if is_display_only:
				return
			range.shape.radius = RADIUS_SNIPER + upgrades.sniper.range * 6
		Type.Archer:
			building.show()
			building.sprite_frames = load("res://scenes/towers_animations/archer_tower.tres")
			soldier.sprite_frames = load("res://scenes/towers_animations/archer.tres")
			soldier.play("idle")
			building.play("level_1")
			if is_display_only:
				return
			range.shape.radius = RADIUS_ARCHER + upgrades.archer.range * 6
		Type.Electric:
			building.hide()
			soldier.sprite_frames = load("res://scenes/towers_animations/electric.tres")
			soldier.play("level_1")
			if is_display_only:
				return
			range.shape.radius = RADIUS_ELECTRIC + upgrades.electric.range * 6
		Type.Bomber:
			building.hide()
			soldier.sprite_frames = load("res://scenes/towers_animations/bomber.tres")
			soldier.play("level_1_idle")
			if is_display_only:
				return
			range.shape.radius = RADIUS_BOMBER + upgrades.bomber.range * 6
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_display_only:
		return
	# Handle zombies
	if is_instance_valid(target_zombie) and target_zombie.health > 0:
		shoot_timer -= delta
		if type == Type.Sniper or type == Type.Archer :
			# Rotate toward zombies
			rotate_to_target(target_zombie,delta)
			if soldier.animation == "shoot_bot_1" :
				if soldier.frame == 11:
					shoot_at_target(target_zombie,delta)
		elif type == Type.Electric:
			if soldier.frame == 5:
				shoot_at_target(target_zombie,delta)
		elif  type == Type.Bomber:
			if soldier.frame == 10 and BOMBER_SHOOTING_ANIMATION.has(soldier.animation) :
				shoot_at_target(target_zombie,delta)
	else:
		if target_queue.size()>0:
			get_target()
		else:
			if type == Type.Sniper or type == Type.Archer :
				if soldier.animation != "idle":
					soldier.play("idle")
					soldier.rotation =  deg_to_rad(0)
			elif  type == Type.Bomber:
				if soldier.animation != str("level_",level,"_idle"):
					soldier.play(str("level_",level,"_idle"))

func shoot_at_target(target:Zombie,delta:float)->void:
	soldier.frame += 1
	match type:
		Type.Archer:
			var arrow :Projectile = arrow_node.instantiate()
			arrow.damage += upgrades.archer.damage
			arrow.velocity += upgrades.archer.velocity
			add_child(arrow)
			var angle = soldier.rotation - deg_to_rad(135)
			arrow.global_position = arrow_position.global_position
			arrow.rotate(angle)
			arrow.direction = (target.hit_box.global_position - global_position).normalized()
			AudioPlayer.play_sfx(AudioPlayer.SFX.ShootArrow)
			
		Type.Sniper:
			var bullet :Projectile = bullet_node.instantiate()
			bullet.damage += upgrades.sniper.damage
			bullet.velocity += upgrades.sniper.velocity
			add_child(bullet)
			var angle = soldier.rotation - deg_to_rad(135)
			bullet.global_position = bullet_position.global_position
			bullet.rotate(angle)
			bullet.direction = (target.hit_box.global_position - global_position).normalized()
			AudioPlayer.play_sfx(AudioPlayer.SFX.ShootBullet)
			
		Type.Electric:
			var lighter :Projectile = lighter_node.instantiate()
			lighter.damage += upgrades.electric.damage
			lighter.velocity += upgrades.electric.velocity
			add_child(lighter)
			var angle = soldier.rotation - deg_to_rad(135)
			lighter.position = Vector2(7,-49)
			lighter.direction = (target.hit_box.global_position - lighter.global_position).normalized()
			AudioPlayer.play_sfx(AudioPlayer.SFX.ShootElectric)
			
		Type.Bomber:
			var bomb :Projectile = bomb_node.instantiate()
			bomb.damage += upgrades.bomber.damage
			bomb.velocity += upgrades.bomber.velocity
			add_child(bomb)
			var angle = soldier.rotation - deg_to_rad(135)
			bomb.position = Vector2(-5,-59)
			bomb.direction = (target.hit_box.global_position - bomb.global_position).normalized()
			AudioPlayer.play_sfx(AudioPlayer.SFX.ShootBomb)
		

func rotate_to_target(target:Zombie,delta:float)->void:
	var direction = target.hit_box.global_position - global_position
	var angle_to = soldier.transform.x.angle_to(direction)
	var angle =0
	var angle_deg = rad_to_deg(soldier.rotation)
	
	angle = angle_to - deg_to_rad(135)
	soldier.rotate(angle)
	
	# soldier.rotate(sign(angle_to) * -1 * min(delta * roation_speed, abs(angle_to)) )

func _on_body_entered(body:Node2D)->void:
	if body is Zombie and body.health > 0:
		if target_zombie == null:
			target_zombie = body
			if type == Type.Archer or type == Type.Sniper:
				soldier.play("shoot_bot_1")
			elif type == Type.Bomber:
				soldier.play("level_1_shoot")
		else:
			target_queue.append(body)

func _on_body_exited(body:Node2D)->void:
	if is_display_only:
		return
	# Clear target
	var idx = -1
	var del = []
	for zombie in target_queue:
		idx += 1
		if zombie == body:
			del.append(idx)
	for i in del:
		target_queue.remove_at(i)
	
	if body == target_zombie:
		target_zombie = null
		
	# Get a new target
	if target_queue.size() > 0 and target_zombie == null :
		get_target()
		
func get_target(random = true)->void:
	var i = randi()%target_queue.size()
	target_zombie = target_queue[i]
	target_queue.remove_at(i)
	
func _draw()->void:
	if is_display_only:
		return
	if show_range:
		draw_circle(range.position,range.shape.radius,range.debug_color)

func _input(event: InputEvent) -> void:
	if is_display_only:
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if range_mouse.shape.get_rect().has_point(get_local_mouse_position()):
			show_range = true
		else:
			show_range = false
		queue_redraw()
