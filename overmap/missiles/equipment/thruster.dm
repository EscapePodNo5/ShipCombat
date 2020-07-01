/obj/item/missile_equipment/thruster
	name = "missile booster"
	desc = "A simple but powerful and modular booster that can be fitted in most missiles. This one comes with an embedded targeting computer."
	icon_state = "target"

	cooldown = 5

	var/atom/target
	var/fuel = 60 // how many times can the engine do work until its out of fuel
	var/max_fuel = 100
	var/fuel_mass = 5 //Used to calculate the total mass of the missile. This is in tons
	var/thrust = 10

/obj/item/missile_equipment/thruster/do_overmap_work(var/obj/effect/overmap/projectile/P)
	if(!..() || isnull(P.target_x) || isnull(P.target_x) || !fuel)
		return 0

	var/turf/T = locate(P.target_x,P.target_y,GLOB.using_map.overmap_z)
	var/direction = get_dir(P.loc, T)
	var/speed = P.get_speed()
	var/heading = P.get_heading()

	world << "[T]"
	world << "[speed]"
	world << "[heading]"
	world << "[direction]"
	if (speed > P.speedlimit)
		world << "braking"
		P.decelerate()
	// Heading does not match direction
	else if (heading & ~direction)
		P.accelerate(turn(heading & ~direction, 180), P.accellimit)
		world << "gotta go fast to get to class"
		// All other cases, move toward direction
	else if (speed + thrust <= P.speedlimit)
		P.accelerate(direction, P.accellimit)
		world << "gotta go fast but in a straight line"

	fuel--
	return 1

/obj/item/missile_equipment/thruster/should_enter(var/obj/effect/overmap/visitable/O)
	if(O == target)
		return TRUE
	return FALSE

/obj/item/missile_equipment/thruster/proc/is_target_valid(var/obj/effect/overmap/visitable/O)
	return ((O.sector_flags & OVERMAP_SECTOR_IN_SPACE) && !(O.sector_flags & OVERMAP_SECTOR_UNTARGETABLE) && LAZYLEN(O.map_z))


