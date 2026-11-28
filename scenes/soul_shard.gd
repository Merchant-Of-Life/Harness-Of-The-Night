extends Area2D

@export var magnet_radius: float = 110.0
@export var move_speed: float = 350.0

var xp_value: float = 1.0
var is_magnetized: bool = false
var player: CharacterBody2D = null
var collected: bool = false


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
func _physics_process(delta: float) -> void:
	if player == null or player.is_dead:
		return
	var effective_radius: float = magnet_radius * player.magnet_multiplier
	if not is_magnetized and global_position.distance_to(player.global_position) <= effective_radius:
		is_magnetized = true
	if is_magnetized:
		var direction := global_position.direction_to(player.global_position)
		global_position += direction * move_speed * delta
		
func _on_body_entered(body: Node2D) -> void:
	if collected:
		return
	if body.is_in_group("player"):
		collected = true
		if body.has_method("gain_xp"):
			body.gain_xp(xp_value)
		queue_free()
