class_name BaseProjectile
extends Node2D

var velocity = Vector2.ZERO

func _process(delta):
  position += velocity * delta

func _on_VisibilityNotifier2D_screen_exited():
  queue_free()
