extends VBoxContainer

func _ready() -> void:
	GameManager.upgrade_purchased.connect(_on_upgrade_purchased)
	GameManager.money_changed.connect(_on_money_changed)
	_build_buttons()

func _build_buttons() -> void:
	for child in get_children():
		child.queue_free()
	
	for upg in GameManager.upgrades:
		var btn := Button.new()
		btn.name = upg.id
		btn.text = _button_text(upg)
		btn.pressed.connect(GameManager.try_buy_upgrade.bind(upg.id))
		add_child(btn)
		_update_button_state(btn, upg)

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
