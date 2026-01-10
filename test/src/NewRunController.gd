# src/NewRunController.gd
extends Node

@onready var seed_label : Label = $Label
@onready var seed_input : LineEdit = $LineEdit
@onready var start_btn  : Button = $StartButton
@onready var load_btn   : Button = $LoadButton


func _ready() -> void:
	# Generate a fresh random seed
	SeedManager.init_new_run()

	# Sync GameState with the generated seed
	GameState.start_new_run(SeedManager.current_seed)

	seed_label.text = "Current Seed:\n%s" % SeedManager.current_seed

	start_btn.pressed.connect(_on_start_pressed)
	load_btn.pressed.connect(_on_load_pressed)


func _on_start_pressed() -> void:
	var entered := seed_input.text.strip_edges()

	if not SeedManager.validate_seed(entered):
		push_error("Invalid seed! Must be exactly 9 alphanumeric characters.")
		return

	# Initialize deterministic RNG from player seed
	SeedManager.init_run_from_player_seed(entered)

	# Start run using that seed
	GameState.start_new_run(entered)

	seed_label.text = "Seed set to:\n%s" % entered
	print_rich("[color=green]🚀 New run started![/color]")


func _on_load_pressed() -> void:
	if GameState.load_saved_run():
		seed_label.text = "Loaded saved run:\n%s" % GameState.seed
		print_rich("[color=cyan]💾 Run loaded![/color]")
	else:
		push_error("Failed to load a saved run.")
