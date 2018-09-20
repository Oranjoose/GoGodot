extends Node

var Main

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	Main = get_tree().root.get_children()[get_tree().root.get_children().size()-1]
	
	#set up the gogodot custom signals
	_attach_all_signals()
	
#	for nodeWithTimer in get_all_nodes_with_function("go_interval"):
#		pass
	
	get_tree().connect("node_added", self, "_node_added_to_scene_tree")
	
	pass
	
func _attach_all_signals():
	#attach the go_collision callback to every area 2d node at the beginning of the game
	for area in get_all_nodes_by_class("Area2D"):
		#_attach_collision_to_area2d(area)
		_attach_signal_to_ancestor_callback(area, "area_entered", "go_collision")
		
	for spritesheet in get_all_nodes_with_signal("on_animation_end"):
		_attach_signal_to_ancestor_callback(spritesheet, "on_animation_end", "go_animation_end")

func _process(delta):

	pass
	
func get_all_nodes_by_class(className):
	return _get_nodes_by_class_within_node(className, get_tree().root)
	
func _get_nodes_by_class_within_node(className, nodeToCheck):
	var nodesOfClass = []
	var children = nodeToCheck.get_children()

	if nodeToCheck.get_class().to_lower() == className.to_lower():
		nodesOfClass.append(nodeToCheck)
	
	if children.empty():
		return nodesOfClass
	
	for child in children:
		nodesOfClass += _get_nodes_by_class_within_node(className, child) #combine lists
		
	return nodesOfClass
	
func get_all_nodes_with_function(funcName):
	return _get_nodes_with_function_within_node(funcName, get_tree().root)
	
func _get_nodes_with_function_within_node(funcName, nodeToCheck):
	var nodesWithFunction = []
	var children = nodeToCheck.get_children()
	
	if nodeToCheck.has_method(funcName):
		nodesWithFunction.append(nodeToCheck)
	
	if children.empty():
		return nodesWithFunction
	
	for child in children:
		nodesWithFunction += _get_nodes_with_function_within_node(funcName, child) #combine lists
		
	return nodesWithFunction
	
func get_all_nodes_with_signal(signalName):
	return _get_nodes_with_signal_within_node(signalName, get_tree().root)
	
func _get_nodes_with_signal_within_node(signalName, nodeToCheck):
	var nodesWithSignal = []
	var children = nodeToCheck.get_children()
	
	if nodeToCheck.get_script() and nodeToCheck.get_script().has_script_signal(signalName):
		nodesWithSignal.append(nodeToCheck)
	
	if children.empty():
		return nodesWithSignal
	
	for child in children:
		nodesWithSignal += _get_nodes_with_signal_within_node(signalName, child) #combine lists
		
	return nodesWithSignal
	
	
func restart_scene():
	get_tree().reload_current_scene()
	
func spawn_instance(sceneName, xOrObject = 0, y = 0, parent=Main):
	
	var scenePath = _find_file(sceneName)
	if scenePath:
		var instance = load(scenePath).instance()
		
		if "position" in instance:
			instance.position = Vector2(xOrObject, y)
		elif "rect_position" in instance:
			instance.rect_position = Vector2(xOrObject, y)
			
		Main.add_child(instance)
		
#		#this is now handled by the node_added signal attached to the scene tree, so as to catch new Area2D nodes
#			#created by traditional methods of adding new instances without go.spawn_instance 
#		for area in _get_nodes_by_class_within_node("Area2D", instance):
#			_attach_collision_to_area2d(area)
		
		return instance
	else:
		return null
	
	pass 

func destroy (objectToDestroy):
	if objectToDestroy.has_method("queue_free"):
		objectToDestroy.queue_free()
	else:
		print (objectToDestroy, " cannot be removed this way")

#return file path to file if found, and -1 if not
func _find_file(fileName, dirPath = "res://", extension = "tscn"): #if path not provided, assume this is the first call in the root
	
	var files = []
	var dir = Directory.new()
	dir.change_dir(dirPath)
	dir.list_dir_begin()
	
	var file = dir.get_next()
	
	while file != "":
		if not file.begins_with(".") and dir.current_is_dir():
			
			var dirResult = _find_file(fileName, dir.get_current_dir() + "/" + file)
			
			#pass back the correct answer if was found in this directory
			if dirResult: #i.e. not null
				return dirResult
		#elif file.ends_with(".tscn") and file.begins_with(fileName) and file.length == (fileName.length + 5):
		elif file.to_lower() == fileName.to_lower() + ("." + extension if fileName.find("." + extension) == -1 else ""):
			return dir.get_current_dir() + file
			
		file = dir.get_next()
		
	dir.list_dir_end()
	
	return null

func _attach_signal_to_ancestor_callback(nodeWithSignal, signalName, callbackName):
	var nodeToAddCallback = _get_closest_node_in_ancestry_with_callback(nodeWithSignal, callbackName)
	
	if nodeToAddCallback and nodeToAddCallback.has_method(callbackName):
		
		nodeWithSignal.connect(signalName, nodeToAddCallback, callbackName)
	else:
		nodeWithSignal.connect(signalName, self, "_short_circuit")

#attach a collision signal callback to area2d if it has a script, and if not, to its nearest parent with a script
#this is to make collisions more simple for beginners, as all they have to do is type the go_collision function and it
	#automatically works
#this function has been mostly deprecated by the more generalized _attach_signal_to_ancestor_callback
func _attach_collision_to_area2d(area):
	var nodeToAddCallback = _get_closest_node_in_ancestry_with_script(area)
	
	if nodeToAddCallback and nodeToAddCallback.has_method("go_collision"):
		area.connect("area_entered", nodeToAddCallback, "go_collision")
	else:
		area.connect("area_entered", self, "_collision_fallback")
	
func _get_closest_node_in_ancestry_with_script (nodeToCheck):
	if nodeToCheck.get_script():
		return nodeToCheck
	
	var parentToCheck = nodeToCheck.get_parent()
	while parentToCheck:
		if parentToCheck.get_script():
			return parentToCheck
		
		parentToCheck = parentToCheck.get_parent()

	return null 
	
func _get_closest_node_in_ancestry_with_callback (nodeToCheck, callbackName):
	if nodeToCheck.has_method(callbackName):
		return nodeToCheck
	
	var parentToCheck = nodeToCheck.get_parent()
	while parentToCheck:
		if parentToCheck.has_method(callbackName):
			return parentToCheck
		
		parentToCheck = parentToCheck.get_parent()

	return null 
	
#short circuit function if no ancestor node with callback function was found
#this is mostly to avoid the non-terminating error that occurs when the signal is fired but no function to receive.
func _short_circuit(arg1 = null):
	#print ("no ancestor found with the callback function")
	pass
	
func _node_added_to_scene_tree(addedNode):
	#when scene is "reloaded", the Main scene is removed and readded
	#so need to reset value for Main variable
	if addedNode == get_tree().root.get_children()[get_tree().root.get_children().size()-1]:
		Main = addedNode
	
	if addedNode.get_class().to_lower() == "area2d":
		#_attach_collision_to_area2d(addedNode)
		_attach_signal_to_ancestor_callback(addedNode, "area_entered", "go_collision")
		
	if addedNode.get_script() and addedNode.get_script().has_script_signal("on_animation_end"):
		_attach_signal_to_ancestor_callback(addedNode, "on_animation_end", "go_animation_end")
