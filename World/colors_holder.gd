extends Node2D

var color_values = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# I like to call this an ultra Thor move
	color_values = {
	1 : 0x993333,
	2 : 0x00ffff,
	4 : 0x003399,
	8 : 0x003366,
	16 : 0x336699,
	32 : 0x3366cc,
	64 : 0x003399,
	128 : 0x000099,
	256 : 0x0000cc,
	512 : 0x006666,
	1024 : 0x006699,
	2048 : 0x0099cc,
	4096 : 0x0066cc,
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
