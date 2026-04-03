extends CanvasLayer

# We grab a reference to the label right when the game starts
@onready var instruction_label = $LedBackground/Label

# This function lets your invisible triggers change the text
func update_text(new_text: String) -> void:
	instruction_label.text = new_text

# Optional: A function to hide the text when the player is just walking
func hide_text() -> void:
	instruction_label.text = ""
