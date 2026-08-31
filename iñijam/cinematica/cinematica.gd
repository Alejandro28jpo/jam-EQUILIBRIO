extends Node2D

func _ready() -> void:
	await get_tree().create_timer(3.0).timeout
	$AnimationPlayer.play("comienzo")
	await get_tree().create_timer(2.9).timeout
	$UQ2Hb2391VbThunderClap521194.play()
	$ExplosionBlastFireHeavyCrackle01.play()
	$AmbienceNatureTrail18001.stop()
	await get_tree().create_timer(3.5).timeout
	$UniversfieldManPainScream567203.play()
	await get_tree().create_timer(2.5).timeout
	$UQ2Hb2391VbThunderClap521194.stop()
	$ExplosionBlastFireHeavyCrackle01.stop()
	await get_tree().create_timer(0.8).timeout
	$BryansantosbretonDarknessTonalCymbalRollRiserBraamImpact184275.play()
	

# Called when the node enters the scene tree for the first time.
func _inicio():
	get_tree().change_scene_to_file("uid://b4t2us54hecpu")
