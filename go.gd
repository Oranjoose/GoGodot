extends Node

var Main

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	Main = get_tree().root.get_children()[get_tree().root.get_children().size()-1]
	
	#attach the go_collision callback to every area 2d node at the beginning of the game
	for area in get_all_nodes_by_class("Area2D"):
		_attach_collision_to_area2d(area)
	
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
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
	
func restart_scene():
	get_tree().reload_current_scene()
	
func spawn_instance(sceneName, xOrObject = 0, y = 0, parent=Main):
	
	var scenePath = _find_scene_file(sceneName)
	if scenePath:
		var instance = load(scenePath).instance()
		
		if "position" in instance:
			instance.position = Vector2(xOrObject, y)
		elif "rect_position" in instance:
			instance.rect_position = Vector2(xOrObject, y)
			
		Main.add_child(instance)
		
		#if there are any area 2D nodes within this new instance, then attach the go_collision signal to it 
		for area in _get_nodes_by_class_within_node("Area2D", instance):
			_attach_collision_to_area2d(area)
		
		return instance
	else:
		return null
	
	pass 
	
#return file path to file if found, and -1 if not
func _find_scene_file(fileName, dirPath = "res://"): #if path not provided, assume this is the first call in the root
	
	var files = []
	var dir = Directory.new()
	dir.change_dir(dirPath)
	dir.list_dir_begin()
	
	var file = dir.get_next()
	
	while file != "":
		if not file.begins_with(".") and dir.current_is_dir():
			
			var dirResult = _find_scene_file(fileName, dir.get_current_dir() + "/" + file)
			
			#pass back the correct answer if was found in this directory
			if dirResult: #i.e. not null
				return dirResult
		#elif file.ends_with(".tscn") and file.begins_with(fileName) and file.length == (fileName.length + 5):
		elif file.to_lower() == fileName.to_lower() + ".tscn":
			return dir.get_current_dir() + "/" + file
			
		file = dir.get_next()
		
	dir.list_dir_end()
	
	return null

#attach a collision signal callback to area2d if it has a script, and if not, to its nearest parent with a script
#this is to make collisions more simple for beginners, as all they have to do is type the go_collision function and it
	#automatically works
func _attach_collision_to_area2d(area):
	var nodeToAddCallback = _get_closest_node_in_ancestry_with_script(area)
	
	if nodeToAddCallback: #not null
		area.connect("area_entered", nodeToAddCallback, "go_collision")
	
func _get_closest_node_in_ancestry_with_script (nodeToCheck):
	if nodeToCheck.get_script():
		return nodeToCheck
	
	var parentToCheck = nodeToCheck.get_parent()
	while parentToCheck:
		if parentToCheck.get_script():
			return parentToCheck
		
		parentToCheck = parentToCheck.get_parent()

	return null 
