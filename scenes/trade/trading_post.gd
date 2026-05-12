class_name TradingPost extends Area3D

signal trading_post_entered(trading_post: TradingPost, area: Area3D)
signal trading_post_exited(trading_post: TradingPost, area: Area3D)

@export var trading_post_name: String = "UNNAMED"
@export var trade_inventory: TradeInventory

@onready var trading_post_billboard: Label3D = %TradingPostBillboard

func _ready():
	area_entered.connect(func(area): 
		trading_post_entered.emit(self, area)
	)
	area_exited.connect(func(area):
		trading_post_exited.emit(self, area)
	)
	trading_post_billboard.text = trading_post_name

func is_item_wanted(trade_item: Enums.TradeItem) -> bool:
	return _has_buy_price(trade_item)

func _has_buy_price(trade_item: Enums.TradeItem) -> bool:
	return trade_inventory.willing_to_buy.get_or_add(trade_item, TradeInventory.NOT_AVAILABLE) != TradeInventory.NOT_AVAILABLE

func is_item_for_sale(trade_item: Enums.TradeItem) -> bool:
	return _item_in_inventory(trade_item) and _has_sale_price(trade_item)

func _item_in_inventory(trade_item: Enums.TradeItem) -> bool:
	return trade_inventory.inventory.get_or_add(trade_item, 0) != 0

func _has_sale_price(trade_item: Enums.TradeItem) -> bool:
	return trade_inventory.willing_to_sell.get_or_add(trade_item, TradeInventory.NOT_AVAILABLE) != TradeInventory.NOT_AVAILABLE
