class_name MenuUI extends Control

signal exit_menu
var inMenu : bool = false

func exit():
	exit_menu.emit()
