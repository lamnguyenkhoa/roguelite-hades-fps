extends Node3D
class_name Gun

@export var gun_resource: GunResource
@export var bullet_trail: PackedScene

@onready var barrel: Marker3D = $Barrel
