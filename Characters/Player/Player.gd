extends Character

onready var sword: Node2D = get_node("Sword")
onready var sword_hitbox: Area2D = get_node("Sword/Node2D/Sprite/Hitbox")
onready var sword_animation_player: AnimationPlayer = get_node("Sword/SwordAnimationPlayer")
onready var charge_particles: Particles2D = get_node("Sword/Node2D/Sprite/ChargeParticles")
onready var sword_sound: AudioStreamPlayer = get_node("SwordSound")
onready var player_hurt_sound: AudioStreamPlayer = get_node("PlayerHurtSound")
onready var hurtbox_timer: Timer = get_node("HurtboxTimer")
onready var pause_menu: Node2D = get_node("Camera2D/CanvasLayer/PauseMenu")


func _process(_delta: float) -> void:
	var mouse_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
	
	if mouse_direction.x > 0 and animated_sprite.flip_h:
		animated_sprite.flip_h = false
	elif mouse_direction.x < 0 and not animated_sprite.flip_h:
		animated_sprite.flip_h = true
	
	
	sword.rotation = mouse_direction.angle()
	sword_hitbox.knockback_direction = mouse_direction
	if sword.scale.y == 1 and mouse_direction.x < 0:
		sword.scale.y = -1
	elif sword.scale.y == -1 and mouse_direction.x > 0:
		sword.scale.y = 1
	

func get_input() -> void:
	move_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_down"):
		move_direction += Vector2.DOWN
	if Input.is_action_pressed("ui_left"):
		move_direction += Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		move_direction += Vector2.RIGHT
	if Input.is_action_pressed("ui_up"):
		move_direction += Vector2.UP
	
	if Input.is_action_just_pressed("ui_attack") and not sword_animation_player.is_playing():
		sword_animation_player.play("charge")
		
	elif Input.is_action_just_released("ui_attack"):
		if sword_animation_player.is_playing() and sword_animation_player.current_animation == "charge":
			sword_animation_player.play("attack")
		elif charge_particles.emitting:
			sword_animation_player.play("circular_attack")
		
	if Input.is_action_pressed("pause_menu"):
		pause_menu.set_visible(true)
		get_parent().get_tree().paused = true
	
func cancel_attack() -> void:
	sword_animation_player.play("cancel_attack")

func switch_camera() -> void:
	var main_scene_camera: Camera2D = get_parent().get_node("Camera2D") 
	main_scene_camera.position = position
	main_scene_camera.current = true
	get_node("Camera2D").current = false
	
func play_sword_sound() -> void:
	sword_sound.play()
	
func play_hurt_sound() -> void:
		player_hurt_sound.play(.13)

func disable_player_hurtbox() -> void:
	set_collision_layer_bit(4, false)
	hurtbox_timer.start()
	yield(hurtbox_timer,"timeout")
	set_collision_layer_bit(4, true)
	

func _on_Resume_pressed():
	pause_menu.set_visible(false)
	get_parent().get_tree().paused = false

func _on_NewDungeon_pressed():
	get_parent().get_tree().paused = false
	get_parent().get_tree().reload_current_scene()

func _on_Exit_pressed():
	get_parent().get_tree().paused = false
	get_parent().get_tree().quit()
