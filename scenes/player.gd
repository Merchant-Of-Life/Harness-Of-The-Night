extends CharacterBody2D

var attack_style = "magic"
var projectile_scene = preload("res://scenes/light_bolt.tscn")

var speed = 220
var dash_speed = 650
var is_dashing = false
var can_dash = true
var is_charging = false
var dash_direction = Vector2.ZERO
var orbit_radius = 50
var max_charges = 6
var currect_charges = 6

@onready var animated_sprite = $AnimatedSprite2D
@onready var book = $Book
@onready var book_sprite = $Book/BookSprite
@onready var dash_timer = $DashTimer
@onready var cooldown_timer = $CooldownTimer

func _ready():
	book_sprite.play("open")

func _physics_process(delta):
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
	update_book_orbit()
	
	if Input.is_action_just_pressed("recharge") and not is_charging and not is_dashing:
		start_recharge()
	if Input.is_action_pressed("attack") and not is_charging and not is_dashing:
		if $AttackCooldownTimer.is_stopped():
			if currect_charges > 0:
				fire_projectile()
			else:
				start_recharge()
	update_animation(direction)
	
func update_book_orbit():
	var aim_direction = (get_global_mouse_position() - book_sprite.global_position).normalized()
	if aim_direction == Vector2.ZERO:
		aim_direction = Vector2.RIGHT
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
		
	if is_dashing:
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
