extends CharacterBody2D

signal hp_changed(current_hp: int, max_hp: int)
signal ammo_changed(current_charges: int, max_charges: int, is_charging: bool)
signal xp_changed(current_xp: float, xp_to_next: float, level: int)
signal leveled_up

const FIREBALL_SCENE := preload("res://scenes/fireball.tscn")

@export var attack_style: String = "magic"
@export var max_hp: int = 30
@export var speed: float = 220.0
@export var dash_speed: float = 650.0
@export var max_charges: int = 6

var hp: int = 30
var power: int = 10
var level: int = 1
var current_xp: float = 0.0
var xp_to_next_level: float = 10.0
var krakens_stack: int = 0
var xp_multiplier: float = 1.0
var dodge_chance: float = 0.0
var magnet_multiplier: float = 1.0
var recharge_speed_multiplier: float = 1.0
var projectile_count: int = 1
var damage_multiplier: float = 1.0
var projectile_speed_multiplier: float = 1.0
var bonus_pierce: int = 0
var has_crescendo: bool = false
var pending_level_ups: int = 0

var is_invulnerable: bool = false
var is_dead: bool = false
var is_hit_flashing: bool = false
var flash_steps: int = 0

var is_dashing: bool = false
var can_dash: bool = true
var is_charging: bool = false
var dash_direction: Vector2 = Vector2.ZERO
var orbit_radius: float = 50.0
var aim_angle: float = 0.0
var current_charges: int = 6

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var point_light: PointLight2D = $PointLight2D
@onready var book: Node2D = $Book
@onready var book_sprite: AnimatedSprite2D = $Book/BookSprite
@onready var dash_timer: Timer = $DashTimer
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var recharge_timer: Timer = $RechargeTimer
@onready var iframes_timer: Timer = $Iframes
@onready var hit_flash_timer: Timer = $HitFlashTimer
@onready var death_timer: Timer = $DeathTimer


func _ready() -> void:
	hp = max_hp
	current_charges = max_charges
	book_sprite.play("open")
	hp_changed.emit(hp, max_hp)
	ammo_changed.emit(current_charges, max_charges, is_charging)
	xp_changed.emit(current_xp, xp_to_next_level, level)
	
func _physics_process(delta: float) -> void:
	if is_dead:
		return
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if Input.is_action_just_pressed("dash") and can_dash and direction != Vector2.ZERO:
		is_dashing = true
		can_dash = false
		dash_direction = direction
		dash_timer.start()
		cooldown_timer.start()
	if is_dashing:
		velocity = dash_direction * dash_speed
	else:
		var current_move_speed: float = speed
		if is_charging:
			current_move_speed *= recharge_speed_multiplier
		velocity = direction * current_move_speed
	move_and_slide()
	update_book_orbit(delta)
	handle_combat_input()
	update_animation(direction)
	
func handle_combat_input() -> void:
	if is_charging or is_dashing:
		return
	if Input.is_action_just_pressed("recharge") and current_charges < max_charges:
		start_recharge()
	elif Input.is_action_pressed("attack") and attack_cooldown_timer.is_stopped():
		if current_charges > 0:
			fire_projectile()
		else:
			start_recharge()
			
func update_book_orbit(delta: float) -> void:
	var mouse_offset := get_global_mouse_position() - book.global_position
	if mouse_offset.length() > 15.0:
		aim_angle = lerp_angle(aim_angle, mouse_offset.angle(), 12.0 * delta)
	var aim_direction := Vector2.from_angle(aim_angle)
	book_sprite.position = aim_direction * orbit_radius
	book_sprite.z_index = -1 if aim_direction.y < 0.0 else 1
	
func update_animation(direction: Vector2) -> void:
	animated_sprite.flip_h = get_global_mouse_position().x < global_position.x
	if is_hit_flashing:
		animated_sprite.play("hit")
	elif is_dashing:
		animated_sprite.play("dash")
	elif direction != Vector2.ZERO:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
		
func fire_projectile() -> void:
	current_charges -= 1
	var is_crescendo_shot: bool = has_crescendo and current_charges == 0
	ammo_changed.emit(current_charges, max_charges, is_charging)
	attack_cooldown_timer.start()
	var base_direction: Vector2 = (get_global_mouse_position() - book_sprite.global_position).normalized()
	var spread_step: float = deg_to_rad(12.0)
	for i in range(projectile_count):
		var angle_offset: float = (i - (projectile_count - 1) / 2.0) * spread_step
		var shot_direction: Vector2 = base_direction.rotated(angle_offset)
		spawn_fireball(shot_direction, is_crescendo_shot)
	if current_charges <= 0:
		start_recharge()
		
func spawn_fireball(shot_direction: Vector2, is_crescendo_shot: bool) -> void:
	var projectile := FIREBALL_SCENE.instantiate()
	projectile.global_position = book_sprite.global_position
	projectile.direction = shot_direction
	projectile.rotation = shot_direction.angle()
	projectile.speed *= projectile_speed_multiplier
	projectile.pierce_count = bonus_pierce
	projectile.is_crescendo = is_crescendo_shot
	var shot_damage: float = calculate_shot_damage()
	if is_crescendo_shot:
		shot_damage *= 2.5
		projectile.scale *= 1.35
	projectile.damage = shot_damage
	get_parent().add_child(projectile)
	
