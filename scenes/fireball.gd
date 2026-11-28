extends Area2D

@export var speed: float = 550.0
@export var explosion_radius: float = 85.0

var damage: float = 1.0
var direction: Vector2 = Vector2.RIGHT
var pierce_count: int = 0
var is_crescendo: bool = false
var hit_enemies: Array[Node2D] = []

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
func _on_body_entered(body: Node2D) -> void:
	if not body.has_method("take_damage") or body in hit_enemies:
		return
	hit_enemies.append(body)
	body.take_damage(damage)
	if is_crescendo:
		is_crescendo = false
		explode_around(body)
	if pierce_count > 0:
		pierce_count -= 1
	else:
		queue_free()
		
func explode_around(primary_target: Node2D) -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy is Node2D and enemy != primary_target and enemy.has_method("take_damage"):
			if enemy.global_position.distance_to(global_position) <= explosion_radius:
				enemy.take_damage(damage)
				
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
