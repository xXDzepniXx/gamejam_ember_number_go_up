extends Node2D

var color_values = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# I like to call this an ultra Thor move
	color_values = {
	1 : 0x6699ff,
	2 : 0xcc33ff,
	4 : 0xff0066,
	8 : 0xffff00,
	16 : 0x66ff33,
	32 : 0x00ffff,
	64 : 0x0099ff,
	128 : 0xff3300,
	256 : 0x6600cc,
	512 : 0x006600,
	1024 : 0xff33cc,
	2048 : 0x660033,
	4096 : 0xff6600,
	8192 : 0x0033cc,
	16384 : 0x333399,
	32768 : 0x669999,
	65536 : 0x009999,
	131072 : 0x33cccc,
	262144 : 0x0099ff,
	524288 : 0x339966,
	1048576 : 0x00cc99,
	2097152 : 0x00ffcc,
	4194304 : 0x3399ff,
	8388608 : 0x6600cc,
	16777216 : 0x339933,
	33554432 : 0x00cc66,
	67108864 : 0x66ccff,
	134217728 : 0x9999ff,
	268435456 : 0x9933ff,
	536870912 : 0x006600,
	1073741824 : 0xcc66ff,
	2147483648 : 0x009933,
	4294967296 : 0xff66ff,
	8589934592 : 0xcc00cc,
	17179869184 : 0x336600
	}
