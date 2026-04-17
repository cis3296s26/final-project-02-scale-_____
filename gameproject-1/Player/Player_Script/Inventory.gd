extends Resource

class_name Inv

signal inventory_updated

@export var slots: Array[InvSlot]

func insert(item: InvItem):
	for slot in slots: 
		if slot != null and slot.item == item:
			slot.amount += 1
			inventory_updated.emit()
			return
			
	for slot in slots:
		if slot != null and !slot.item:
			slot.item = item
			slot.amount = 1
			inventory_updated.emit()
			return

func remove_item(item: InvItem):
	for slot in slots:
		if slot.item == item:
			slot.amount -= 1
			if slot.amount <= 0:
				slot.item = null # Clear the slot if empty
			inventory_updated.emit()
			return
