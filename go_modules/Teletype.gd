#tool
extends Node

export var Autostart = true

export var TypeSpeed = 8 setget set_type_speed #characters per second

var IsTyping = false setget set_is_typing

#var currentCharacterIndex = 0
#var completeText = ""

onready var typeTimer = $Timer

signal on_finished

func set_type_speed(value):
	TypeSpeed = value
	
	if typeTimer:
		typeTimer.wait_time = 1.0 / TypeSpeed
	
func set_is_typing(value):
	if value:
		play()
	else:
		stop()
		
func play():
	IsTyping = true
	if typeTimer:
		typeTimer.start()
	
func play_from_beginning():
	#currentCharacterIndex = 0
	get_parent().visible_characters = 0
	play()
	
func pause():
	IsTyping = false
	if typeTimer:
		typeTimer.stop()
	
func stop():
	#currentCharacterIndex = completeText.length()
	get_parent().visible_characters = -1
	pause()

func _ready():
	#typeTimer = $Timer
	if Autostart:
		play()
		
	if not "visible_characters" in self.get_parent():
		print("Teletype module must be a child of a Label or RichTextLabel. Removing teletype node.")
		go.destroy(self)
	else:
		#self.completeText = self.get_parent().text
		get_parent().visible_characters = 0
		set_type_speed(TypeSpeed)
#		self.add_child(typeTimer)
#		typeTimer.connect("timeout", self, "typeTimer_timeout")
#		typeTimer.one_shot = false
		#typeTimer.autostart = Autostart
		

func _process(delta):
	#get_parent().visible_characters = completeText.substr(0, currentCharacterIndex)
		
	pass
	
func typeTimer_timeout():
	#print("timered")
	if get_parent().visible_characters > get_parent().get_total_character_count():
		pause()
		emit_signal("on_finished")
	else:
		get_parent().visible_characters += 1
