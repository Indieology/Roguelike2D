extends Node

var camera_shake_intensity = 0.0
var camera_shake_duration = 0.0

enum Type {Random, Sine}
var camera_shake_type = Type.Random

func _ready():
	
	return

func shake(intensity, duration, type = Type.Random):
	# Set the shake parameters
	# A good idea here is to add configuration settings that
	# allow the player to turn off shake
	# if player_no_want:
	# 	intensity = 0
	
	if intensity > camera_shake_intensity and duration > camera_shake_duration:
		camera_shake_intensity = intensity
		camera_shake_duration = duration
		camera_shake_type = type

func _process(delta):
	# Get the camera
	# You'll need to adjust this depending on how you want to
	# keep track of the active camera in your game
	# Maybe your game has two cameras, maybe it has 10, who knows?
	# Do what you like
	var camera = get_tree().current_scene.get_node("DeathCamera2D")
	var is_player: = is_instance_valid(get_tree().current_scene.get_node("Player"))
	if is_player:
		 camera = get_tree().current_scene.get_node("Player").get_node("Camera2D")
	
	
	
	# Stop shaking if the camera_shake_duration timer is down to zero
	if camera_shake_duration <= 0:
		# Reset the camera when the shaking is done
		camera.offset = Vector2.ZERO
		camera_shake_intensity = 0.0
		camera_shake_duration = 0.0
		return
	
	# Subtract the elapsed time from the camera_shake_duration
	# so that it eventually ends
	# You can do other fun stuff here too like have the intensity
	# decay gradually so that the shake tapers off
	camera_shake_duration = camera_shake_duration - delta
	
	# Shake it
	var offset = Vector2.ZERO
		
	if camera_shake_type == Type.Random:
		# Random shake
		# Chaos
		# Madness
		#
		# Personally, I like this best because players don't notice
		# any difference in the thick of battle when the shakes are short
		# and because it's dead simple.
		offset = Vector2(randf(), randf()) * camera_shake_intensity

	if camera_shake_type == Type.Sine:
		# Sine wave based shake
		# Play around with the magic numbers to adjust the feel
		# Basing the sine wave off of get_ticks_msec ensures that
		# the returned value is continuous and smooth
		offset = Vector2(sin(OS.get_ticks_msec() * 0.03), sin(OS.get_ticks_msec() * 0.07)) * camera_shake_intensity * 0.5
		
	camera.offset = offset
