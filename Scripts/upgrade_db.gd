class_name UpgradeDB

static var UPGRADES = [
	{
		"name": "Heal",
		"description": "Restore 20 Health",
		"type": "stat",
		"id": "heal",
		"weight": 10
	},
	{
		"name": "Swiftness",
		"description": "Move Speed +10%",
		"type": "stat",
		"id": "speed",
		"weight": 10
	},
	{
		"name": "Power",
		"description": "Damage +10%",
		"type": "stat",
		"id": "damage",
		"weight": 10
	},
	{
		"name": "Magic Shotgun",
		"description": "+1 Projectile",
		"type": "weapon_upgrade",
		"id": "magic_shotgun",
		"weight": 8
	},
	{
		"name": "Wand",
		"description": "Fires homing projectiles",
		"description_upgrade": "Cooldown -10%",
		"type": "weapon_unlock",
		"id": "wand",
		"weight": 5
	},
	{
		"name": "Smart",
		"description": "XP Gain +10%",
		"type": "stat",
		"id": "smart",
		"weight": 10
	},
	{
		"name": "Despair",
		"description": "Enemies +5% HP/Speed, You get +10% XP",
		"type": "challenge",
		"id": "challenge",
		"weight": 5
	},
	{
		"name": "Vitality",
		"description": "Max Health +10%",
		"type": "stat",
		"id": "vitality",
		"weight": 10
	},
	{
		"name": "Luck",
		"description": "Luck +10%",
		"type": "stat",
		"id": "luck",
		"weight": 10
	},
	{
		"name": "Piercing",
		"description": "Projectiles pierce +1 Enemy",
		"type": "stat",
		"id": "piercing",
		"weight": 5
	},
	{
		"name": "Defense",
		"description": "Defense +2.5",
		"type": "stat",
		"id": "defense",
		"weight": 8
	},
	{
		"name": "Regeneration",
		"description": "Regen +0.1 HP/s",
		"type": "stat",
		"id": "regeneration",
		"weight": 5
	},
	{
		"name": "Dagger",
		"description": "Fires forward rapidly",
		"description_upgrade": "Cooldown -10%",
		"type": "weapon_unlock",
		"id": "dagger",
		"weight": 5
	},
	{
		"name": "Scythe",
		"description": "Orbits and damages enemies",
		"description_upgrade": "+1 Scythe blade",
		"type": "weapon_unlock",
		"id": "scythe",
		"weight": 5
	},
	{
		"name": "Sword",
		"description": "High damage swing",
		"description_upgrade": "Damage +20%",
		"type": "weapon_unlock",
		"id": "sword",
		"weight": 4
	},
	{
		"name": "Relentless Rhythm",
		"description": "Attack Speed +10%",
		"type": "stat",
		"id": "attack_speed",
		"weight": 5
	}
]

static func get_random_upgrades(count: int) -> Array:
	var pool = UPGRADES.duplicate()
	var selected = []
	
	for i in range(count):
		if pool.is_empty():
			break
			
		var total_weight = 0.0
		for item in pool:
			total_weight += item.get("weight", 1)
			
		var roll = randf() * total_weight
		var current_weight = 0.0
		var picked_item = null
		
		for item in pool:
			current_weight += item.get("weight", 1)
			if roll <= current_weight:
				picked_item = item
				break
		
		if picked_item:
			selected.append(picked_item)
			pool.erase(picked_item) # Remove so we don't pick it again for this hand
			
	return selected

static func apply_upgrade(player: Node, upgrade_id: String):
	Global.console_log("Applying upgrade: " + upgrade_id)
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
				Global.console_log("Enemies Buffed! HP Multiplier: " + str(game.enemy_health_multiplier))
		"magic_shotgun":
			var mm = player.get_node_or_null("MagicShotgun")
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
		"piercing":
			if "piercing_count" in player:
				player.piercing_count += 1
		"defense":
			if "defense" in player:
				player.defense += 2.5
		"attack_speed":
			if "attack_speed_multiplier" in player:
				player.attack_speed_multiplier += 0.1
		"regeneration":
			if "regeneration" in player:
				player.regeneration += 0.1
		"dagger":
			var dagger = player.get_node_or_null("Dagger")
			if not dagger:
				# Add Dagger
				dagger = Node2D.new()
				dagger.name = "Dagger"
				dagger.set_script(load("res://Scripts/dagger.gd"))
				player.add_child(dagger)
			else:
				# Upgrade Dagger
				if "cooldown" in dagger:
					dagger.cooldown *= 0.9
		"scythe":
			var scythe = player.get_node_or_null("Scythe")
			if not scythe:
				scythe = Node2D.new()
				scythe.name = "Scythe"
				scythe.set_script(load("res://Scripts/scythe_weapon.gd"))
				player.add_child(scythe)
			else:
				if scythe.has_method("upgrade"):
					scythe.upgrade()
		"sword":
			var sword = player.get_node_or_null("Sword")
			if not sword:
				sword = Node2D.new()
				sword.name = "Sword"
				sword.set_script(load("res://Scripts/sword_weapon.gd"))
				player.add_child(sword)
			else:
				if sword.has_method("upgrade"):
					sword.upgrade()
