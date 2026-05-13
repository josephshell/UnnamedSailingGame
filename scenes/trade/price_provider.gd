class_name PriceProvider extends Node

var base_prices: Dictionary[Enums.TradeItem, int] = {}

func _ready() -> void:
	populate_base_prices()

func populate_base_prices():
	for item in Enums.TradeItem.values():
		var base_price: int
		match item:
			Enums.TradeItem.COFFEE:
				base_price = 10
			Enums.TradeItem.RUM:
				base_price = 10
			_:
				push_error("Item with no base price: ", Enums.TradeItem.find_key(item))
				base_price = 0
		base_prices[item] = base_price

func get_import_price_for(trade_item: Enums.TradeItem, at_post: TradingPost) -> int:
	var max_imported = at_post.amount_to_import.get_or_add(trade_item, 0)
	var current_imported = at_post.trade_inventory.inventory.get_or_add(trade_item, 0)
	var modifier: float
	if current_imported == 0:
		modifier = 2.0
	else:
		# Limit max modifier to 200%
		modifier = minf((max_imported / 2.0) / current_imported, 2.0)
	return base_prices[trade_item] * modifier

func get_export_price_for(trade_item: Enums.TradeItem, at_post: TradingPost) -> int:
	return 10
