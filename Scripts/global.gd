extends Node

var debug_enabled: bool = false
var cheats_enabled: bool = false
var fps_enabled: bool = true

signal log_emitted(text: String)

func log(text: String):
	print(text) # Still print to editor output
	log_emitted.emit(text)
