extends Node

signal upgrade_purchased(upgrade_name: String, new_level: int)

var upgrades_catalog: Dictionary = {
	"power": {
		"base_price": 100,
		"price_multiplier": 1.5,
		"level": 0,
		"effect_per_level": 0.20
	},
	"steer": {
		"base_price": 150,
		"price_multiplier": 1.4,
		"level": 0,
		"effect_per_level": 0.10
	},
	"size": {
		"base_price": 200,
		"price_multiplier": 1.6,
		"level": 0,
		"effect_per_level": 0.10
	},
	"load_speed": {
		"base_price": 250,
		"price_multiplier": 1.7,
		"level": 0,
		"effect_per_level": 0.35
	}
}

var base_truck_stats: Dictionary = {
	"power": 400.0,
	"steer": 0.9,
	"capacity": 5.0,
	"load_speed": 1.0,
	"unload_speed": 1.0,
}

var stat_sources: Dictionary = {
	"power": "power",
	"steer": "steer",
	"capacity": "size",
	"load_speed": "load_speed",
	"unload_speed": "load_speed",
}

func get_stat(stat_name: String) -> float:
	var data: Dictionary = upgrades_catalog[stat_sources[stat_name]]
	var mult : float = 1.0 + data["level"] * data["effect_per_level"]
	return base_truck_stats[stat_name] * mult

func get_capacity() -> int:
	return int(base_truck_stats["capacity"]) + upgrades_catalog["size"]["level"] * 2

func get_load_speed() -> float:
	return get_stat("load_speed")

func get_unload_speed() -> float:
	return get_stat("unload_speed")

func get_upgrade_data(upgrade_name: String) -> Dictionary:
	return upgrades_catalog[upgrade_name]

func get_current_price(upgrade_name: String) -> int:
	var data = upgrades_catalog[upgrade_name]
	return int(data["base_price"] * pow(data["price_multiplier"], data["level"]))

func buy_upgrade(upgrade_name: String) -> bool:
	var price = get_current_price(upgrade_name)
	if GameManager.remove_money(price):
		upgrades_catalog[upgrade_name]["level"] += 1
		upgrade_purchased.emit(upgrade_name, upgrades_catalog[upgrade_name]["level"])
		return true
	return false

func get_available_upgrades() -> Array:
	return upgrades_catalog.keys()
