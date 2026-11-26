extends Enemy

const PROJECTILE_SCENE := preload("res://scenes/reaper_projectile.tscn")

@export var attack_range: float = 280.0

var is_attacking: bool = false
var has_fired: bool = false
var can_attack: bool = true

@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer

func _init() -> void:
	max_hp = 2.0 
	speed = 135.0
	xp_reward = 2.0
	
func _physics_process(_delta:float) -> void:
	if is_dead or player == null or player.is_dead:
		return
		
	var to_player := player.global_position - global_position
	var distance := to_player.length()
	var direction := to_player.normalized()
	
	if direction.x != 0.0:
		animated_sprite.flip_h = direction.x < 0.0
	
	if is_attacking:
		velocity = Vector2.ZERO
		if animated_sprite.animation == "attack" and animated_sprite.frame == 4 and not has_fired:
			shoot_projectile(direction)
			has_fired = true
	elif distance > attack_range:
		velocity = direction * speed 
		move_and_slide()
		play_idle_if_needed()
	else:
		velocity = Vector2.ZERO
		if can_attack:
			start_attack()
		else:
			play_idle_if_needed()
				
func play_idle_if_needed() -> void:
	if animated_sprite.animation != "idle":
		animated_sprite.play("idle")
		
func start_attack() -> void:
	is_attacking = true
	has_fired = false
	can_attack = false
	animated_sprite.play("attack")
	
func shoot_projectile(direction: Vector2) -> void:
	var projectile := PROJECTILE_SCENE.instantiate()
	projectile.global_position = global_position
	projectile.direction = direction
	projectile.damage = damage
	get_parent().add_child(projectile)
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_attacking = false
		animated_sprite.play("idle")
		attack_cooldown_timer.start()
	else:
		super()
		
func _on_attack_cooldown_timer_timeout() -> void:
	can_attack = true
