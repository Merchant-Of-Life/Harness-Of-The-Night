extends Area2D

var xp_value = 1
var magnet_radius = 40
var move_speed = 350
var is_magnetized = false

var player = null

func _ready():
	player = get_tree().get_first_node_in_group("player")
	
func _physics_process(delta):
	if player == null or player.is_dead:
		return
		
	var distance = global_position.distance_to(player.global_position)
	if distance <= magnet_radius:
		is_magnetized = true
		
	if is_magnetized:
		var direction = global_position.direction_to(player.global_position)
		global_position += direction * move_speed * delta
		
func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("gain_xp"):
			body.gain_xp(xp_value)
		queue_free()
