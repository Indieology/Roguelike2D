extends KinematicBody2D
class_name Character #, "res://Art/heroes/knight/knight_idle_anim_f0.png"

const FRICTION: float = 0.15

export(int) var acceleration: int = 40
export(int) var max_speed: int = 100

export(bool) var flying: bool = false

export(int) var hp: int = 2 setget set_hp
signal hp_changed()

onready var state_machine: Node = get_node("FiniteStateMachine")
onready var animated_sprite: AnimatedSprite = get_node("AnimatedSprite")

var move_direction: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO


func _physics_process(_delta: float) -> void:
	velocity = move_and_slide(velocity)
	velocity = lerp(velocity, Vector2.ZERO, FRICTION)


func move() -> void:
	move_direction = move_direction.normalized()
	velocity += move_direction * acceleration
	velocity = velocity.clamped(max_speed)
	

func take_damage(damage: int, direction: Vector2, force: int) -> void:
	if state_machine.state != state_machine.states.hurt and state_machine.state != state_machine.states.dead:
		self.hp -= damage
		if hp > 0:
			state_machine.set_state(state_machine.states.hurt)
			velocity += direction * force
		else:
			state_machine.set_state(state_machine.states.dead)
			velocity += direction * force
	
func set_hp(new_hp: int) -> void:
	hp = new_hp
	emit_signal("hp_changed", new_hp)
