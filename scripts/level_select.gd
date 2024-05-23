extends Control

@onready var levels = $Levels
@onready var tabs = $"%Tab"
@onready var tabs_help = $"%TabHelp"
@onready var lab_money = $"%Money"
@onready var lab_level_title = $"%LevelTitle"
@onready var lab_help_title = $"%HelpTitle"
@onready var ctrl_upgrade = $HUD/Upgrade
@onready var ctrl_help = $HUD/Help
@onready var hud = $HUD
@onready var item_accuracy = $"%Accuracy"
@onready var item_damage = $"%Damage"
@onready var item_attack_speed = $"%AttackSpeed"
@onready var item_velocity = $"%Velocity"
@onready var item_range = $"%Range"
@onready var item_target = $"%Target"
@onready var dots = $"%Dots"
@onready var tower : Tower = $"%Tower"

enum Screen {Help, Upgrade, LevelSelect}

var active_screen = Screen.LevelSelect
var selected_dot = 0

var selected_update_tab : Tower.Type:
	set(v):
		selected_update_tab = v
		update_view()

var upgrades : Upgrades = Upgrades.new()

var money : int:
	set(v):
		money = v
		if not is_instance_valid(lab_money):
			return
		lab_money.text = str(money)
		check_upgrades()

var selected_level = -12
var unlocked_levels = 0

func get_active_option()->UpgradeOption:
	var option : UpgradeOption
	match selected_update_tab:
		Tower.Type.Archer:
			option = upgrades.archer
		Tower.Type.Bomber:
			option = upgrades.bomber
		Tower.Type.Sniper:
			option = upgrades.sniper
		Tower.Type.Electric:
			option = upgrades.electric
	return option

func update_view()->void:
	var option = get_active_option()
	item_accuracy.bars_number = option.accuracy
	item_range.bars_number = option.range
	item_target.bars_number = option.target
	item_damage.bars_number = option.damage
	item_velocity.bars_number = option.velocity
	item_attack_speed.bars_number = option.attack_speed

func hide_stuff()->void:
	hud.hide()
	ctrl_help.hide()
	ctrl_upgrade.hide()

func check_upgrades()->void:
	if money <= 0:
		get_tree().call_group("upgrade","freeze_increse")
	else:
		get_tree().call_group("upgrade","unfreeze_increse")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerData.init()
	upgrades.load(PlayerData.retreive_upgrades())
	unlocked_levels = PlayerData.retreive_unlocked_levels()
	selected_level = unlocked_levels-1
	money = PlayerData.retreive_balance()
	hide_stuff()
	selected_update_tab = Tower.Type.Archer
	_update_level_selection()
	
	InputScheme.input_scheme_changed.connect(
		func(scheme):
			if scheme != InputScheme.Schemes.Gamepad:
				for lvl : LevelItem in levels.get_children():
					lvl.scale = lvl.initial_scale
			else:
				levels.get_child(0).selected = true
				
	)
	
	for i in range(levels.get_child_count()):
		var lvl : LevelItem = levels.get_child(i)
		if i < unlocked_levels:
			lvl.disabled = false
			lvl.active = false
		if i == unlocked_levels-1:
			lvl.active = true
		if not OS.has_feature("mobile"):
			lvl.initial_scale = Vector2(.8,.8)
			lvl.scale = lvl.initial_scale
		lvl.start.connect(_on_level_pressed)
		
	for tab:UpgradeTab in tabs.get_children():
		tab.toggl.connect(_on_tab_pressed)
		
	for tab:UpgradeTab in tabs_help.get_children():
		tab.toggl.connect(_on_tab_pressed)
	
	for ut:UpgradeItem in get_tree().get_nodes_in_group("upgrade"):
		ut.increased.connect(_on_upgrade_bought)
		
	for dot :Dot in dots.get_children():
		dot.toggl.connect(_on_dot_pressed)
	
func _on_dot_pressed(dot:Dot):
	if dot.button_pressed:
		var i=0
		for dt:Dot in dots.get_children():
			i += 1
			if dt != dot:
				dt.button_pressed = false
			else:
				if tower.type == Tower.Type.Archer or tower.type == Tower.Type.Sniper:
					tower.building.play(str("level_",i))
				elif tower.type == Tower.Type.Electric:
					tower.soldier.play(str("level_",i))
				elif tower.type == Tower.Type.Bomber:
					tower.soldier.play(str("level_",i,"_idle"))
					
				lab_level_title.text = str("Level ",i)
			
	
func _on_upgrade_bought(ut:UpgradeItem)->void:
	var option :UpgradeOption = get_active_option()
	match ut.type:
		UpgradeItem.Type.Range:
			option.range = ut.bars_number
		UpgradeItem.Type.Damage:
			option.damage = ut.bars_number
		UpgradeItem.Type.Target:
			option.target = ut.bars_number
		UpgradeItem.Type.FireRate:
			option.velocity = ut.bars_number
		UpgradeItem.Type.Accuracy:
			option.accuracy = ut.bars_number
		UpgradeItem.Type.AttackSpeed:
			option.attack_speed = ut.bars_number
	money-=1

func _on_tab_pressed(tab:UpgradeTab)->void:
	if tab.button_pressed:
		if tab.type == Tower.Type.Archer:
			lab_help_title.text = "Archer Tower"
		elif tab.type == Tower.Type.Bomber:
			lab_help_title.text = "Bomber Tower"
		elif tab.type == Tower.Type.Sniper:
			lab_help_title.text = "Sniper Tower"
		elif tab.type == Tower.Type.Electric:
			lab_help_title.text = "Electric Tower"
		
		
		for t:UpgradeTab in tabs.get_children():
			if t != tab:
				t.button_pressed = false
				
		for t:UpgradeTab in tabs_help.get_children():
			if t != tab:
				t.button_pressed = false
			tower.type = tab.type
			tower._init_tower()
			dots.get_child(0).button_pressed = true
		selected_update_tab = tab.type
		

func _on_level_pressed(level:int)->void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _input(event: InputEvent) -> void:
	if InputScheme.scheme == InputScheme.Schemes.Gamepad:
		if event.is_action_pressed("ui_left"):
			selected_level -= 1
			if selected_level < 0:
				selected_level = unlocked_levels-1
				
		if event.is_action_pressed("ui_right"):
			selected_level += 1
			if selected_level >= levels.get_children().size() :
				selected_level = 0
			else:
				var lvl :LevelItem = levels.get_children()[selected_level]
				if lvl.disabled:
					selected_level = 0
		if event.is_action_pressed("ui_accept"):
			if selected_level >= 0:
				var lvl : LevelItem = levels.get_child(selected_level)
				lvl.texture_normal = lvl.texture_pressed
				lvl.pressed.emit()
		_update_level_selection()
	
func _update_level_selection()->void:
	if selected_level < 0 and selected_level >= levels.get_children().size():
		return
	var lvl :LevelItem = levels.get_children()[selected_level]
	lvl.selected = true
	
	for lv : LevelItem in levels.get_children():
		if lv != lvl:
			lv.selected = false
	


func _on_upgrade_pressed() -> void:
	hud.show()
	ctrl_upgrade.show()
	active_screen = Screen.Upgrade


func _on_close_upgrade_pressed() -> void:
	hud.hide()
	ctrl_upgrade.hide()
	ctrl_help.hide()
	if active_screen == Screen.Upgrade:
		PlayerData.save_upgrades(upgrades.save())
		PlayerData.save_balance(money)
	active_screen = Screen.LevelSelect


func _on_help_pressed() -> void:
	hud.show()
	ctrl_help.show()
	active_screen = Screen.Help
