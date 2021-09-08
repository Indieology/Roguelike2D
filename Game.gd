extends Node2D

onready var BackgroundMusic: AudioStreamPlayer = get_node("BackgroundMusic")



func _init() -> void:
	randomize()
	var screen_size: Vector2 = OS.get_screen_size()
	var window_size: Vector2 = OS.get_window_size()
	
	OS.set_window_position(screen_size * 0.5 - window_size * .5)
	

func _ready() -> void:
	BackgroundMusic.play()
	


func _on_Button_pressed():
	get_tree().reload_current_scene()


func _on_Quit_pressed():
	get_tree().quit()
