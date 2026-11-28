class_name Enemy
extends CharacterBody2D

const SOUL_SHARD_SCENE := preload("res://scenes/SoulShard.tscn")

@export var max_hp: float = 10.0
@export var speed: float = 150.0
@export var damage: int = 10
@export var xp_reward: float = 1.0

var hp: float = 10.0
var is_dead: bool = false
var player: CharacterBody2D = null

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	hp = max_hp
	player = get_tree().get_first_node_in_group("player")
	
func take_damage(amount: float) -> void:
	if is_dead:
		return
	hp -= amount
	if hp <= 0.0:
		die()
		
func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	collision_shape.set_deferred("disabled", true)
	drop_xp()
	animated_sprite.play("death")
	
func drop_xp() -> void:
	var shard := SOUL_SHARD_SCENE.instantiate()
	shard.global_position = global_position
	shard.xp_value = xp_reward
	get_parent().call_deferred("add_child", shard)
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "death":
		queue_free()
