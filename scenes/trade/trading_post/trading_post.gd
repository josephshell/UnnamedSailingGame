class_name TradingPost extends Area3D

signal trading_post_entered(trading_post: TradingPost, area: Area3D)
signal trading_post_exited(trading_post: TradingPost, area: Area3D)

@export var trading_post_name: String = "UNNAMED"
@export var trade_inventory: TradeInventory

@onready var trading_post_billboard: Label3D = %TradingPostBillboard

@export var amount_to_import: Dictionary[Enums.TradeItem, int] = {}
@export var _exports: Array[Enums.TradeItem] = []

func _ready():
	area_entered.connect(func(area): 
		trading_post_entered.emit(self, area)
	)
	area_exited.connect(func(area):
		trading_post_exited.emit(self, area)
	)
	trading_post_billboard.text = trading_post_name

func get_exports() -> Array[Enums.TradeItem]:
	return _exports

func get_imports() -> Array[Enums.TradeItem]:
	return amount_to_import.keys()

func is_importing(trade_item: Enums.TradeItem) -> bool:
	var max_import_quantity = amount_to_import.get_or_add(trade_item, 0)
	return trade_inventory.inventory.get_or_add(trade_item, 0) < max_import_quantity
		
func is_exporting(trade_item: Enums.TradeItem) -> bool:
	return trade_item in _exports \
		and trade_inventory.inventory.get_or_add(trade_item, 0) > 0

func import_price_for(trade_item: Enums.TradeItem) -> int:
	return 20

func export_price_for(trade_item: Enums.TradeItem) -> int:
	return 10
