extends CharacterBody2D

var speed = 220
var dash_speed = 650
var is_dashing = false
var can_dash = true
var is_charging = false
var dash_direction = Vector2.ZERO

@onready var animated_sprite = $AnimatedSprite2D
@onready var dash_timer = $DashTimer
@onready var cooldown_timer = $CooldownTimer

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
    update_animation(direction)
    
func update_animation(direction):
     if direction.x <0:
         $AnimatedSprite2D.flip_h = true
     elif direction.x > 0:
         $AnimatedSprite2D.flip_h = false
     if is_dashing:
         $AnimatedSprite2D.play("dash")
     elif is_charging:
         $AnimatedSprite2D.play("charge")
     elif direction != Vector2.ZERO:
         $AnimatedSprite2D.play("run")
     else:         
        $AnimatedSprite2D.play("idle")
    
func _on_dash_timer_timeout():
    is_dashing = false
    
func _on_cooldown_timer_timeout():
    can_dash = true
