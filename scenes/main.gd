extends Node3D

@onready var shop_ui: ShopUI = %ShopUI
@onready var shop_name_ui = %ShopNameUI
@onready var shop_name_label = %ShopNameLabel

@onready var player_hud: PlayerHUD = %PlayerHud

@onready var trading_post_container: TradingPostContainer = %TradingPostContainer

@onready var player_trade_inventory: TradeInventory = %PlayerTradeInventory

@onready var movement_component: MovementComponent = %MovementComponent
@onready var camera_controller = %CameraController
@onready var boat: Boat = %Boat

var near_shop: TradingPost

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disable_shop_menu()
	shop_name_ui.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	movement_component.boat = boat
	player_hud.set_player_inventory(player_trade_inventory)
	player_hud.set_speed(movement_component.get_speed_mode())
	
	for child in trading_post_container.get_children():
		if child is TradingPost:
			child.trading_post_entered.connect(_on_trading_post_entered)
			child.trading_post_exited.connect(_on_trading_post_exited)

#region TradingPost Signals
func _on_trading_post_entered(trading_post: TradingPost, area: Area3D):
	if area.is_in_group("player"):
		_on_boat_player_arrived_at_post(trading_post)

func _on_trading_post_exited(trading_post: TradingPost, area: Area3D):
	if area.is_in_group("player"):
		_on_boat_player_left_post()

func _on_boat_player_arrived_at_post(trading_post: TradingPost):
	shop_name_label.text = "WELCOME TO %s" % trading_post.trading_post_name
	shop_ui.toggle_tutorial_popup(true)
	shop_name_ui.show()
	near_shop = trading_post

func _on_boat_player_left_post():
	disable_shop_menu()
	near_shop = null

#endregion

func capture_mouse():
	camera_controller.is_camera_locked = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func confine_mouse():
	camera_controller.is_camera_locked = true
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func release_mouse():
	camera_controller.is_camera_locked = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func get_first_sellable_item(trading_post: TradingPost) -> Enums.TradeItem:
	for item in trading_post.trade_inventory.inventory:
		if trading_post.trade_inventory.inventory[item] > 0:
			return item
	return Enums.TradeItem.NULL

func can_player_afford(trade_item: Enums.TradeItem, at_shop: TradingPost) -> bool:
	var cost = at_shop.trade_inventory.willing_to_sell[trade_item]
	return cost != TradeInventory.NOT_AVAILABLE and player_trade_inventory.money >= cost

func buy(trade_item: Enums.TradeItem, at_shop: TradingPost):
	var abort_trade: bool = false
	# check if shop sells trade_item
	if not at_shop.is_item_for_sale(trade_item):
		print("Shop %s is not selling %s" % [at_shop.trading_post_name, Enums.TradeItem.find_key(trade_item)])
		abort_trade = true
		
	# determine buy price
	var buy_price = at_shop.trade_inventory.willing_to_sell.get_or_add(trade_item, TradeInventory.NOT_AVAILABLE)
	if buy_price == TradeInventory.NOT_AVAILABLE:
		print("Shop %s is not selling %s" % [at_shop.trading_post_name, Enums.TradeItem.find_key(trade_item)])
		abort_trade = true
	
	# check if player can afford transaction
	if player_trade_inventory.money < buy_price:
		printerr("Player failed to buy item, not enough money to cover transaction")
		abort_trade = true
	
	# check if shop has item in inventory
	var shop_current_count: int = at_shop.trade_inventory.inventory.get_or_add(trade_item, 0)
	if shop_current_count <= 0:
		printerr("Shop failed to sell item, no stock")
		abort_trade = true
	
	if abort_trade:
		printerr("Transaction failed, aborting trade")
		return
	
	# transfer items from shop to player
	at_shop.trade_inventory.inventory[trade_item] = max(shop_current_count - 1, 0)
	player_trade_inventory.inventory[trade_item] = player_trade_inventory.inventory.get_or_add(trade_item, 0) + 1
	
	# transfer money from player to shop
	at_shop.trade_inventory.money += buy_price
	player_trade_inventory.money = max(player_trade_inventory.money - buy_price, 0)
	
	player_hud.set_player_inventory(player_trade_inventory)
	shop_ui.populate(at_shop)

