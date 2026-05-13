class_name ShopUI extends CanvasLayer

signal buy_button_pressed(trade_item: Enums.TradeItem)
signal sell_button_pressed(trade_item: Enums.TradeItem)
signal rumors_button_pressed(trading_post: TradingPost)
signal exit_menu_button_pressed

@export var price_provider: PriceProvider

@onready var inventory_items: VBoxContainer = %InventoryItems
@onready var sale_items: VBoxContainer = %SaleItems
@onready var buy_items: VBoxContainer = %BuyItems
@onready var shop_name_label: Label = %ShopName
@onready var money: Label = %Money

@onready var rumors_button: Button = %RumorsButton
@onready var exit_menu_button = %ExitMenuButton

@onready var primary_shop_window = %PrimaryShopWindow
@onready var tutorial_popup = %TutorialPopup

@onready var rumor_container: PanelContainer = %RumorContainer
@onready var rumor_label: Label = %RumorLabel
@onready var dismiss_rumor_button: Button = %DismissRumorButton

const SHOP_BUTTON = preload("uid://brqfslk3rb0lk")

func _ready():
	%ExitMenuButton.pressed.connect(exit_menu_button_pressed.emit)
	_dismiss_rumor_container()
	dismiss_rumor_button.pressed.connect(_dismiss_rumor_container)

func _dismiss_rumor_container():
	rumor_container.hide()
	
func _enable_rumor_container(rumor: TradingPostContainer.Rumor):
	rumor_label.text = rumor.description
	rumor_container.show()

func toggle_primary_shop_window(make_visible: bool):
	primary_shop_window.visible = make_visible
	exit_menu_button.visible = make_visible

func toggle_tutorial_popup(make_visible: bool):
	tutorial_popup.visible = make_visible

func populate(trading_post: TradingPost):
	var trade_inventory = trading_post.trade_inventory
	shop_name_label.text = "WELCOME TO %s" % trading_post.trading_post_name
	money.text = "$%d" % trading_post.trade_inventory.money
	for connection in rumors_button.pressed.get_connections():
		rumors_button.pressed.disconnect(connection["callable"])
	rumors_button.pressed.connect(func(): rumors_button_pressed.emit(trading_post))
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
	
	for export in trading_post.get_exports():
		if not trading_post.is_exporting(export):
			continue
		var h_box_container: HBoxContainer = _new_centered_h_box_container()
		var item_price_label = Label.new()
		var price = trading_post.export_price_for(export)
		item_price_label.text = "$%d" % price
		var name_label = Label.new()
		name_label.text = Enums.TradeItem.find_key(export)
		var buy_button: Button = SHOP_BUTTON.instantiate()
		buy_button.pressed.connect(func(): buy_button_pressed.emit(export))
		h_box_container.add_child(item_price_label)
		h_box_container.add_child(name_label)
		h_box_container.add_child(buy_button)
		sale_items.add_child(h_box_container)
		
		
	for import in trading_post.get_imports():
		if not trading_post.is_importing(import):
			continue
		var price = trading_post.import_price_for(import)
		var h_box_container: HBoxContainer = _new_centered_h_box_container()
		var item_price_label = Label.new()
		item_price_label.text = "$%d" % price
		var name_label = Label.new()
		name_label.text = Enums.TradeItem.find_key(import)
		var sell_button: Button = SHOP_BUTTON.instantiate()
		sell_button.pressed.connect(func(): sell_button_pressed.emit(import))
		sell_button.text = "Sell"
		h_box_container.add_child(item_price_label)
		h_box_container.add_child(name_label)
		h_box_container.add_child(sell_button)
		buy_items.add_child(h_box_container)

func _new_centered_h_box_container() -> HBoxContainer:
	var container = HBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return container

func set_rumor(rumor: TradingPostContainer.Rumor):
	if rumor:
		_enable_rumor_container(rumor)
	else:
		_dismiss_rumor_container()
