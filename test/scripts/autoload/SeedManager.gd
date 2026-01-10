# scripts/autoloads/SeedManager.gd
extends Node

## ----------------------------------------------------------------------
## 1️⃣  Constants
## ----------------------------------------------------------------------
const CHARSET := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
const SEED_LENGTH := 9

## ----------------------------------------------------------------------
## 2️⃣  State
## ----------------------------------------------------------------------
var current_seed := ""
var run_rng : RandomNumberGenerator

## ----------------------------------------------------------------------
## 3️⃣  Seed generation
## ----------------------------------------------------------------------
func generate_alphanum_seed() -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var result := ""
	for i in range(SEED_LENGTH):
		var idx := rng.randi_range(0, CHARSET.length() - 1)
		result += CHARSET.substr(idx, 1)
	return result

## ----------------------------------------------------------------------
## 4️⃣  Seed validation
## ----------------------------------------------------------------------
func validate_seed(seed_str: String) -> bool:
	if seed_str.length() != SEED_LENGTH:
		return false

	for ch in seed_str:
		if CHARSET.find(ch) == -1:
			return false

	return true

## ----------------------------------------------------------------------
## 5️⃣  RNG initialization (deterministic)
## ----------------------------------------------------------------------
func init_rng_from_seed(seed_str: String) -> void:
	run_rng = RandomNumberGenerator.new()
	run_rng.seed = seed_str.hash()

## ----------------------------------------------------------------------
## 6️⃣  Run initialization
## ----------------------------------------------------------------------
func init_new_run() -> void:
	current_seed = generate_alphanum_seed()
	init_rng_from_seed(current_seed)

func init_run_from_player_seed(seed_str: String) -> bool:
	if not validate_seed(seed_str):
		return false

	current_seed = seed_str
	init_rng_from_seed(seed_str)
	return true
