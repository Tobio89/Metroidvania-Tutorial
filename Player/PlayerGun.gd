class_name PlayerGun
extends Node2D

const PlayerBullet = preload("res://Player/PlayerBullet.tscn")

export var BULLET_SPEED:int = 250

onready var muzzle := $Sprite/Muzzle
onready var timer := $ShootTimer

func fire_bullet(scaleX:int):
  if timer.is_stopped():
    var bullet := Utils.instance_scene_on_main(PlayerBullet, muzzle.global_position)
    bullet.velocity = Vector2.RIGHT.rotated(rotation) * BULLET_SPEED
    bullet.velocity.x *= scaleX
    bullet.rotation = bullet.velocity.angle()
    timer.start()
  

func _process(_d):
  var player := get_parent()
  rotation = player.get_local_mouse_position().angle()


