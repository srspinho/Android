extends Node
## Efeitos sonoros e música. Fica sempre carregado (autoload "Audio" no
## project.godot), então a música não reinicia quando a fase recomeça.
## Os sons são gerados por tools/gen_audio.py.

const SFX_DIR := "res://audio/sfx/"
const MUSIC_DIR := "res://audio/music/"
const VOICES := 10
## O mesmo efeito não toca de novo antes disso (ms), para não "metralhar".
const MIN_REPEAT_MS := 35

var music_on := true

var _players: Array[AudioStreamPlayer] = []
var _next := 0
var _cache := {}
var _last_played := {}
var _music: AudioStreamPlayer
var _music_name := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in VOICES:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)
	_music = AudioStreamPlayer.new()
	_music.volume_db = -5.0
	add_child(_music)


## Toca um efeito (nome do arquivo em audio/sfx, sem .wav).
func sfx(name: String, volume_db := 0.0, pitch_variation := 0.05) -> void:
	var now := Time.get_ticks_msec()
	if now - int(_last_played.get(name, -100000)) < MIN_REPEAT_MS:
		return
	_last_played[name] = now
	var stream := _load(SFX_DIR + name + ".wav")
	if stream == null:
		return
	var p := _players[_next]
	_next = (_next + 1) % VOICES
	p.stream = stream
	p.volume_db = volume_db
	p.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	p.play()


## Troca a música (nome do arquivo em audio/music). Se já estiver tocando, segue.
func music(name: String) -> void:
	if name == _music_name and (_music.playing or not music_on):
		return
	_music_name = name
	_music.stream = _load(MUSIC_DIR + name + ".wav")
	if music_on and _music.stream:
		_music.play()


func stop_music() -> void:
	_music.stop()
	_music_name = ""


func toggle_music() -> bool:
	music_on = not music_on
	if music_on and _music.stream:
		_music.play()
	else:
		_music.stop()
	return music_on


func _load(path: String) -> AudioStream:
	if not _cache.has(path):
		_cache[path] = load(path) if ResourceLoader.exists(path) else null
	return _cache[path]

