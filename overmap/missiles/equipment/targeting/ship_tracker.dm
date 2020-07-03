/obj/item/missile_equipment/targeting_package/tracker
	name = "tracking targeting package"
	desc = "The NA2 'Bloodhound' is a slightly smarter set of avionics capable of tracking ships. However, it is prone to falling for decoys, and easily falls prey to enemy ECM."
	icon_state = "guidance"

	can_be_jammed = TRUE
	decoy_chance = 80
	ecm_resist = 20
	ecm_resist_chance = 10

	var/target
	var/original_target //The original target, cached incase of getting smacked by ECM.

/obj/item/missile_equipment/targeting_package/tracker/set_target(var/obj/O) //Use target ref or coords to set target, then hand over to guide_missile.
	if(istype(O, /obj/effect/overmap/visitable/ship))
		var/obj/effect/overmap/visitable/ship/S = O
		if(S.IFF_code && missile.has_iff())
			if(S.IFF_code == missile.get_iff_code())
				return

	target = O
	if(!original_target)
		original_target = O

/obj/item/missile_equipment/targeting_package/tracker/guide_missile() //If tracking, update target x and y.
	. = ..()
	var/turf/T = get_turf(target)

	if(using_own_guidance)
		for(var/obj/O in view(scan_range, src))
			if(!istype(O, overmap_target_type))
				continue
			if(O == target)
				missile.overmap_missile.target = target
				missile.overmap_missile.target_x = T.x
				missile.overmap_missile.target_y = T.y

	else
		var/obj/machinery/shipsensors/sensors

		for(var/obj/machinery/shipsensors/S in SSmachines.machinery)
			if(missile.overmap_missile.host_ship.check_ownership(S))
				sensors = S

		for(var/obj/O in view(sensors.range, missile.overmap_missile.host_ship))
			if(!istype(O, overmap_target_type))
				continue
			if(O == target)
				missile.overmap_missile.target = target
				missile.overmap_missile.target_x = T.x
				missile.overmap_missile.target_y = T.y


/obj/item/missile_equipment/targeting_package/tracker/ecm_act(var/obj/effect/overmap/O)
	return