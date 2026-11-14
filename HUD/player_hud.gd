extends Control

# --- Références UI permanente ---
@onready var money_label: Label = $MoneyLabel
@onready var timer_label: Label = $TimerLabel
@onready var delivery_lab: Label = $DeliveryLab
@onready var capacity_label: Label = $BottomRight/CapacityL
@onready var speed_label: Label = $BottomRight/SpeedLab

# --- Référence UI conditionnelle (Ferme) ---
@onready var farm_ui: VBoxContainer = $FarmUI

# --- Référence à la scène des cartes ---
@export var upgrade_card_scene: PackedScene

var current_truck: Truck = null
var total_delivered: int = 0
var total_target: int = 100
var cards_generated: bool = false

func _ready() -> void:
	# Cache FarmUI au départ
	farm_ui.visible = false
	
	# Écoute l'argent
	Wallet.money_changed.connect(_on_money_changed)
	_on_money_changed(Wallet.money)
	
	_update_delivery_label()

func _process(delta: float) -> void:
	# Mise à jour de la vitesse
	if current_truck:
		var speed_kmh = current_truck.linear_velocity.length() * 3.6
		speed_label.text = "Vitesse: %d km/h" % speed_kmh

# --- Mises à jour permanentes ---

func _on_money_changed(amount: int) -> void:
	money_label.text = "Argent: %d $" % amount

func bind_truck(truck: Truck) -> void:
	current_truck = truck
	truck.chickens_changed.connect(_on_truck_chickens_changed)
	_on_truck_chickens_changed(truck.get_chicken_count())

func _on_truck_chickens_changed(count: int) -> void:
	if current_truck:
		capacity_label.text = "%d / %d" % [count, current_truck.capacity]

func add_delivered_chickens(amount: int) -> void:
	total_delivered += amount
	_update_delivery_label()

func _update_delivery_label() -> void:
	delivery_lab.text = "%d / %d" % [total_delivered, total_target]

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
