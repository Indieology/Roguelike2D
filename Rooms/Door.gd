extends StaticBody2D

onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
onready var door_sound: AudioStreamPlayer = get_node("DoorSound")


func open() -> void:
	animation_player.play("open")


func make_sound() -> void:
	door_sound.play(.07)