func sell(trade_item: Enums.TradeItem, at_shop: TradingPost):
	var abort_trade: bool = false
	# check if shop wants trade_item
	if not at_shop.is_item_wanted(trade_item):
		print("Shop %s is not buying %s" % [at_shop.trading_post_name, Enums.TradeItem.find_key(trade_item)])
		abort_trade = true
		
	# determine sell price
	var sale_price = at_shop.trade_inventory.willing_to_buy.get_or_add(trade_item, TradeInventory.NOT_AVAILABLE)
	if sale_price == TradeInventory.NOT_AVAILABLE:
		print("Shop %s is not buying %s" % [at_shop.trading_post_name, Enums.TradeItem.find_key(trade_item)])
		abort_trade = true
	
	# check if shop can afford transaction
	if at_shop.trade_inventory.money < sale_price:
		printerr("Shop failed to buy item, not enough money to cover transaction")
		abort_trade = true
	
	# check if player has item in inventory
	var player_current_count: int = player_trade_inventory.inventory.get_or_add(trade_item, 0)
	if player_current_count <= 0:
		printerr("Player failed to sell item, no stock")
		abort_trade = true
	
	if abort_trade:
		printerr("Transaction failed, aborting trade")
		return
	
	# transfer items
	player_trade_inventory.inventory[trade_item] = max(player_current_count - 1, 0)
	at_shop.trade_inventory.inventory[trade_item] = at_shop.trade_inventory.inventory.get_or_add(trade_item, 0) + 1
	
	# transfer money
	player_trade_inventory.money += sale_price
	at_shop.trade_inventory.money = max(at_shop.trade_inventory.money - sale_price, 0)
	
	player_hud.set_player_inventory(player_trade_inventory)
	shop_ui.populate(at_shop)


#region shopUI signals
func _on_shop_ui_buy_button_pressed(trade_item):
	if near_shop:
		buy(trade_item, near_shop)
	else:
		push_error("Cannot buy %s, no shop nearby" % Enums.TradeItem.find_key(trade_item))

func _on_shop_ui_sell_button_pressed(trade_item):
	print("selling ", Enums.TradeItem.find_key(trade_item))
	if near_shop:
		sell(trade_item, near_shop)
	else:
		push_error("Cannot sell %s, no valid shop nearby" % Enums.TradeItem.find_key(trade_item))

func _on_shop_ui_rumors_button_pressed(trading_post: TradingPost) -> void:
	var all_rumors = trading_post_container.get_rumors(trading_post)
	if all_rumors.is_empty():
		print("No rumors available at trading post ", trading_post.trading_post_name)
	else:
		var rumor = all_rumors.pick_random()
		print("Rumor: %s" % rumor.description)
		shop_ui.set_rumor(rumor)

func _on_shop_ui_exit_menu_button_pressed():
	disable_shop_menu()
	_on_boat_player_arrived_at_post(near_shop)

#endregion

#region InputComponent signals

func _on_input_component_movement_pressed(direction: Vector2) -> void:
	movement_component.on_turn_input(direction.x)

func _on_input_component_mouse_moved(scaled_relative_movement: Vector2) -> void:
	camera_controller.on_mouse_moved(scaled_relative_movement)

func _on_input_component_exit_pressed():
	get_tree().quit()

func _on_input_component_forwards_pressed():
	movement_component.increase_speed()
	player_hud.set_speed(movement_component.get_speed_mode())

func _on_input_component_backwards_pressed():
	movement_component.decrease_speed()
	player_hud.set_speed(movement_component.get_speed_mode())

func _on_input_component_toggle_inventory_pressed():
	if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
		release_mouse()
	else:
		capture_mouse()

func _on_input_component_interact_pressed():
	if near_shop:
		initiate_shop_menu()

#endregion

func initiate_shop_menu():
	confine_mouse()
	shop_ui.populate(near_shop)
	shop_ui.set_rumor(null)
	shop_ui.toggle_primary_shop_window(true)
	shop_ui.toggle_tutorial_popup(false)

func disable_shop_menu():
	shop_ui.toggle_primary_shop_window(false)
	shop_ui.toggle_tutorial_popup(false)
	shop_name_ui.hide()
	shop_name_label.text = "ERROR"
	capture_mouse()
