extends RichTextLabel

@onready var this: RichTextLabel = $"."
@onready var audio_stream_player: AudioStreamPlayer = $"../../../AudioStreamPlayer"
@onready var audio_stream_player_2: AudioStreamPlayer = $"../../../AudioStreamPlayer2"
@onready var audio_stream_player_3: AudioStreamPlayer = $"../../../AudioStreamPlayer3"
@onready var audio_stream_player_4: AudioStreamPlayer = $"../../../AudioStreamPlayer4"
@onready var audio_stream_player_5: AudioStreamPlayer = $"../../../AudioStreamPlayer5"
@onready var audio_stream_player_6: AudioStreamPlayer = $"../../../AudioStreamPlayer6"
@onready var audio_stream_player_7: AudioStreamPlayer = $"../../../AudioStreamPlayer7"
var rng = RandomNumberGenerator.new()

func play_keyboard():
	var sound = [audio_stream_player_2,
				 audio_stream_player_3,
				 audio_stream_player_4,
				 audio_stream_player_5,
				 audio_stream_player_6,
				 audio_stream_player_7]
	var choice = sound[randi() % sound.size()]
	choice.play()
	
func wait(start, finish):
	var number = rng.randf_range(start, finish)
	await get_tree().create_timer(number).timeout

func type_enter():
	audio_stream_player.play()
	await wait(0.5, 0.8)

func erase_text():
	this.text = ""
	position = this.position
	position[1] = 0.0
	this.set_position(position)

func type(text):
	var half = int(len(text)/20*19)
	for i in range(half):
		if text[i] == "\n":
			await type_enter()
		this.add_text(text[i])
	audio_stream_player.play()
	for i in range(half, len(text)):
		if text[i] == "\n":
			await type_enter()
			continue
		this.add_text(text[i])
		#remover if quando adicionar cursor
		if text[i] != " ":
			play_keyboard()
		await wait(0.1, 0.25)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	erase_text()
	rng.randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
