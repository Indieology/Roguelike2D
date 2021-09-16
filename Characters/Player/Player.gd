extends Character

enum {UP, DOWN}

onready var weapons: Node2D = $Weapons

onready var player_hurt_sound: AudioStreamPlayer = $PlayerHurtSound
onready var hurtbox_timer: Timer = $HurtboxTimer
onready var pause_menu: Node2D = $Camera2D/CanvasLayer/PauseMenu
onready var cursor_timer: Timer = $CursorTimer

var current_weapon: Node2D

var mouse_direction: Vector2

func _ready() -> void:
	current_weapon = weapons.get_child(0)

func _process(_delta: float) -> void:
	mouse_direction = (get_global_mouse_position() - global_position).normalized()
	
	if mouse_direction.x > 0 and animated_sprite.flip_h:
		animated_sprite.flip_h = false
	elif mouse_direction.x < 0 and not animated_sprite.flip_h:
		animated_sprite.flip_h = true
	
	
	current_weapon.move(mouse_direction)
	

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
	
	if not current_weapon.is_busy():
		if Input.is_action_just_released("previous_weapon"):
			_switch_weapon(UP)
		elif Input.is_action_just_released("next_weapon"):
			_switch_weapon(DOWN)
			
		elif Input.is_action_just_pressed("throw_weapon") and current_weapon.get_index() != 0:
			_drop_weapon()
		
	current_weapon.get_input()
		
	if Input.is_action_pressed("pause_menu"):
		pause_menu.set_visible(true)
		get_parent().get_tree().paused = true
	
func pick_up_weapon(weapon: Node2D) -> void:
	weapon.get_parent().call_deferred("remove_child", weapon)
	weapons.call_deferred("add_child", weapon)
	weapon.set_deferred("owner", weapons)
	current_weapon.hide()
	current_weapon.cancel_attack()
	current_weapon = weapon
	
func _switch_weapon(direction: int) -> void:
	var index: int = current_weapon.get_index()
	if direction == UP:
		index -= 1
		if index < 0:
			index = weapons.get_child_count() - 1
	else:
		index += 1
		if index > weapons.get_child_count() - 1:
			index = 0
	current_weapon.hide()
	current_weapon = weapons.get_child(index)
	current_weapon.show()
	
func _drop_weapon() -> void:
	var weapon_to_drop: Node2D = current_weapon
	_switch_weapon(UP)
	weapons.call_deferred("remove_child", weapon_to_drop)
	get_parent().call_deferred("add_child", weapon_to_drop)
	weapon_to_drop.set_owner(get_parent())
	yield(weapon_to_drop.tween, "tree_entered")
	weapon_to_drop.show()
	
	var throw_dir: Vector2 = (get_global_mouse_position() - position).normalized()
	weapon_to_drop.interpolate_pos(position, position + throw_dir * 50)
	
func cancel_attack() -> void:
	current_weapon.cancel_attack()

func switch_camera() -> void:
	var main_scene_camera: Camera2D = get_parent().get_node("DeathCamera2D")
	main_scene_camera.position = position
	main_scene_camera.current = true
	get_node("Camera2D").current = false
	
func play_hurt_sound() -> void:
		player_hurt_sound.play(.13)

func disable_player_hurtbox() -> void:
	set_collision_layer_bit(4, false)
	hurtbox_timer.start()
	yield(hurtbox_timer,"timeout")
	set_collision_layer_bit(4, true)
	

func shake():
	var intensity = 20 / 5.0
	var duration = 15 / 200.0
	var type = 1 #  0 for random 1 for sine
	
	Shake.shake(intensity, duration, type)


func _on_Resume_pressed():
	pause_menu.set_visible(false)
	get_parent().get_tree().paused = false

func _on_NewDungeon_pressed():
	get_parent().get_tree().paused = false
	get_parent().get_tree().reload_current_scene()

func _on_Exit_pressed():
	get_parent().get_tree().paused = false
	get_parent().get_tree().quit()
