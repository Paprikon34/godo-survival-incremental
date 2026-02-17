extends Resource
class_name EnemyData

@export var name: String = "Enemy"
@export var scene: PackedScene
@export var health: float = 10.0
@export var speed: float = 100.0
@export var damage: float = 10.0
@export var defense: float = 0.0
@export var xp_reward: float = 10.0
@export var is_boss: bool = false
@export var hp_scaling: float = 1.0
