extends Skeleton2D

@onready var equipment = {
	"Head": [$Torso/Head/Head/Equipment],
	"Body": [$Torso/Torso/Equipment],
	"Legs":
	[
		$Torso/UpperLegLeft/UpperLegLeft,
		$Torso/UpperLegLeft/LowerLegLeft/LowerLegLeft,
		$UpperLegRight,
		$LowerLegRight
	],
	"Arms":
	[
		$Torso/UpperArmLeft/UpperArmLeft,
		$Torso/UpperArmLeft/LowerArmLeft/LowerArmLeft,
		$UpperArmRight,
		$LowerArmRight
	],
	"Feet": [$Torso/UpperLegLeft/LowerLegLeft/FootLeft/FootLeft, $LowerLegRight/FootRight],
	"RightHand": [$LowerArmRight/WeaponRight],
	"LeftHand": [$Torso/UpperArmLeft/LowerArmLeft/WeaponLeft]
}


func equip_item(equipment_slot: String, item: Item):
	if not equipment.has(equipment_slot):
		return

	if equipment[equipment_slot].size() != item.equipment_texture_paths.size():
		return

	for i in range(equipment[equipment_slot].size()):
		equipment[equipment_slot][i].texture = load(item.equipment_texture_paths[i])


func unequip_item(equipment_slot: String):
	if not equipment.has(equipment_slot):
		return

	for i in range(equipment[equipment_slot].size()):
		equipment[equipment_slot][i].texture = null
