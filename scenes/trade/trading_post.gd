class_name TradingPost extends Area3D

signal trading_post_entered(trading_post: TradingPost, area: Area3D)
signal trading_post_exited(trading_post: TradingPost, area: Area3D)

@export var trading_post_name: String = "UNNAMED"
@export var trade_inventory: TradeInventory

func _ready():
	area_entered.connect(func(area): 
		trading_post_entered.emit(self, area)
	)
	area_exited.connect(func(area):
		trading_post_exited.emit(self, area)
	)
