extends Resource

class_name Inv

signal inventory_updated

@export var slots: Array[InvSlot]

func insert(item: InvItem):
	# 1. Try to STACK the item
	for slot in slots: 
		# ADDED CHECK: Ensure 'slot' is not Nil before checking '.item'
		if slot != null and slot.item == item:
			slot.amount += 1
			inventory_updated.emit()
			return
			
	# 2. Find the first EMPTY slot
	for slot in slots:
		# ADDED CHECK: Ensure 'slot' is not Nil
		if slot != null and !slot.item:
			slot.item = item
			slot.amount = 1
			inventory_updated.emit()
			return
