tool
extends KinematicBody2D

const UP = Vector2(0, -1)
export var Gravity = 20
export var Speed = 200
export var JumpStrength = 500

export (Vector2) var CollisionBounds = Vector2(10, 10) setget _set_collision_bounds
export (bool) var Set_Bounds_To_Sibling_Sprite = false setget _set_bounds_to_sibling_sprite

export (bool) var WASD = false
export (bool) var ArrowKeys = true

var motion = Vector2(0, 0)

func _set_collision_bounds(value):
	CollisionBounds = value

	#this function runs before the collisionshape exists for some reason
#	if not get_shape_owners().empty():
#		shape_owner_clear_shapes(get_shape_owners()[0])
#		var rectshape = RectangleShape2D.new()
#		rectshape.extents = value
#
#		shape_owner_add_shape(get_shape_owners()[0], rectshape)
	
	#scale works, but maybe extents is better
	#but extents appears to have a bug, where changing extents in one instance, changes it in the editor for the first
		#instance of the Platformer module
	self.scale = value
	
#	if self.get_child_count() > 0: #to prevent pesky "CollisionShape2D not found" error upon each save, and crash when game starts 
#		$CollisionShape2D.shape.extents = CollisionBounds
	#update()
	
func _set_bounds_to_sibling_sprite(value):
	#Set_Bounds_To_Sibling_Sprite = value
	var siblingSprite
	if value:
#		var parent = 
		if get_parent():
			for child in get_parent().get_children():
				if child is Sprite:
					siblingSprite = child
					break
		
		if siblingSprite:
			_set_collision_bounds(siblingSprite.texture.get_size() * siblingSprite.scale)
		elif get_parent(): #to prevent the print from happening each time the module is saved (since no parent)
			print("no sibling sprites")
		
	
#func _draw():
#	var rect = Rect2(0, 0, 200, 300)
#
#	draw_rect(rect, Color(randf(), randf(), randf()))

func _ready():
	#necessary to have child move the parent without perpetually throwing off the child in turn
	if not Engine.editor_hint:
		#necessary to have child move the parent without perpetually throwing off the child in turn
		set_as_toplevel(true)
		
		#start at location where parent node was placed within level editor, then
			#proceed to have parent follow child (KinematicBody2D) for position
		self.global_position = get_parent().global_position
	
	_set_collision_bounds(CollisionBounds)
	pass

func _physics_process(delta):
	if not Engine.editor_hint:
		#first set to the parent's position, in case the parent was teleported, etc.
			#in the last frame
		self.global_position = get_parent().global_position
		
		motion.y += Gravity
	
		if (ArrowKeys and Input.is_key_pressed(KEY_RIGHT)) or (WASD and Input.is_key_pressed(KEY_D)):
			motion.x = Speed
		elif (ArrowKeys and Input.is_key_pressed(KEY_LEFT)) or (WASD and Input.is_key_pressed(KEY_A)):
			motion.x = -Speed
		else:
			motion.x = 0
			
		if self.is_on_floor():
			if (ArrowKeys and Input.is_key_pressed(KEY_UP)) or (WASD and Input.is_key_pressed(KEY_W)):
				motion.y = -JumpStrength
				
		motion = move_and_slide(motion, UP)
		
		get_parent().global_position = self.global_position
	
	