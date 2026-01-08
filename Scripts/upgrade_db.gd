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
		"name": "Magic Shotgun",
		"description": "+1 Projectile",
		"type": "weapon_upgrade",
		"id": "multishot"
	},
	{
		"name": "Wand",
		"description": "Unlock/Upgrade Magic Wand",
		"type": "weapon_unlock",
		"id": "wand"
	},
	{
		"name": "Smart",
		"description": "XP Gain +10%",
		"type": "stat",
		"id": "smart"
	},
	{
		"name": "Despair",
		"description": "Enemies +5% HP/Speed, You get +10% XP",
		"type": "challenge",
		"id": "challenge"
	},
	{
		"name": "Vitality",
		"description": "Max Health +10%",
		"type": "stat",
		"id": "vitality"
	},
	{
		"name": "Luck",
		"description": "Luck +10%",
		"type": "stat",
		"id": "luck"
	}
]

static func get_random_upgrades(count: int) -> Array:
	var options = UPGRADES.duplicate()
	options.shuffle()
	return options.slice(0, count)

static func apply_upgrade(player: Node, upgrade_id: String):
	Global.log("Applying upgrade: " + upgrade_id)
	match upgrade_id:
		"heal":
			player.health = min(player.health + 20, player.max_health)
		"speed":
			player.speed *= 1.1
		"damage":
			player.damage_multiplier *= 1.1
		"smart":
			if "xp_multiplier" in player:
				player.xp_multiplier += 0.1
		"challenge":
			if "xp_multiplier" in player:
				player.xp_multiplier += 0.1
			# Need to reach Game node to buff enemies
			var game = player.get_parent() # Assuming Player is child of Game
			if game and "enemy_speed_multiplier" in game:
				game.enemy_speed_multiplier += 0.05
				game.enemy_health_multiplier += 0.05
				if game.has_method("update_all_enemies"):
					game.update_all_enemies()
				Global.log("Enemies Buffed! HP Multiplier: " + str(game.enemy_health_multiplier))
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
		"vitality":
			player.max_health *= 1.1
			player.health *= 1.1 # Also increase current health to match percentage
		"luck":
			if "luck_multiplier" in player:
				player.luck_multiplier += 0.1
