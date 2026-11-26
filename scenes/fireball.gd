extends Area2D

@export var speed: float = 550.0

var damage: float = 1.0
var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
		
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
