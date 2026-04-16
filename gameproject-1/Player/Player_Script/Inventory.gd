extends Resource

class_name Inv

signal inventory_updated

@export var items: Array[InvSlot]

func insert(item: InvItem):
	for items in items:
		if items.item == items:
			items.amount += 1
			inventory_updated.emit() # Tell the UI to refresh
			return
		if !items.item:
			items.item = item
			items.amount = 1
			inventory_updated.emit() # Tell the UI to refresh
			return
