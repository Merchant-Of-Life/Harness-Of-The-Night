extends CharacterBody2D


var attack_style = "magic"
var projectile_scene = preload("res://scenes/fireball.tscn")
var max_hp = 3
var hp = 3
var power = 1
var is_invulnerable = false
var is_dead = false
var is_hit_flashing = false
var flash_steps = 0

var speed = 220
var dash_speed = 650
var is_dashing = false
var can_dash = true
var is_charging = false
var dash_direction = Vector2.ZERO
var orbit_radius = 50
var aim_angle = 0.0
var max_charges = 6
var currect_charges = 6

@onready var animated_sprite = $AnimatedSprite2D
@onready var book = $Book
@onready var book_sprite = $Book/BookSprite
@onready var dash_timer = $DashTimer
@onready var cooldown_timer = $CooldownTimer

func _ready():
	hp = max_hp
	book_sprite.play("open")

func _physics_process(delta):
	if is_dead:
		return
		
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if Input.is_action_just_pressed("dash") and can_dash and direction != Vector2.ZERO:
		is_dashing = true
		can_dash = false
		dash_direction = direction
		$DashTimer.start()
		$CooldownTimer.start()
		
	if is_dashing:
		velocity = dash_direction * dash_speed
	else:
		velocity = direction * speed
		
	move_and_slide()
	update_book_orbit(delta)
	
	if Input.is_action_just_pressed("recharge") and not is_charging and not is_dashing:
		start_recharge()
	if Input.is_action_pressed("attack") and not is_charging and not is_dashing:
		if $AttackCooldownTimer.is_stopped():
			if currect_charges > 0:
				fire_projectile()
			else:
				start_recharge()
	update_animation(direction)
	
func update_book_orbit(delta):
	var mouse_offset = (get_global_mouse_position() - book_sprite.global_position)
	if mouse_offset.length() > 15.0:
		var target_angle = mouse_offset.angle()
		aim_angle = lerp_angle(aim_angle, target_angle, 12.0 * delta)
	var aim_direction = Vector2.from_angle(aim_angle)
	book_sprite.position = aim_direction * orbit_radius
	if aim_direction.y < 0:
		book_sprite.z_index = -1
	else:
		book_sprite.z_index = 1
	
func update_animation(direction):
	var mouse_pos = get_global_mouse_position()
	if mouse_pos.x < global_position.x:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
		
	if is_hit_flashing:
		$AnimatedSprite2D.play("hit")
	elif is_dashing:
		$AnimatedSprite2D.play("dash")
	elif direction != Vector2.ZERO:
		$AnimatedSprite2D.play("run")
	else:         
		$AnimatedSprite2D.play("idle")
		
func fire_projectile():
	currect_charges -= 1
	$AttackCooldownTimer.start()
	
	var projectile = projectile_scene.instantiate()
	var aim_direction = (get_global_mouse_position() - book_sprite.global_position).normalized()
	projectile.global_position = book_sprite.global_position
	projectile.direction = aim_direction
	projectile.rotation = aim_direction.angle()
	projectile.damage = power
	
	get_parent().add_child(projectile)
	
	if currect_charges <= 0:
		start_recharge()
		
func start_recharge():
	is_charging = true
	book_sprite.play_backwards("open")
	$RechargeTimer.start()
	
func _on_dash_timer_timeout():
	is_dashing = false
	
func _on_cooldown_timer_timeout():
	can_dash = true

func _on_recharge_timer_timeout():
	currect_charges = max_charges
	is_charging = false
	book_sprite.play("open")
	
func _on_hit_flash_timer_timeout():
	flash_steps += 1
	if flash_steps >= 6:
		is_hit_flashing = false
		$HitFlashTimer.stop()
	else:
		is_hit_flashing = not is_hit_flashing

func _on_iframes_timeout():
	is_invulnerable = false
	is_hit_flashing = false

func die():
	is_dead = true
	is_hit_flashing = false
	$HitFlashTimer.stop()
	velocity = Vector2.ZERO
	book.visible = false
	$CollisionShape2D.set_deferred("disabled", "true")
	animated_sprite.play("death")
	$DeathTimer.start()
	
func take_damage(amount):
	if is_invulnerable or is_dead:
		return
	hp -= amount
	print("Player HP: ", hp)
	if hp <= 0:
		die()
	else:
		is_invulnerable = true
		is_hit_flashing = true
		flash_steps = 0
		$Iframes.start()
		$HitFlashTimer.start()
		
func _on_death_timer_timeout():
	get_tree().reload_current_scene()
