tool
extends Node

func _ready():
	var projectFile = File.new()
	projectFile.open("res://project.godot", projectFile.READ_WRITE)

	var rawText = projectFile.get_as_text()
	
	var gogodotAutoload = 'go="*res://addons/GoGodot/go.gd"'
	if rawText.find(gogodotAutoload) == -1:
		var autoloadPos = rawText.find("[autoload]")
		
		if autoloadPos == -1:
			rawText += "\n[autoload]\n\n" + gogodotAutoload + "\n"
		else:
			rawText = rawText.insert(autoloadPos + 12, gogodotAutoload + "\n")
		
		projectFile.store_string(rawText)

#	while !projectFile.eof_reached():
#		var nextLine = projectFile.get_line()
#
#		if nextLine == "[autoload]":
#			print("autoload reached")
#			#projectFile.get_line() #skip empty line
#			var filePosition = projectFile.get_position()
#			projectFile.close()
#
#			projectFile.open("res://projectz.godot", projectFile.READ_WRITE)
#			projectFile.seek(filePosition)
#			projectFile.store_line("")
#			projectFile.store_line("testing it out")
#			print("got here")
#			break
#
#		print(nextLine)
		
		
	projectFile.close()
	
	pass

