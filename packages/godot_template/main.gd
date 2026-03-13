extends Node

func _ready():
	if OS.get_environment("DEBUG") == "1":
		print("test ... ok")
	else:
		print("Hello World")
	get_tree().quit()
