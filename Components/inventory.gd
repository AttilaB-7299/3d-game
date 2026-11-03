class_name Inventory extends Node

signal item_updated(val: Item, ammount: int, index: int)

@export var size: int:
	set(new_val):
		if new_val < 0:
			new_val = 0
		size = new_val

var _items: Array[Item]
var _item_counts: Array[int]

func _ready() -> void:
	for i in range(size):
		_items.append(null)
		_item_counts.append(0)


## adds item to inventory if possible. 
## returns true if item was added to inventory
## returns false otherwise
func attempt_add_item(item: Item) -> bool:
	var null_val_index := -1

	for i in range(size):
		if _items.get(i) != null && _items.get(i).item_name == item.item_name:
			_item_counts.set(i, _item_counts.get(i) + 1)

			item_updated.emit(item, _item_counts.get(i), i)
			return true

		if !_items.get(i) && null_val_index == -1:
			null_val_index = i

	if null_val_index != -1:
		_items.set(null_val_index, item)
		_item_counts.set(null_val_index, 1)

		item_updated.emit(item, 1, null_val_index)
		return true

	return false

## if ammout of an item is > 1 than ammount will be reduced by 1
## if ammount of item is 1 then set item val to null & ammount to 0
func pop_item(index: int) -> void:
	if _item_counts.get(index) > 1:
		_item_counts.set(index, _item_counts.get(index) - 1)

	elif _item_counts.get(index) == 1:
		_item_counts.set(index, 0)
		_items.set(index, null)

	item_updated.emit(_items.get(index), _item_counts.get(index), index)

## gets item at index
func get_item(index: int) -> Item:
	return _items.get(index)

## gets item count at index
func get_item_count(index: int) -> int:
	return _item_counts.get(index)
