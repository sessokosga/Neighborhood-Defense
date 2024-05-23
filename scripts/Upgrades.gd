extends Node
class_name Upgrades

var archer : UpgradeOption = UpgradeOption.new()
var bomber : UpgradeOption = UpgradeOption.new()
var sniper : UpgradeOption = UpgradeOption.new()
var electric : UpgradeOption = UpgradeOption.new()

func save()->Dictionary:
	var res = {
		archer = archer.save(),
		bomber = bomber.save(),
		sniper = sniper.save(),
		electric = electric.save()
	}
	return res
	
func load(data:Dictionary)->void:
	if data == {}:
		return
	archer.load(data.archer)
	bomber.load(data.bomber)
	sniper.load(data.sniper)
	electric.load(data.electric)
