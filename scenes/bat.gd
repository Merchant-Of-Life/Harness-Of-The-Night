extends CharacterBody2D

var speed = 170
var max_hp = 1
var hp = 1
var damage = 1
var xp_reward = 1
var is_dead = false

var player = null

@onready var animated_sprite = $AnimatedSprite2D
var xp_shard_scene = preload("res://scenes/SoulShard.tscn")

func _ready():
	hp = max_hp
	animated_sprite.play("fly")
	player = get_tree().get_first_node_in_group("player")
	
func _physics_process(delta):
	if is_dead:
		return
	if player != null:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		
		if direction.x < 0:
			animated_sprite.flip_h = true
		else: 
			animated_sprite.flip_h = false
		move_and_slide()
		
func take_damage(amount):
	if is_dead:
		return
	hp -= amount
	if hp <= 0:
		die()

func _on_hitbox_body_entered(body):
	if is_dead:
		return

	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		die()

func die():
	is_dead = true
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	drop_xp()
	animated_sprite.play("death")
	
func drop_xp():
	var shard = xp_shard_scene.instantiate()
	shard.global_position = global_position
	shard.xp_value = xp_reward
	get_parent().call_deferred("add_child", shard)
	
func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "death":
		queue_free()
