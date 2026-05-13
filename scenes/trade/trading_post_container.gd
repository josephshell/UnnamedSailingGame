class_name TradingPostContainer extends Node3D

@export var price_provider: PriceProvider

var trading_posts: Array[TradingPost] = []

func _ready():
	for trading_post: TradingPost in find_children("*", "TradingPost"):
		trading_posts.append(trading_post)
		trading_post.price_provider = price_provider

func get_rumors(trading_post: TradingPost) -> Array[Rumor]:
	if trading_post.trading_post_name == "Tortungo":
		var index = trading_posts.find_custom(func(element: TradingPost) -> bool: return element.trading_post_name == "CaféLoca")
		if index != -1:
			var cafe_loca: TradingPost = trading_posts[index]
			return [Rumor.new("CaféLoca looks a little light on Rum", cafe_loca)]
	elif trading_post.trading_post_name == "CaféLoca":
		var index = trading_posts.find_custom(func(element: TradingPost) -> bool: return element.trading_post_name == "Tortungo")
		if index != -1:
			var tortungo: TradingPost = trading_posts[index]
			return [Rumor.new("Tortungo looks a little light on Coffee", tortungo)]
	return []

class Rumor:
	var description: String
	var target_location: Node3D
	
	func _init(_description: String, _target_location: Node3D):
		description = _description
		target_location = _target_location