func calculate_shot_damage() -> float:
	var final_damage: float = float(power) * damage_multiplier
	for i in range(krakens_stack):
		if randf() <= 0.60:
			final_damage *= 1.60
		else:
			final_damage *= 0.70
	return final_damage
	
func start_recharge() -> void:
	is_charging = true
	ammo_changed.emit(current_charges, max_charges, is_charging)
	book_sprite.play_backwards("open")
	recharge_timer.start()
	
func apply_skill(skill_id: String) -> void:
	match skill_id:
		"wick_and_flint":
			power += 4
			attack_cooldown_timer.wait_time *= 1.15
		"murmur":
			attack_cooldown_timer.wait_time = max(0.08, attack_cooldown_timer.wait_time * 0.75)
			recharge_timer.wait_time *= 1.20
		"guideness_of_light":
			point_light.texture_scale += 0.40
			speed = max(100.0, speed - 20.0)
		"quire":
			refill_and_increase_max_charges(2)
			recharge_timer.wait_time *= 1.25
		"swift":
			speed += 40.0
			point_light.texture_scale = max(0.35, point_light.texture_scale * 0.85)
		"grit_of_blood":
			heal_and_increase_max_hp(10)
			xp_multiplier *= 0.85
		"krakens_gamble":
			krakens_stack += 1
		"quick_chant":
			recharge_timer.wait_time = max(0.20, recharge_timer.wait_time * 0.65)
			recharge_speed_multiplier *= 0.75
		"glass_lantern":
			power += 6
			attack_cooldown_timer.wait_time = max(0.08, attack_cooldown_timer.wait_time * 0.70)
			reduce_max_hp(10)
		"veil_of_mist":
			dodge_chance = min(0.60, dodge_chance + 0.15)
			iframes_timer.wait_time = max(0.20, iframes_timer.wait_time * 0.70)
		"soul_beacon":
			magnet_multiplier *= 1.65
			xp_multiplier *= 1.20
			point_light.texture_scale = max(0.35, point_light.texture_scale * 0.80)
		"split_ember":
			projectile_count += 1
			damage_multiplier *= 0.65
		"searing_lance":
			bonus_pierce += 1
			projectile_speed_multiplier *= 1.20
			reduce_max_charges(1)
		"crescendo":
			has_crescendo = true
			reduce_max_charges(2)
			
func heal_and_increase_max_hp(amount: int) -> void:
	max_hp += amount
	hp = min(hp + amount, max_hp)
	hp_changed.emit(hp, max_hp)
	
func reduce_max_hp(amount: int) -> void:
	max_hp = max(10, max_hp - amount)
	hp = min(hp, max_hp)
	hp_changed.emit(hp, max_hp)
	
func refill_and_increase_max_charges(amount: int) -> void:
	max_charges += amount
	current_charges = max_charges
	is_charging = false
	recharge_timer.stop()
	book_sprite.play("open")
	ammo_changed.emit(current_charges, max_charges, is_charging)
	
func reduce_max_charges(amount: int) -> void:
	max_charges = max(1, max_charges - amount)
	current_charges = min(current_charges, max_charges)
	if current_charges <= 0 and not is_charging:
		start_recharge()
	else:
		ammo_changed.emit(current_charges, max_charges, is_charging)
		
func take_damage(amount: int) -> void:
	if is_invulnerable or is_dead:
		return
	if dodge_chance > 0.0 and randf() < dodge_chance:
		return
	hp = max(0, hp - amount)
	hp_changed.emit(hp, max_hp)
	if hp <= 0:
		die()
	else:
		is_invulnerable = true
		is_hit_flashing = true
		flash_steps = 0
		iframes_timer.start()
		hit_flash_timer.start()
		
func die() -> void:
	is_dead = true
	is_hit_flashing = false
	hit_flash_timer.stop()
	velocity = Vector2.ZERO
	book.visible = false
	collision_shape.set_deferred("disabled", true)
	animated_sprite.play("death")
	death_timer.start()
	
func gain_xp(amount: float) -> void:
	if is_dead:
		return
	current_xp += amount * xp_multiplier
	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		level += 1
		xp_to_next_level = round(xp_to_next_level * 1.2)
		pending_level_ups += 1
	xp_changed.emit(current_xp, xp_to_next_level, level)
	check_pending_level_ups()
	
func check_pending_level_ups() -> void:
	if pending_level_ups > 0 and not is_dead:
		pending_level_ups -= 1
		leveled_up.emit()
		
func _on_dash_timer_timeout() -> void:
	is_dashing = false
	
func _on_cooldown_timer_timeout() -> void:
	can_dash = true
	
func _on_recharge_timer_timeout() -> void:
	current_charges = max_charges
	is_charging = false
	book_sprite.play("open")
	ammo_changed.emit(current_charges, max_charges, is_charging)
	
func _on_hit_flash_timer_timeout() -> void:
	flash_steps += 1
	if flash_steps >= 6:
		is_hit_flashing = false
		hit_flash_timer.stop()
	else:
		is_hit_flashing = not is_hit_flashing
		
func _on_iframes_timeout() -> void:
	is_invulnerable = false
	is_hit_flashing = false
	hit_flash_timer.stop()
	
func _on_death_timer_timeout() -> void:
	if get_parent().has_method("show_game_over"):
		get_parent().show_game_over()
