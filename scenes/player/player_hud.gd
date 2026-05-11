class_name PlayerHUD extends CanvasLayer

@onready var money: Label = %Money

@onready var inventory_container: VBoxContainer = %InventoryContainer
@onready var speed_bar = %SpeedBar

func set_player_inventory(player_inventory: TradeInventory):
	clear_hud()
	set_money(player_inventory.money)
	set_inventory(player_inventory.inventory)

func set_speed(speed: int):
	speed_bar.value = speed

func clear_hud():
	money.text = "$0"
	for child in inventory_container.get_children():
		inventory_container.remove_child(child)
		child.queue_free()

func set_money(money_amount: int):
	money.text = "$%d" % money_amount

func set_inventory(inventory: Dictionary[Enums.TradeItem, int]):
	for trade_item in inventory:
		var quantity = inventory[trade_item]
		var item_name = Enums.TradeItem.find_key(trade_item)
		var inventory_item_container := HBoxContainer.new()
		var item_quantity_label := Label.new()
		item_quantity_label.text = "%dx" % quantity
		var item_name_label := Label.new()
		item_name_label.text = item_name
		inventory_item_container.add_child(item_quantity_label)
		inventory_item_container.add_child(item_name_label)
		inventory_container.add_child(inventory_item_container)
