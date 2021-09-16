extends Node2D
class_name Weapon

export(bool) var on_floor: bool = false

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var charge_particles: Particles2D = $Node2D/Sprite/ChargeParticles
onready var hitbox: Area2D = $Node2D/Sprite/Hitbox

onready var cursor_timer: Timer = $CursorTimer
onready var sound: AudioStreamPlayer = $Sound

onready var player_detector: Area2D = $PlayerDetector
onready var tween: Tween = $Tween

var mouse_direction: Vector2

func _ready() -> void:
	if not on_floor:
		player_detector.set_collision_mask_bit(0, false)
		player_detector.set_collision_mask_bit(1, false)
	

func _process(delta):
	mouse_direction = (get_global_mouse_position() - global_position).normalized()

func get_input() -> void:
	if Input.is_action_just_pressed("ui_attack") and not animation_player.is_playing():
		animation_player.play("charge")
		
		
	elif Input.is_action_just_released("ui_attack"):
		if animation_player.is_playing() and animation_player.current_animation == "charge":
			animation_player.play("attack")
		elif charge_particles.emitting:
			animation_player.play("strong_attack")
		elif not animation_player.current_animation == "strong_attack":
			animation_player.play("attack")
			

func move(mouse_direction: Vector2) -> void:
	if not animation_player.is_playing() or animation_player.current_animation == "charge":
		rotation = mouse_direction.angle()
		hitbox.knockback_direction = mouse_direction
		if scale.y == 1 and mouse_direction.x < 0:
			scale.y = -1
		elif scale.y == -1 and mouse_direction.x > 0:
			scale.y = 1
	
func cancel_attack() -> void:
	animation_player.play("cancel_attack")
	
func is_busy() -> bool: 
	if animation_player.is_playing() or charge_particles.emitting:
		return true
	return false

func play_sound() -> void:
	sound.play()

func simple_cursor_movement() -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var movement_amount: Vector2 = Vector2(mouse_pos.x + (mouse_direction.x * 1.5) , mouse_pos.y + (mouse_direction.y * 1.5))
	get_viewport().warp_mouse(movement_amount)
	
	cursor_timer.start()
	yield(cursor_timer, "timeout")
	
	get_viewport().warp_mouse(mouse_pos)

func shake():
	var intensity = 20 / 5.0
	var duration = 15 / 200.0
	var type = 1 #  0 for random 1 for sine
	
	Shake.shake(intensity, duration, type)

func _on_PlayerDetector_body_entered(body: KinematicBody2D) -> void:
	if body != null:
		player_detector.set_collision_mask_bit(0, false)
		player_detector.set_collision_mask_bit(1, false)
		body.pick_up_weapon(self)
		position = Vector2.ZERO
	else:
		var __ = tween.stop_all()
		assert(__)
		player_detector.set_collision_mask_bit(1, true)

func interpolate_pos(initial_pos: Vector2, final_pos: Vector2) -> void:
	var __ = tween.interpolate_property(self, "position", initial_pos, final_pos, 0.8, Tween.TRANS_QUART, Tween.EASE_OUT)
	assert(__)
	__ = tween.start()
	assert(__)
	player_detector.set_collision_mask_bit(0, true)

func _on_Tween_tween_completed(object: Object, _key: NodePath) -> void:
	player_detector.set_collision_mask_bit(1, true)
