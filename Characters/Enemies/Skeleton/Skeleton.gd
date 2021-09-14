extends Enemy

const THROWABLE_KNIFE_SCENE: PackedScene = preload("res://Characters/Enemies/Skeleton/Throwable.tscn")

const MAX_DISTANCE_TO_PLAYER: int = 90
const MIN_DISTANCE_TO_PLAYER: int = 45

export(int) var projectile_speed: int = 120

var can_attack: bool = true

var distance_to_player: float

onready var attack_timer: Timer = get_node("AttackTimer")
onready var aim_raycast: RayCast2D = get_node("AimRayCast")
onready var hurt_sound: AudioStreamPlayer = get_node("HurtSound")
onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

func _on_PathTimer_timeout() -> void:
	if is_instance_valid(player):
		distance_to_player = (player.position - global_position).length()
		if distance_to_player > MAX_DISTANCE_TO_PLAYER:
			_get_path_to_player()
		elif distance_to_player < MIN_DISTANCE_TO_PLAYER:
			_get_path_to_move_away_from_player()
		else:
			aim_raycast.cast_to = player.position - global_position
			if can_attack and state_machine.state == state_machine.states.idle and not aim_raycast.is_colliding():
				can_attack = false
				_throw_knife()
				attack_timer.start()
	else:
		path_timer.stop()
		path = []
		move_direction = Vector2.DOWN
			
			
func _get_path_to_move_away_from_player() -> void:
	var dir: Vector2 = (global_position  - player.position).normalized()
	path = navigation.get_simple_path(global_position, global_position + dir * 100)

func _throw_knife() -> void:
	if !player:
		return
	animation_player.play("Throw")
	yield(animation_player, "animation_finished")
	var projectile: Area2D = THROWABLE_KNIFE_SCENE.instance()
	projectile.launch(global_position, (player.position - global_position).normalized(), projectile_speed)
	get_tree().current_scene.add_child(projectile)

func _on_AttackTimer_timeout() -> void:
	can_attack = true

func play_hurt_sound() -> void:
	hurt_sound.play(0.09)
