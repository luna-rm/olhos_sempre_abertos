extends Control

const LINE_SIZE = 21 

var rng = RandomNumberGenerator.new()
var dialogue = ClydeDialogue.new()
var select = 0
var opt = {}
var text_hour = ""
var text_main = ""
var text_next = ""
var text_choices = ""
var position_base
var can_choose = 0
var file_text = ""
var eyes = 0

var cont_end667 = 0
var cave = 0

const EYE = preload("res://eye.tscn")

@onready var hour: RichTextLabel = $Hour
@onready var main_text: RichTextLabel = $MainText
@onready var next: RichTextLabel = $Next
@onready var choices: RichTextLabel = $Choices
@onready var selector: RichTextLabel = $Selector
@onready var eye: Sprite2D = $Eye
@onready var window: Window = $"../../Window"
@onready var text_edit: TextEdit = $"../../Window/CanvasLayer/Control/TextEdit"
@onready var timer: Timer = $Timer

func _on_timer_timeout() -> void:
	if eyes:
		appear_eyes(eyes)

func appear_eyes(how):
	var eye_inst = EYE.instantiate()
	eye_inst.position = Vector2(rng.randf_range(-100, 150), rng.randf_range(700, 900))
	eye_inst.rotation = rng.randf_range(-25.0, 25.0)
	var r = randf_range(0.4, 1.2)
	eye_inst.scale = Vector2(r, r)
	add_child(eye_inst)
		
	var eye_inst2 = EYE.instantiate()
	eye_inst2.position  = Vector2(rng.randf_range(952, 1252), rng.randf_range(700, 900))
	eye_inst2.rotation = rng.randf_range(-25.0, 25.0)
	r = randf_range(0.4, 1.2)
	eye_inst2.scale = Vector2(r, r)
	add_child(eye_inst2)
		
	#if how == 0:
		#for i in range(how_many):
			#var eye = EYE_WINDOW.instantiate()
			#eye.global_position = Vector2(rng.randf_range(-125.0, 1102), rng.randf_range(-50.0, 600.0))
			#eye.global_rotation = rng.randf_range(-360.0, 360.0)
			#var r = randf_range(1.0, 2.0)
			#eye.scale = Vector2(r, r)
			#add_child(eye)
	#elif how == 1:
		#for i in range(how_many):
		#	for x in range(-250, 1102, 100):
		#		var eye = EYE_WINDOW.instantiate()
		#		var y = -((x-401)**2)/500 + 523
		#		eye.global_position = Vector2(x, y)
		#		add_child(eye)
		#		var eye2 = EYE_WINDOW.instantiate()
		#		var y2 = y + 150
		#		eye2.global_position = Vector2(x, y)
		#		add_child(eye2)

			#var x = rng.randf_range(-125.0, 1102)
			#var y = rng.randf_range( -((x-401)**2)/500 + 523, 670.0)
			#eye.global_position = Vector2(x, y)
			#eye.global_rotation = rng.randf_range(-360.0, 360.0)
			#var r = randf_range(1.0, 2.0)
			#eye.scale = Vector2(r, r)
			#add_child(eye)

func clear():
	can_choose = 0
	select = 0
	opt.clear()
	position_base = hour.position
	selector.visible = false
	selector.set_position(position_base)
	text_hour = ""
	text_main = ""
	text_next = ""
	text_choices = ""
	hour.erase_text()
	main_text.erase_text()
	next.erase_text()
	choices.erase_text()
	window.visible = false
	file_text = ""
	cont_end667 = 0
	cave = 0
	eyes = 0
	
func update_select():
	var new_pos = position_base
	for i in range(select):
		new_pos[1] += LINE_SIZE
	selector.set_position(new_pos)
	main_text.play_keyboard()

func load_text():
	var content = dialogue.get_content()
	while content.type == "line" && content.speaker:
		print(content)
		if content.speaker == "eye":
			eyes = 1
			if content.text == "1":
				timer.wait_time = 3.0
			if content.text == "2":
				timer.wait_time = 2.0
		if content.speaker == "A":
			content = dialogue.get_content()
			while content.speaker == "T":
				print(content)
				file_text += content.text
				file_text += "\n"
				content = dialogue.get_content()
			text_edit.text = file_text
			window.visible = true
		if content.speaker == "H":
			text_hour += content.text
		if content.speaker == "R":
			text_main += "    "
			text_main += content.text
			text_main += "\n"
		if content.speaker == "D":
			text_next += "    "
			text_next += content.text
		if content.speaker == "F":
			text_hour += "FINAL "
			text_hour += content.text
		if content.speaker == "W":
			cont_end667 = 1
			can_choose = 1
		if content.speaker == "cave":
			cave = 1
			can_choose = 1
		if content.speaker == "E":
			can_choose = 1
			
		content = dialogue.get_content()
	
	print(content)
	await hour.type(text_hour)
	
	for i in range(hour.get_line_count() + 2):
		position_base[1] += LINE_SIZE
	main_text.set_position(position_base)
	await main_text.type(text_main)
	
	for i in range(main_text.get_line_count() + 2):
		position_base[1] += LINE_SIZE
	next.set_position(position_base)
	await next.type(text_next)

	for i in range(next.get_line_count() + 1):
		position_base[1] += LINE_SIZE
	choices.set_position(position_base)
	selector.set_position(position_base)
	
	if content.type == "options":
		for option in content.options:
			opt[opt.size()] = [option.label]
			text_choices += "    "
			text_choices += option.label
			text_choices += "\n"
		selector.visible = true
		await choices.type(text_choices)
		can_choose = 1

func _on_text_edit_text_changed() -> void:
	text_edit.text = file_text

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clear()
	rng.randomize()
	dialogue.load_dialogue("res://dialog/comp.clyde")
	dialogue.start()
	selector.visible = false
	position_base = hour.position
	load_text()
	#https://github.com/viniciusgerevini/godot-clyde-dialogue/blob/godot_4/USAGE.md

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_choose:
		if Input.is_action_just_pressed("continue"):
			if text_choices != "":
				dialogue.choose(select)
			var content = dialogue.get_content()
			if content.type == "end":
				if cont_end667:
					dialogue.load_dialogue("res://dialog/cont_e667.clyde")
					dialogue.start()
				elif cave:
					dialogue.load_dialogue("res://dialog/cave.clyde")
					dialogue.start()
				else:
					clear()
					eye.visible = true
					await hour.wait(1.0, 2.0)
					eye.visible = false
					dialogue.load_dialogue("res://dialog/comp.clyde")
					dialogue.start()
			clear()
			await hour.wait(0.5, 1.0)
			load_text()
	if Input.is_action_just_pressed("up"):
		if select <= 0:
			return
		select += -1
		update_select()
	if Input.is_action_just_pressed("down"):
		if select >= opt.size()-1:
			return
		select += +1
		update_select()
