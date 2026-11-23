extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var attack_cooldown_timer = $AttackCooldownTimer

var projectile_scene = preload("res://scenes/reaper_projectile.tscn")
var soul_shards_scene = preload("res://scenes/SoulShard.tscn")

var max_hp = 2
var hp = 2
var speed = 135
var attack_range = 280
var damage = 1
var xp_reward = 2

var is_dead = false
var is_attacking = false
var has_fired = false
var can_attack = true
var player = null

func _ready():
	hp = max_hp
	player = get_tree().get_first_node_in_group("player")
	attack_cooldown_timer.wait_time = 2.5
	attack_cooldown_timer.one_shot = true
	
func _physics_process(delta):
	if is_dead or player == null or player.is_dead:
		return
	var to_player = player.global_position - global_position
	var distance = to_player.length()
	var direction = to_player.normalized()
	
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0
		
	if is_attacking:
		velocity = Vector2.ZERO
		if animated_sprite.animation == "attack" and animated_sprite.frame == 4 and not has_fired:
			shoot_projectile(direction)
			has_fired = true
	elif distance > attack_range:
		velocity = direction * speed
		move_and_slide()
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")
	else:
		velocity = Vector2.ZERO
		if can_attack:
			is_attacking = true
			has_fired = false
			can_attack = false
			animated_sprite.play("attack")
		elif animated_sprite.animation != "idle":
			animated_sprite.play("idle")
					
func shoot_projectile(direction):
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.direction = direction
	projectile.damage = damage
	get_parent().add_child(projectile)
			
func take_damage(amount):
	if is_dead:
		return
	hp -= amount
	if hp <= 0:
		die()
		
func die():
	is_dead = true
	velocity = Vector2.ZERO
	collision_shape.set_deferred("disabled", true)
	
	var shard = soul_shards_scene.instantiate()
	shard.global_position = global_position
	shard.xp_value = xp_reward
	get_parent().call_deferred("add_child", shard)
	
	animated_sprite.play("death")
	
func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "attack":
		is_attacking = false
		animated_sprite.play("idle")
		attack_cooldown_timer.start()
	elif animated_sprite.animation == "death":
		queue_free()
		
func _on_attack_cooldown_timer_timeout() -> void:
	can_attack = true
