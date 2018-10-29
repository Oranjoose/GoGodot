tool
extends Sprite

#class_name Spritesheet

export (Texture) var SpritesheetTexture setget _set_texture

export var CurrentFrame = 0 setget _set_current_frame
export var Framerate = 12.0 setget _set_frame_rate
export var HorzFrames = 1 setget _set_horz_frames
export var VertFrames = 1 setget _set_vert_frames

export var FirstFrame = 0 setget _set_first_frame
export var FinalFrame = 1 setget _set_final_frame

export var Loop = true setget _set_looping
export var Reverse = false setget _set_reverse

export var IsPlaying = false setget _set_playing
export var Autostart = true setget _set_autostart

var currentTime = 0
var frameInterval = 1

signal on_animation_end

func _set_texture(value):
	SpritesheetTexture = value
	self.texture = value

func _set_current_frame(value):
	if value >= FirstFrame and value <= FinalFrame:
		CurrentFrame = value
		self.frame = value
	
func _set_frame_rate(value):
	Framerate = value
	frameInterval = 1.0/value
	
func _set_horz_frames(value):
	if value > 0:
		HorzFrames = value
		self.hframes = value
	
func _set_vert_frames(value):
	if value > 0:
		VertFrames = value
		self.vframes = value
	
func _set_first_frame(value):
	if value >= 0 and value <= FinalFrame:
		FirstFrame = value

func _set_final_frame(value):
	if value >= FirstFrame and value <= HorzFrames * VertFrames:
		FinalFrame = value
	else:
		FinalFrame = HorzFrames * VertFrames
	
func _set_looping(value):
	Loop = value
	
func _set_reverse(value):
	Reverse = value
	
func _set_playing(value):
	IsPlaying = value
	
func _set_autostart(value):
	Autostart = value
	
func play():
	_set_playing(true)
	
func stop():
	_set_playing(false)
	
	_set_current_frame(FirstFrame if not Reverse else FinalFrame)
	
func pause():
	_set_playing(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	if Autostart:
		IsPlaying = true
		
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if IsPlaying:
		currentTime += delta
		
		if currentTime > frameInterval * (CurrentFrame + 1 if not Reverse else FinalFrame - (CurrentFrame - FirstFrame)):
			if CurrentFrame == (FinalFrame if not Reverse else FirstFrame):
				_set_current_frame(FirstFrame if not Reverse else FinalFrame)
				currentTime = FirstFrame * frameInterval #reset clock
				
				#print("animanimanim")
				emit_signal("on_animation_end")
				
				if not Loop:
					_set_playing(false)
			else:
				_set_current_frame(CurrentFrame + 1 if not Reverse else CurrentFrame - 1)
			
	
	
	pass
