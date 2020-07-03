/obj/item/missile_equipment/thruster
	name = "missile booster"
	desc = "A relatively simple but capable missile booster stage, the range is not particularly spectacular."
	icon_state = "dumbfire"

	cooldown = 5

	var/fuel = 60 // how many times can the engine do work until its out of fuel
	var/fuel_mass = 5 //Used to calculate the total mass of the missile. This is in tons
	var/thrust = 2

/obj/item/missile_equipment/thruster/do_overmap_work(var/obj/effect/overmap/projectile/P)
	if(!..() || isnull(P.target_x) || isnull(P.target_x) || !fuel)
		return 0

	var/turf/T = locate(P.target_x,P.target_y,GLOB.using_map.overmap_z)
	var/direction = get_dir(P.loc, T)
	var/speed = P.get_speed()
	var/heading = P.get_heading()
	var/did_work = FALSE

	if (speed > P.speedlimit)
		P.decelerate()
		did_work = TRUE
	// Heading does not match direction
	else if (heading & ~direction)
		P.accelerate(turn(heading & ~direction, 180), P.accellimit)
		did_work = TRUE
		// All other cases, move toward direction
	else if (speed + thrust <= P.speedlimit)
		P.accelerate(direction, P.accellimit)
		did_work = TRUE

	if(did_work)
		fuel--
	return 1

/obj/item/missile_equipment/thruster/should_enter(var/obj/effect/overmap/visitable/O)
	if(O == missile.overmap_missile.target)
		return TRUE
	return FALSE

/obj/item/missile_equipment/thruster/proc/is_target_valid(var/obj/effect/overmap/visitable/O)
	return ((O.sector_flags & OVERMAP_SECTOR_IN_SPACE) && !(O.sector_flags & OVERMAP_SECTOR_UNTARGETABLE) && LAZYLEN(O.map_z))


