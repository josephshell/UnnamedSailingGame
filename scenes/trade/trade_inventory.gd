class_name TradeInventory extends Node

const NOT_AVAILABLE: int = -999

@export var initial_money: int = 100
## A dictionary of item type to quantity in inventory. An item this vendor
## does not possess may not be present in the keys of this dictionary.
@export var inventory: Dictionary[Enums.TradeItem, int] = {}
## A dictionary of item type to sell value at this vendor. Items the
## the vendor does not sell will appear as price -999
@export var willing_to_sell: Dictionary[Enums.TradeItem, int] = {}
## A dictionary of item type to the price this vendor will buy an item.
## Items the vendor will not buy will appear as price -999
@export var willing_to_buy: Dictionary[Enums.TradeItem, int] = {}

var money: int

# Called when the node enters the scene tree for the first time.
func _ready():
	money = initial_money
	for trade_item in Enums.TradeItem.values():
		if not trade_item in willing_to_sell.keys():
			willing_to_sell[trade_item] = NOT_AVAILABLE
		if not trade_item in willing_to_buy.keys():
			willing_to_buy[trade_item] = NOT_AVAILABLE
