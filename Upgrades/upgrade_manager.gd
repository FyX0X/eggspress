extends Node

# Signal pour prévenir l'UI qu'une amélioration a été achetée
signal upgrade_purchased(upgrade_name: String, new_level: int)

# --- CATALOGUE DES AMÉLIORATIONS ---
# On définit ici les stats de base et le coût de chaque amélioration
var upgrades_catalog: Dictionary = {
	"power": {
		"base_price": 100,
		"price_multiplier": 1.5,
		"level": 0,
		"effect_per_level": 0.20 # +20% de puissance par niveau
	},
	"steer": {
		"base_price": 150,
		"price_multiplier": 1.4,
		"level": 0,
		"effect_per_level": 0.10 # +10% de direction par niveau
	},
	"size": {
		"base_price": 200,
		"price_multiplier": 1.6,
		"level": 0,
		"effect_per_level": 0.10 # +10% de taille par niveau
	}
}

# --- STATISTIQUES DE BASE DU CAMION ---
# Ces valeurs seront multipliées par les effets des upgrades
var base_truck_stats: Dictionary = {
	"power": 400.0,
	"steer": 0.9,
	"scale": 1.0
}

# --- FONCTIONS POUR L'UI ---

func get_upgrade_data(upgrade_name: String) -> Dictionary:
	return upgrades_catalog[upgrade_name]

func get_current_price(upgrade_name: String) -> int:
	var data = upgrades_catalog[upgrade_name]
	return int(data["base_price"] * pow(data["price_multiplier"], data["level"]))

func buy_upgrade(upgrade_name: String) -> bool:
	var price = get_current_price(upgrade_name)
	# On demande au Wallet de retirer l'argent
	if Wallet.remove_money(price):
		upgrades_catalog[upgrade_name]["level"] += 1
		upgrade_purchased.emit(upgrade_name, upgrades_catalog[upgrade_name]["level"])
		return true
	return false

# --- FONCTIONS POUR LE CAMION ---

# Le camion appellera cette fonction au _ready() pour connaître ses nouvelles stats
func get_final_stat(stat_name: String) -> float:
	var data = upgrades_catalog[stat_name]
	var base_value = base_truck_stats[stat_name]
	var multiplier = 1.0 + (data["level"] * data["effect_per_level"])
	return base_value * multiplier

func get_available_upgrades() -> Array:
	return upgrades_catalog.keys()
