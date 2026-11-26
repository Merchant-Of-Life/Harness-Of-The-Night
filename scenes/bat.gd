extends Enemy

@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D

func _ready() -> void:
	super()
	animated_sprite.play("fly")
	
func _physics_process(_delta: float) -> void:
	if is_dead or player == null:
		return
		
	var direction := global_position.direction_to(player.global_position)
	velocity = direction * speed
	animated_sprite.flip_h = direction.x < 0
	move_and_slide()
	
func die() -> void:
	hitbox_shape.set_deferred("disabled", true)
	super()
	
func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		die()
