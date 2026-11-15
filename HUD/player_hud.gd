extends Control

# --- Références UI permanente ---
@onready var money_label: Label = $MoneyLabel
@onready var timer_label: Label = $TimerLabel
@onready var delivery_label: Label = $DeliveryLabel
@onready var capacity_label: Label = $BottomRight/CapacityLabel
@onready var speed_label: Label = $BottomRight/SpeedLabel

# --- Référence UI conditionnelle (Ferme) ---
@onready var farm_ui: VBoxContainer = $FarmHUD

# --- Référence à la scène des cartes ---
@export var upgrade_card_scene: PackedScene

@export var truck: Truck
var cards_generated: bool = false

func _ready() -> void:
	# Cache FarmUI au départ
	farm_ui.visible = false
	
	# Écoute l'argent
	GameManager.money_changed.connect(_on_money_changed)
	_on_money_changed(GameManager.money)
	GameManager.chicken_delivered_changed.connect(_on_delivery_changed)
	_on_delivery_changed(GameManager.chicken_delivered)
	
	truck = GameManager.truck
	assert(truck)
	truck.chicken_area.chickens_changed.connect(_on_truck_chickens_changed)
	_on_truck_chickens_changed(truck.get_chicken_count())

func _process(delta: float) -> void:
	# Mise à jour de la vitesse
	var speed_kmh = truck.linear_velocity.length() * 3.6
	speed_label.text = "Speed: %d km/h" % speed_kmh
	timer_label.text = GameManager.get_formatted_time()

# --- Mises à jour permanentes ---

func _on_money_changed(amount: int) -> void:
	money_label.text = "Money: %d $" % amount

func _on_truck_chickens_changed(count: int) -> void:
	capacity_label.text = "%d / %d Chickens in Truck" % [count, truck.capacity]

func _on_delivery_changed(amount: int) -> void:
	delivery_label.text = "%d / %d Chickens Delivered" % [amount, GameManager.chicken_delivery_total]

# --- Gestion des Upgrade Cards (génération auto) ---

func _generate_upgrade_cards() -> void:
	if cards_generated or upgrade_card_scene == null:
		return
	
	# Parcourt toutes les clés du dictionnaire upgrades_catalog
	for upgrade_name in UpgradeManager.upgrades_catalog.keys():
		var card = upgrade_card_scene.instantiate()
		card.upgrade_name = upgrade_name  # Passe le nom à la carte
		farm_ui.add_child(card)
	
	cards_generated = true

# --- Affichage / Masquage de la FarmUI ---

func show_farm_ui() -> void:
	_generate_upgrade_cards()  # Génère les cartes la première fois
	farm_ui.visible = true

func hide_farm_ui() -> void:
	farm_ui.visible = false
