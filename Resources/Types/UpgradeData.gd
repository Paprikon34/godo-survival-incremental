extends Resource
class_name UpgradeData

enum UpgradeType { STAT, WEAPON_UPGRADE, WEAPON_UNLOCK, CHALLENGE }

@export var id: String
@export var name: String
@export var description: String
@export var type: UpgradeType = UpgradeType.STAT
@export var icon: Texture
