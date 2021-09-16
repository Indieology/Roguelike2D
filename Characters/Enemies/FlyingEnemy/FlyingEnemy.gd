extends Enemy

onready var hitbox: Area2D = $Hitbox
onready var hurt_sound: AudioStreamPlayer = $HurtSound

func _process(_delta: float) -> void:
	hitbox.knockback_direction = velocity.normalized()

func play_hurt_sound() -> void:
	hurt_sound.play(.04)
	
