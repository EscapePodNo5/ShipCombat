/obj/item/missile_equipment/thruster/planet
	name = "planetary missile booster"
	desc = "The standard fare missile booster, but with planetary flight capabilities."
	icon_state = "planet"

	var/turf/planetary_target
	mass = 6

/obj/item/missile_equipment/thruster/planet/is_target_valid(var/obj/effect/overmap/O)
	return istype(O, /obj/effect/overmap/visitable/sector/exoplanet)

// Immediately move the missile to the target on arrival
/obj/item/missile_equipment/thruster/planet/on_enter_level(var/z_level)
	var/obj/structure/missile/M = loc
	if(!istype(M))
		return

	if(z_level == planetary_target.z)
		// Effectively apply a small random offset from the target
		var/turf/impact_turf = planetary_target
		for(var/turf/T in shuffle(range(3, planetary_target)))
			if(!T.contains_dense_objects())
				impact_turf = T
				break

		M.forceMove(impact_turf)
		M.detonate(impact_turf)

	return null
/*
/obj/item/missile_equipment/thruster/planet/attackby(var/obj/item/I, var/mob/user)
	..()

	// If we set a target, follow up with setting a specific x/y target on the planet
	if(target && isMultitool(I))
		var/target_x = input(user, "Enter planetary target X coordinate", "Input coordinates") as null|num
		var/target_y = input(user, "Enter planetary target Y coordinate", "Input coordinates") as null|num
		if(!target_x || !target_y || target_x <= 0 || target_x >= world.maxx || target_y <= 0 || target_y >= world.maxx)
			to_chat(user, SPAN_NOTICE("The targeting computer display indicates that the target wasn't valid."))
			return

		var/obj/effect/overmap/visitable/sector/exoplanet/planet = target
		var/turf/tgt = locate(target_x, target_y, planet.map_z[planet.map_z.len])
		if(!tgt || tgt.contains_dense_objects())
			to_chat(user, SPAN_NOTICE("The targeting computer display indicates that the target wasn't valid."))
			return

		planetary_target = tgt
		to_chat(user, SPAN_NOTICE("Planetary target successfully set to [target_x]-[target_y]."))
		return
*/