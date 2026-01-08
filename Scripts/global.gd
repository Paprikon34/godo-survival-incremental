extends Node

var debug_enabled: bool = false
var cheats_enabled: bool = false

signal log_emitted(text: String)

func log(text: String):
	print(text) # Still print to editor output
	log_emitted.emit(text)
