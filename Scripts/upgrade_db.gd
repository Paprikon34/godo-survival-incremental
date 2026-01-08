class_name UpgradeDB

static var UPGRADES = [
	{
		"name": "Heal",
		"description": "Restore 20 Health",
		"type": "stat",
		"id": "heal"
	},
	{
		"name": "Swiftness",
		"description": "Move Speed +10%",
		"type": "stat",
		"id": "speed"
	},
	{
		"name": "Power",
		"description": "Damage +10%",
		"type": "stat",
		"id": "damage"
	},
	{
		"name": "Multishot",
		"description": "Magic Missile +1 Projectile",
		"type": "weapon_upgrade",
		"id": "multishot"
	},
	{
		"name": "Wand",
		"description": "Unlock/Upgrade Magic Wand",
		"type": "weapon_unlock",
		"id": "wand"
	}
]

static func get_random_upgrades(count: int) -> Array:
	var options = UPGRADES.duplicate()
	options.shuffle()
	return options.slice(0, count)

static func apply_upgrade(player: Node, upgrade_id: String):
	print("Applying upgrade: ", upgrade_id)
	match upgrade_id:
		"heal":
			player.health = min(player.health + 20, 100) # Assuming max health 100... should export max
		"speed":
			player.speed *= 1.1
		"damage":
			player.damage_multiplier *= 1.1
		"multishot":
			var mm = player.get_node_or_null("MagicMissile")
			if mm:
				if "projectile_count" in mm:
					mm.projectile_count += 1
				else:
					mm.set("projectile_count", 2) # Assuming default is 1
		"wand":
			var wand = player.get_node_or_null("Wand")
			if not wand:
				# Add Wand
				wand = Node2D.new()
				wand.name = "Wand"
				wand.set_script(load("res://Scripts/wand.gd"))
				player.add_child(wand)
			else:
				# Upgrade Wand (e.g. cooldown)
				wand.cooldown *= 0.9
