/obj/effect/overmap/projectile
	name = "projectile"
	icon_state = "projectile"
	icon = 'mods/ship_combat2/icons/overmap.dmi'
	movement_handler_type = /datum/extension/overmap_movement/ship

	var/sector_flags = OVERMAP_SECTOR_KNOWN // technically in space, but you can't visit the missile during its flight

	var/obj/structure/missile/actual_missile = null
	var/obj/effect/overmap/visitable/host_ship = null

	var/walking = FALSE // walking towards something on the overmap?
	var/moving = FALSE // is the missile moving on the overmap?
	var/dangerous = FALSE
	var/should_enter_zs = FALSE

	requires_contact = TRUE
	instant_contact  = TRUE

	var/target_x
	var/target_y
	var/obj/effect/overmap/target

	var/speedlimit = 5
	var/accellimit = 5

	var/launch_time //the time we were launched.
	var/self_destruct_time //If we haven't hit our target after x amount of time after launch, self destruct to avoid cluttering overmap.
	var/self_destruct_delay = 5 MINUTES

/obj/effect/overmap/projectile/Initialize(var/maploading, var/start_turf)
	. = ..()
	forceMove(start_turf)
	START_PROCESSING(SSobj, src)
	launch_time = world.time
	self_destruct_time = world.time + self_destruct_delay

/obj/effect/overmap/projectile/Destroy()
	if(!QDELETED(actual_missile))
		QDEL_NULL(actual_missile)
	actual_missile = null

	. = ..()

/obj/effect/overmap/projectile/proc/set_missile(var/obj/structure/missile/missile)
	actual_missile = missile

/obj/effect/overmap/projectile/proc/set_dangerous(var/is_dangerous)
	dangerous = is_dangerous

/obj/effect/overmap/projectile/proc/set_moving(var/is_moving)
	moving = is_moving

/obj/effect/overmap/projectile/proc/set_enter_zs(var/enter_zs)
	should_enter_zs = enter_zs

/obj/effect/overmap/projectile/get_scan_data(mob/user)
	. = ..()
	. += "<br>General purpose projectile frame"
	. += "<br>Additional information:<br>[get_additional_info()]"

/obj/effect/overmap/projectile/proc/get_additional_info()
	if(actual_missile)
		return actual_missile.get_additional_info()
	return "N/A"

/obj/effect/overmap/projectile/proc/move_to(var/datum/target, var/min_speed, var/speed)
	if(isnull(target) || !speed)
		walk(src, 0)
		walking = FALSE
		update_icon()
		return

	walk_towards(src, target, min_speed - speed)
	walking = TRUE
	update_icon()

/obj/effect/overmap/projectile/Process()
	// Whether overmap movement occurs is controlled by the missile itself
	if(QDELETED(src))
		return

	if(!moving)
		return

	check_enter()

	// let equipment alter speed/course
	for(var/obj/item/missile_equipment/E in actual_missile.equipment)
		E.do_overmap_work(src)

	for(var/obj/item/missile_equipment/targeting_package/T in actual_missile.equipment)
		T.guide_missile()

	if(movement)
		movement.do_overmap_movement()

	if(world.time > self_destruct_time)
		qdel(src)

	update_icon()

// Checks if the missile should enter the z level of an overmap object
/obj/effect/overmap/projectile/proc/check_enter()
	if(!should_enter_zs)
		return

	var/list/potential_levels
	var/turf/T = get_turf(src)
	for(var/obj/effect/overmap/visitable/O in T)
		if(!LAZYLEN(O.map_z))
			continue

		LAZYINITLIST(potential_levels)
		potential_levels[O] = 0

		// Missile equipment "votes" on what to enter
		for(var/obj/item/missile_equipment/E in actual_missile.equipment)
			if(E.should_enter(O))
				potential_levels[O]++

	// Nothing to enter
	if(!LAZYLEN(potential_levels))
		return

	var/total_votes = 0
	for(var/O in potential_levels)
		total_votes += potential_levels[O]

	// Default behavior, just enter the first thing in space we encounter
	if(!total_votes)
		// Must be in motion for this to happen
		if(!walking)
			return

		for(var/obj/effect/overmap/visitable/O in potential_levels)
			if((O.sector_flags & OVERMAP_SECTOR_IN_SPACE))
				actual_missile.enter_level(pick(O.map_z))
	else // Enter the thing with most "votes"
		var/obj/effect/overmap/visitable/winner = pick(potential_levels)
		for(var/O in potential_levels)
			if(potential_levels[O] > potential_levels[winner])
				winner = O
		actual_missile.enter_level(pick(winner.map_z))

/obj/effect/overmap/projectile/on_update_icon()
	if(movement)
		movement.handle_pixel_movement()
	icon_state = "projectile"
	if(!is_still())
		icon_state += "_moving"

	if(dangerous)
		icon_state += "_danger"
	set_dir(get_heading())

/obj/effect/overmap/projectile/get_vessel_mass()
	var/total_mass
	total_mass += actual_missile.frame_mass
	for(var/obj/item/missile_equipment/E in actual_missile.equipment)
		total_mass += E.mass
	return total_mass

/obj/effect/overmap/projectile/proc/recalc_mass()
	vessel_mass = get_vessel_mass()

/obj/effect/overmap/projectile/proc/get_thrust()
	var/thrust
	for(var/obj/item/missile_equipment/E in actual_missile.equipment)
		if(istype(E, /obj/item/missile_equipment/thruster))
			var/obj/item/missile_equipment/thruster/T = E
			thrust = T.thrust
	return thrust

/obj/effect/overmap/projectile/get_delta_v()
	var/thrust = get_thrust()
	var/vessel_mass = get_vessel_mass()
	// special note here
	// get_instant_wet_mass() returns kg
	// vessel_mass is in metric tonnes
	// This is not a correct rocket equation, but it's what is balanced for the game and
	// is intentional.
	var/raw_delta_v = (thrust / GRAVITY_CONSTANT) * log((get_specific_wet_mass() + vessel_mass) / vessel_mass)
	return round(raw_delta_v, SHIP_MOVE_RESOLUTION)

// This is the amount of fuel we can spend in one specific impulse.
/obj/effect/overmap/projectile/get_specific_wet_mass()
	var/mass
	for(var/obj/item/missile_equipment/E in actual_missile.equipment)
		if(istype(E, /obj/item/missile_equipment/thruster))
			var/obj/item/missile_equipment/thruster/T = E
			mass = T.fuel
	return mass
