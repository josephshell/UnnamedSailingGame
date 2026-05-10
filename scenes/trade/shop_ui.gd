class_name ShopUI extends CanvasLayer

@onready var inventory_items: VBoxContainer = %InventoryItems
@onready var sale_items: VBoxContainer = %SaleItems
@onready var buy_items: VBoxContainer = %BuyItems
@onready var shop_name_label: Label = %ShopName

func populate(trading_post: TradingPost):
	var trade_inventory = trading_post.trade_inventory
	shop_name_label.text = "WELCOME TO %s" % trading_post.trading_post_name
	for child in inventory_items.get_children():
		inventory_items.remove_child(child)
		child.queue_free()
	for child in sale_items.get_children():
		sale_items.remove_child(child)
		child.queue_free()
	for child in buy_items.get_children():
		buy_items.remove_child(child)
		child.queue_free()
	for item in trade_inventory.inventory:
		var h_box_container: HBoxContainer = _new_centered_h_box_container()
		var quantity_label = Label.new()
		quantity_label.text = "%dx" % trade_inventory.inventory[item]
		var name_label = Label.new()
		name_label.text = Enums.TradeItem.find_key(item)
		h_box_container.add_child(quantity_label)
		h_box_container.add_child(name_label)
		inventory_items.add_child(h_box_container)
	
	for item in trade_inventory.willing_to_sell:
		var price = trade_inventory.willing_to_sell[item]
		if price == TradeInventory.NOT_AVAILABLE:
			continue
		var h_box_container: HBoxContainer = _new_centered_h_box_container()
		var item_price_label = Label.new()
		item_price_label.text = "$%d" % price
		var name_label = Label.new()
		name_label.text = Enums.TradeItem.find_key(item)
		h_box_container.add_child(item_price_label)
		h_box_container.add_child(name_label)
		sale_items.add_child(h_box_container)
		
		
	for item in trade_inventory.willing_to_buy:
		var price = trade_inventory.willing_to_buy[item]
		if price == TradeInventory.NOT_AVAILABLE:
			continue
		var h_box_container: HBoxContainer = _new_centered_h_box_container()
		var item_price_label = Label.new()
		item_price_label.text = "$%d" % price
		var name_label = Label.new()
		name_label.text = Enums.TradeItem.find_key(item)
		h_box_container.add_child(item_price_label)
		h_box_container.add_child(name_label)
		buy_items.add_child(h_box_container)

func _new_centered_h_box_container() -> HBoxContainer:
	var container = HBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return container
