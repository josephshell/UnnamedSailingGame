class_name TradingPostContainer extends Node3D

@export var price_provider: PriceProvider

var trading_posts: Array[TradingPost] = []

func _ready():
	for trading_post: TradingPost in find_children("*", "TradingPost"):
		trading_posts.append(trading_post)
		trading_post.price_provider = price_provider

func get_rumors(current_trading_post: TradingPost) -> Array[GlobalClasses.Rumor]:
	var rumors: Array[GlobalClasses.Rumor] = []
	for trading_post in trading_posts:
		if trading_post == current_trading_post:
			continue # Skip this trading post
		for high_value_import in trading_post.get_imports_at_max_value():
			var post_name = trading_post.trading_post_name
			var import_name = Enums.TradeItem.find_key(high_value_import)
			rumors.append(GlobalClasses.Rumor.new(
				"%s would pay a high price for %s" % [post_name, import_name],
				trading_post
			))
	return rumors
