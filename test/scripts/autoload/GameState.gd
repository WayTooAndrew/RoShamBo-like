# scripts/autoloads/GameState.gd
extends Node

const SAVE_PATH := "user://run_save.json"

## ----------------------------------------------------------------------
## Run state
## ----------------------------------------------------------------------
var seed : String = ""
var circuit_index : int = 1
var marbles : int = 5
var rerolls_remaining : int = 4
var inventory_slots : Array[String] = []

var base_max_hp : float = 100.0
var current_hp : float = 0.0

# Explicit autoload reference (compiler-safe)
@onready var SeedManager := get_node("/root/SeedManager")


## ----------------------------------------------------------------------
## Run initialization
## ----------------------------------------------------------------------
func start_new_run(seed_str: String) -> void:
	seed = seed_str
	circuit_index = 1
	marbles = 5
	rerolls_remaining = 4
	inventory_slots.clear()
	current_hp = base_max_hp


## ----------------------------------------------------------------------
## Save current run
## ----------------------------------------------------------------------
func save_current_run() -> void:
	var data := {
		"seed": seed,
		"circuit_index": circuit_index,
		"marbles": marbles,
		"rerolls_remaining": rerolls_remaining,
		"inventory_slots": inventory_slots,
		"current_hp": current_hp
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file for writing.")
		return

	file.store_string(JSON.stringify(data, "\t"))
	file.close()


## ----------------------------------------------------------------------
## Load saved run
## ----------------------------------------------------------------------
func load_saved_run() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		push_error("Save file does not exist yet.")
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file for reading.")
		return false

	var raw_json := file.get_as_text()
	file.close()

	var parsed : Variant = JSON.parse_string(raw_json)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Failed to parse saved run JSON.")
		return false

	var d : Dictionary = parsed

	seed = str(d.get("seed", ""))
	circuit_index = int(d.get("circuit_index", 1))
	marbles = int(d.get("marbles", 0))
	rerolls_remaining = int(d.get("rerolls_remaining", 4))
	current_hp = float(d.get("current_hp", base_max_hp))

	inventory_slots.clear()
	for item in d.get("inventory_slots", []):
		inventory_slots.append(str(item))

	if not SeedManager.validate_seed(seed):
		push_error("Loaded seed is invalid; discarding save.")
		return false

	SeedManager.init_rng_from_seed(seed)
	return true
