class_name PlayerHUD
extends Control

# --- Références UI permanente ---
@onready var money_label: Label = $MoneyLabel
@onready var timer_label: Label = $TimerLabel
@onready var delivery_label: Label = $DeliveryLabel
@onready var capacity_label: Label = $BottomRight/CapacityLabel
@onready var speed_label: Label = $BottomRight/SpeedLabel

@onready var engine_light: Control = $EngineLight

# --- Référence UI conditionnelle (Ferme) ---
@onready var farm_ui: VBoxContainer = $FarmHUD

@onready var interaction_prompt: HBoxContainer = $InteractionPrompt
@onready var action_label: Label = $InteractionPrompt/ActionLabel
var truck: Truck

func _init() -> void:
	GameManager.player_hud = self

func _ready() -> void:
	
	# Cache FarmUI au départ
	hide_farm_ui()
	hide_interaction_prompt()
	
	# Écoute l'argent
	GameManager.money_changed.connect(_on_money_changed)
	_on_money_changed(GameManager.money)
	GameManager.chicken_delivered_changed.connect(_on_delivery_changed)
	_on_delivery_changed(GameManager.chicken_delivered)
	
	truck = GameManager.truck
	assert(truck)
	truck.chicken_area.chickens_changed.connect(_on_truck_chickens_changed)
	_on_truck_chickens_changed(truck.get_chicken_count())
	
	truck.engine_drowned_changed.connect(_on_engine_drowned_changed)
	_on_engine_drowned_changed(truck.engine_drowned)

func _process(delta: float) -> void:
	# Mise à jour de la vitesse
	var speed_kmh = truck.linear_velocity.length() * 3.6
	speed_label.text = "Speed: %d km/h" % speed_kmh
	timer_label.text = GameManager.get_formatted_time()

# --- Mises à jour permanentes ---

func _on_engine_drowned_changed(drowned: bool) -> void:
	engine_light.visible = drowned

func _on_money_changed(amount: int) -> void:
	money_label.text = "Money: %d $" % amount

func _on_truck_chickens_changed(count: int) -> void:
	capacity_label.text = "%d / %d Chickens in Truck" % [count, truck.capacity]

func _on_delivery_changed(amount: int) -> void:
	delivery_label.text = "%d / %d Chickens Delivered" % [amount, GameManager.chicken_delivery_total]

# --- Gestion des Upgrade Cards (génération auto) ---


# --- Affichage / Masquage de la FarmUI ---

func show_farm_ui() -> void:
	farm_ui.visible = true

func hide_farm_ui() -> void:
	farm_ui.visible = false

func show_interaction_prompt(action_text: String) -> void:
	action_label.text = action_text
	interaction_prompt.visible = true

func hide_interaction_prompt() -> void:
	interaction_prompt.visible = false
