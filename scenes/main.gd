extends Node3D

@onready var shop_ui: ShopUI = %ShopUI
@onready var shop_name_ui = %ShopNameUI
@onready var shop_name_label = %ShopNameLabel

@onready var trading_post_container: Node3D = %TradingPostContainer

@onready var player_trade_inventory: TradeInventory = %PlayerTradeInventory

@onready var movement_component: MovementComponent = %MovementComponent
@onready var boat: Boat = %Boat

var near_shop: TradingPost

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shop_ui.hide()
	shop_name_ui.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	movement_component.boat = boat
	
	for child in trading_post_container.get_children():
		if child is TradingPost:
			child.trading_post_entered.connect(_on_trading_post_entered)
			child.trading_post_exited.connect(_on_trading_post_exited)


func _on_trading_post_entered(trading_post: TradingPost, area: Area3D):
	if area.is_in_group("player"):
		_on_boat_player_arrived_at_post(trading_post)

func _on_trading_post_exited(trading_post: TradingPost, area: Area3D):
	if area.is_in_group("player"):
		_on_boat_player_left_post()

func _on_boat_player_arrived_at_post(trading_post: TradingPost):
	shop_name_label.text = "WELCOME TO %s" % trading_post.trading_post_name
	shop_ui.populate(trading_post)
	shop_ui.show()
	shop_name_ui.show()
	near_shop = trading_post

func _on_boat_player_left_post():
	shop_ui.hide()
	shop_name_ui.hide()
	shop_name_label.text = "ERROR"
	near_shop = null

func shop(trading_post: TradingPost):
	print("Player wants to shop at ", trading_post.trading_post_name)
	var item_to_buy: Enums.TradeItem = get_first_sellable_item(trading_post)
	if can_player_afford(item_to_buy, trading_post):
		purchase(item_to_buy, trading_post)

func get_first_sellable_item(trading_post: TradingPost) -> Enums.TradeItem:
	for item in trading_post.trade_inventory.inventory:
		if trading_post.trade_inventory.inventory[item] > 0:
			return item
	return Enums.TradeItem.NULL

func can_player_afford(trade_item: Enums.TradeItem, at_shop: TradingPost) -> bool:
	var cost = at_shop.trade_inventory.willing_to_sell[trade_item]
	return cost != TradeInventory.NOT_AVAILABLE and player_trade_inventory.money >= cost

func purchase(trade_item: Enums.TradeItem, at_shop: TradingPost):
	var cost = at_shop.trade_inventory.willing_to_sell[trade_item]
	if cost != TradeInventory.NOT_AVAILABLE:
		player_trade_inventory.money = max(player_trade_inventory.money - cost, 0)
		var current_inventory = player_trade_inventory.inventory.get_or_add(trade_item, 0)
		player_trade_inventory.inventory[trade_item] += 1
	else:
		printerr(
			"Failed to purchase %s at shop %s. Price was not available." % \
				[Enums.TradeItem.find_key(trade_item), at_shop.trading_post_name]
		)
#region InputComponent
func _on_input_component_interact_pressed():
	if near_shop != null:
		shop(near_shop)

#endregion
