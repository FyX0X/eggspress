extends Control

@export var upgrade_name: String = "power"

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var price_label: Label = $VBoxContainer/PriceLabel
@onready var buy_button: Button = $VBoxContainer/BuyButton

func _ready() -> void:
	update_ui()
	# On écoute si l'argent change OU si on achète une autre upgrade
	Wallet.money_changed.connect(_on_data_changed)
	UpgradeManager.upgrade_purchased.connect(_on_data_changed)
	buy_button.pressed.connect(_on_buy_pressed)

func update_ui() -> void:
	var data = UpgradeManager.get_upgrade_data(upgrade_name)
	var price = UpgradeManager.get_current_price(upgrade_name)
	
	name_label.text = upgrade_name.capitalize()
	level_label.text = "Level: " + str(data["level"])
	price_label.text = "Price: " + str(price) + " $"
	
	# Grise le bouton si pas assez d'argent
	buy_button.disabled = not Wallet.is_buyable(price)

func _on_data_changed(_arg = null) -> void:
	update_ui()

func _on_buy_pressed() -> void:
	if UpgradeManager.buy_upgrade(upgrade_name):
		print("Upgrade achetée : ", upgrade_name)
		# L'UI se mettra à jour toute seule grâce au signal upgrade_purchased
