extends Node


const DIR = "res://Resources/Sounds by Pixabay/"
const POOL_SIZE = 8
const EFFECT_VOLUME = -6.0
const MUSIC_VOLUME = -12.0

const EFFECTS = {
	"shoot": "Shoot.mp3",
	"enemy_shoot": "enemy shoot.mp3",
	"tap": "TAP.mp3",
	"hurt": "Hurt.mp3",
	"heart": "heart.mp3",
	"overdrive": "pickup.mp3",
	"explosion": "Explosion.wav",
	"warning": "Warning.mp3",
	"stage_start": "Startinng of satge or a wave.mp3",
	"upgrade": "Upgrade.mp3",
	"wave_clear": "Upgrade.mp3",
	"victory": "Victory.mp3",
	"game_over": "Game Over Music.mp3",
	"game_over_voice": "Game Over Voice.mp3",
}

const VOLUME_OFFSETS = {
	"game_over_voice": 10.0,
	"game_over": -4.0,
}

const MUSIC = {
	"menu": "Background1.mp3",
	"game": "Background2.mp3",
	"boss": "Boss Fight Music.mp3",
}

var effect_players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer
var streams = {}
var current_music = ""

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	for _i in range(POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.volume_db = EFFECT_VOLUME
		add_child(player)
		effect_players.append(player)
		
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = MUSIC_VOLUME
	add_child(music_player)
	
func get_stream(file_name: String) -> AudioStream:
	if streams.has(file_name):
		return streams[file_name]
		
	var path = DIR + file_name
	if not ResourceLoader.exists(path):
		push_warning("Missing Sound: " + path)
		streams[file_name] = null
		return null
		
	streams[file_name] = load(path)
	return streams[file_name]
	
func play(sound_name: String, pitch_range := 0.0, volume_offset := 0.0) -> void:
	if not EFFECTS.has(sound_name):
		return

	var stream = get_stream(EFFECTS[sound_name])
	if stream == null:
		return

	for player in effect_players:
		if not player.playing:
			player.stream = stream
			player.pitch_scale = 1.0 + randf_range(-pitch_range, pitch_range)
			player.volume_db = EFFECT_VOLUME + volume_offset + VOLUME_OFFSETS.get(sound_name, 0.0)
			player.play()
			return
			
func play_music(track: String) -> void:
	if track == current_music and music_player.playing:
		return
		
	current_music = track
	
	var stream = null
	if MUSIC.has(track):
		stream = get_stream(MUSIC[track])
		
	if stream is AudioStreamMP3:
		stream.loop = true
		
	music_player.stream = stream
	music_player.play()
	
func stop_music() -> void:
	current_music = ""
	music_player.stop()	
