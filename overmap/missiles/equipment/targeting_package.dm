/obj/item/missile_equipment/targeting_package
	name = "targeting package"
	desc = "A bog-standard targeting package, used in missiles to target ships."
	icon_state = "guidance"

	var/can_target_specifics = FALSE //Are we smart enough to pick specific things on the z-level we've entered?
	var/can_be_jammed = FALSE //Can we be jammed?
	var/jammed = FALSE //Damn you, Lonestar.

	var/ecm_resist_chance = 0 //If enemy ECM is above ECM_resist, this is the chance it will have to throw off the missile.
	var/ecm_resist = 0 //If enemy ECM strength is below this, we don't even check if we resist it.
	var/ecm_duration = 0//How long the jamming lasts, in ticks.
	var/max_ecm_duration = 200 //Otherwise the missile might be jammed literally forever.

	var/decoy_chance = 0 //The chance for a missile's tracking package to fall for a decoy.
	var/scan_range = 4 //How far the missile can 'see'. They don't use the normal sensor system, but this is a vague analogue for locating targets on the overmap.

	var/list/target_list = list() //The list of things we might target when we enter the level.
	var/obj/effect/overmap/overmap_target_type //The type of things we can target on the overmap.

	var/using_own_guidance //With how this works, since missile sensor range should always be shorter than the max sensor range of a ship, once the missile is roughly ~3 tiles away, it will switch to using it's own guidance (and scan range, accordingly.)
	var/has_RGM = FALSE //Do we have an RGM?

/obj/item/missile_equipment/targeting_package/proc/set_target() //Use target ref or coords to set target, then hand over to guide_missile.
	return

/obj/item/missile_equipment/targeting_package/proc/is_target_valid(var/O)
	if(istype(O, overmap_target_type))
		return TRUE
	else
		return FALSE

/obj/item/missile_equipment/targeting_package/proc/guide_missile() //If tracking, update target x and y.
	if((ecm_duration < world.time) && jammed)
		jammed = FALSE

	if((ecm_duration > world.time) && !jammed)
		jammed = TRUE

	if(ecm_duration) //Knock a tick off the jamming.
		ecm_duration--

	if((get_dist(missile.overmap_missile, missile.overmap_missile.host_ship) >= 3) && !has_RGM && !using_own_guidance) //Kick us off to our own guidance after three tiles.
		using_own_guidance = TRUE

/obj/item/missile_equipment/targeting_package/proc/ecm_act(var/obj/effect/overmap/O, var/ecm_strength) //Handle ECM. The base proc is just a bunch of checks to save from doing them over and over again.
	var/resisted_ecm

	if(has_RGM) //Remotely guided missiles can't be jammed.
		return

	if(!can_be_jammed)
		return

	if(ecm_strength > ecm_resist) //We only care about it being greater - not equal.

		if(prob(ecm_resist_chance))
			resisted_ecm = TRUE
		else
			resisted_ecm = FALSE

	if(resisted_ecm) //Success! We have resisted the enemy ECM.
		return

	if(!resisted_ecm)
		var/duration = rand(1,20)
		ecm_duration += duration
		ecm_duration = Clamp(ecm_duration, 0, max_ecm_duration) //Make sure we don't go past the maximum ecm duration.

	//From this point on, this is left up to the individual targeting packages on how to handle getting jammed.


/obj/item/missile_equipment/targeting_package/on_enter_level(var/z_level)
	if(!can_target_specifics)
		return

	if(!LAZYLEN(target_list)) //Target list is null or empty, return.
		return

	var/target_type = pick(target_list)

	var/list/things_on_z_level = block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level))

	for(var/T in things_on_z_level) //Iterate over the list entirely, remove anything that is NOT what we are going after.
		if(!istype(T, target_type))
			things_on_z_level -= T

	var/obj/final_target = pick(things_on_z_level) //Finally, pick from all the things we found

	var/list/target_coords = list(final_target.x, final_target.y)

	return target_coords



