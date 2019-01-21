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
	var allNodes = get_all_nodes()
	
	for node in allNodes:
		_node_added_to_scene_tree(node)
	#attach the go_collision callback to every area 2d node at the beginning of the game
#	for area in get_all_nodes_by_class("Area2D"):
#		_attach_signal_to_ancestor_callback(area, "area_entered", "go_collision")
#		_attach_signal_to_ancestor_callback(area, "body_entered", "go_body_collision")
#
#	for body in get_all_nodes_by_class("RigidBody2D"):
#		var nodeWithCallback = _attach_signal_to_ancestor_callback(body, "body_entered", "go_body_collision")
#		if nodeWithCallback:
#			body.contact_monitor = true
#			if body.contacts_reported == 0:
#				body.contacts_reported = 2
#
#	for spritesheet in get_all_nodes_with_signal("on_animation_end"):
#		_attach_signal_to_ancestor_callback(spritesheet, "on_animation_end", "go_animation_end")

func _process(delta):

	pass
	
func get_all_nodes():
	return _get_descendants_within_node(get_tree().root)
	
func _get_descendants_within_node(node):
	var nodes = [node]
	var children = node.get_children()
	
	if children.empty():
		return nodes
	
	for child in children:
		nodes += _get_descendants_within_node(child)
	
	return nodes
		
	
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
			
		parent.add_child(instance)

		
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
			var curdir = dir.get_current_dir()
			var isRoot = curdir.substr(curdir.length() - 1, 1) == "/"
			return curdir + ("" if isRoot else "/") + file
			
		file = dir.get_next()
		
	dir.list_dir_end()
	
	return null

func _attach_signal_to_ancestor_callback(nodeWithSignal, signalName, callbackName):
	var nodeToAddCallback = _get_closest_node_in_ancestry_with_callback(nodeWithSignal, callbackName)
	
	if nodeToAddCallback and nodeToAddCallback.has_method(callbackName):
		
		nodeWithSignal.connect(signalName, nodeToAddCallback, callbackName)
		return nodeToAddCallback #in case caller wants to do anything with this
#	else:
#		nodeWithSignal.connect(signalName, self, "_short_circuit")
#		return null
	
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
	
#might deprecate this function in next update (1-21-2019)
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
		
	#if a rigid body wants to call body_entered, then automatically enable its contact monitoring, which for some reason is off by default
	if addedNode.get_class().to_lower() == "rigidbody2d":
		var nodeWithCallback = _attach_signal_to_ancestor_callback(addedNode, "body_entered", "body_entered")
		if nodeWithCallback:
			addedNode.contact_monitor = true
			if addedNode.contacts_reported == 0:
				addedNode.contacts_reported = 2
	
	var signallist = addedNode.get_signal_list()
	for sig in signallist:
		_attach_signal_to_ancestor_callback(addedNode, sig.name, sig.name)
	
#	if addedNode.get_class().to_lower() == "area2d":
#		_attach_signal_to_ancestor_callback(addedNode, "area_entered", "go_collision")
#		_attach_signal_to_ancestor_callback(addedNode, "body_entered", "go_body_collision")
#
#	
#
#	if addedNode.get_script() and addedNode.get_script().has_script_signal("on_animation_end"):
#		_attach_signal_to_ancestor_callback(addedNode, "on_animation_end", "go_animation_end")
		

func random_integer(minimum = null, maximum = null) -> int:
	
	if minimum != null and maximum != null:
		assert(minimum <= maximum)
		return int(floor(rand_range(minimum, maximum + 1))) #have to floor before int cast, because floor floors negative numbers, and int cast just truncates them
	#if there is only one argument, get 1 to provided argument
	elif minimum != null:
		return int(floor(rand_range(1, minimum + 1)))
	#if there are no arguments, then get a die roll 1 to 6
	else:
		return int(floor(rand_range(1, 7)))
		

func array_shuffle(arrayToShuffle:Array) -> Array:
	var shuffledArray = []
	
	while true:
		if arrayToShuffle.size() == 0:
			break
			
		var randIndex = int(rand_range(0, arrayToShuffle.size()))
		shuffledArray.append(arrayToShuffle[randIndex])
		
		arrayToShuffle.remove(randIndex)
		
	return shuffledArray
	
func spawn_instance_grid(SceneName, NumColumns, NumRows, ColumnSpacing = 32, RowSpacing = 32, xPos = 0, yPos = 0, parent = Main):
	var returnArray = []
	for i in range(NumColumns):
		for j in range(NumRows):
			returnArray.append(spawn_instance(SceneName, (i * ColumnSpacing) + xPos, (j * RowSpacing) + yPos, parent))
			
	return returnArray