// Takes in coordinates and flies to said coordinates (although very slowly, so the range isn't great)
/obj/item/missile_equipment/thruster/point
	name = "pointman missile booster"
	desc = "A missile booster designed to travel to and rest at a given point. Steers away from structures."
	icon_state = "dumbfire"
	mass = 2

/obj/item/missile_equipment/thruster/point/attackby(var/obj/item/I, var/mob/user)
	var/target_x = 0
	var/target_y = 0

	if(isMultitool(I))
		target_x = input(user, "Enter target X coordinate", "Input coordinates") as null|num
		target_y = input(user, "Enter target Y coordinate", "Input coordinates") as null|num
	if(!target_x || !target_y || target_x <= 0 || target_x >= GLOB.using_map.overmap_size || target_y <= 0 || target_y >= GLOB.using_map.overmap_size)
		to_chat(user, SPAN_NOTICE("The targeting computer display lets you know that's an invalid target."))
		return

	var/turf/tgt = locate(target_x, target_y, GLOB.using_map.overmap_z)
	if(!tgt)
		to_chat(user, SPAN_NOTICE("The targeting computer display indicates that the target wasn't valid."))
		return

	target = tgt
	to_chat(user, SPAN_NOTICE("Target successfully set to [target]."))
	return

	..()