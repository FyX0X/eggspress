extends VBoxContainer

# Références au tooltip
@onready var tooltip: PanelContainer = $"../ToolTip"
@onready var tooltip_label: RichTextLabel = $"../ToolTip/MarginContainer/ToolTipLabel"

func _ready() -> void:
	GameManager.upgrade_purchased.connect(_on_upgrade_purchased)
	GameManager.money_changed.connect(_on_money_changed)
	
	# Cacher le tooltip au démarrage
	tooltip.visible = false 
	
	_build_buttons()

func _build_buttons() -> void:
	for child in get_children():
		if child.name != "ToolTip":
			child.queue_free()
	
	for upg in GameManager.upgrades:
		var btn := Button.new()
		btn.name = upg.id
		btn.text = _button_text(upg)
		btn.pressed.connect(GameManager.try_buy_upgrade.bind(upg.id))
		
		# NOUVEAU : Connecter les signaux de la souris
		btn.mouse_entered.connect(_on_button_mouse_entered.bind(upg))
		btn.mouse_exited.connect(_on_button_mouse_exited)
		
		add_child(btn)
		_update_button_state(btn, upg)

# --- NOUVELLES FONCTIONS POUR LE TOOLTIP ---

func _on_button_mouse_entered(upg: GameManager.Upgrade) -> void:
	tooltip.visible = true
	
	# Version simple sans BBCode (fonctionne avec un Label standard)
	var text := "%s" % upg.description
		
	tooltip_label.text = text

func _on_button_mouse_exited() -> void:
	tooltip.visible = false

# Fait suivre le tooltip à la souris
func _process(_delta: float) -> void:
	if tooltip.visible:
		# On ajoute un petit décalage (15, 15) pour que le curseur ne cache pas le texte
		tooltip.global_position = get_global_mouse_position() + Vector2(15, 15)

# --- FONCTIONS EXISTANTES ---

func _button_text(upg: GameManager.Upgrade) -> String:
	if upg.level >= upg.max_level:
		return "%s (MAX)" % upg.name
	return "%s (Lv %d) - $%d" % [upg.name, upg.level, upg.price]

func _update_button_state(btn: Button, upg: GameManager.Upgrade) -> void:
	btn.disabled = upg.level >= upg.max_level or not GameManager.is_buyable(upg.price)

func _on_money_changed(_amount: int) -> void:
	for upg in GameManager.upgrades:
		var btn := get_node_or_null(upg.id) as Button
		if btn:
			_update_button_state(btn, upg)

func _on_upgrade_purchased(upg: GameManager.Upgrade) -> void:
	var btn := get_node_or_null(upg.id) as Button
	if btn:
		btn.text = _button_text(upg)
		_update_button_state(btn, upg)
