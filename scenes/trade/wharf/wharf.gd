class_name Wharf extends Area3D

signal wharf_entered(wharf: Wharf, area: Area3D)
signal wharf_exited(wharf: Wharf, area: Area3D)

@export var wharf_name: String = "UNNAMED"
@export var ships_available: Array[String] = []

@onready var billboard: Label3D = %Billboard

var wharf_price_provider: WharfPriceProvider

func _ready():
	area_entered.connect(func(area): 
		wharf_entered.emit(self, area)
	)
	area_exited.connect(func(area):
		wharf_exited.emit(self, area)
	)
	billboard.text = wharf_name

func get_ships_available() -> Array[String]:
	return ships_available
