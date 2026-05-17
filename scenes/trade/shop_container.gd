class_name ShopContainer extends Node3D

@export var price_provider: PriceProvider
@export var wharf_price_provider: WharfPriceProvider

var trading_posts: Array[TradingPost] = []
var wharfs: Array[Wharf] = []

func _ready():
	for trading_post: TradingPost in find_children("*", "TradingPost"):
		trading_posts.append(trading_post)
		trading_post.price_provider = price_provider
	for wharf: Wharf in find_children("*", "Wharf"):
		wharfs.append(wharf)
		wharf.wharf_price_provider = wharf_price_provider

func get_trading_posts() -> Array[TradingPost]:
	return trading_posts

func get_wharfs() -> Array[Wharf]:
	return wharfs

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
	for wharf in wharfs:
		var wharf_name := wharf.wharf_name
		var ships := ", ".join(wharf.get_ships_available().map(func(ship): return Enums.Ships.find_key(ship)))
		rumors.append(GlobalClasses.Rumor.new(
			"%s is selling the following ships %s" % [wharf_name, ships],
			wharf
		))
	return rumors
