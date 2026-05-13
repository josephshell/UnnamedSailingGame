class_name TradeInventory extends Node

#const NOT_AVAILABLE: int = -999

## The amount of money the trade inventory will start with
@export var initial_money: int = 100
## A dictionary of item type to quantity in inventory. An item this vendor
## does not possess may not be present in the keys of this dictionary.
@export var inventory: Dictionary[Enums.TradeItem, int] = {}

var money: int

func _ready():
	money = initial_money
