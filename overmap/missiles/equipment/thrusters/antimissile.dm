/obj/item/missile_equipment/thruster/hunter
	name = "HUNTER warp booster"
	desc = "An advanced booster specifically designed to plot courses towards and catch up to rapidly moving objects such as other missiles."
	icon_state = "seeker"

	fuel = 40
	mass = 4

/obj/item/missile_equipment/thruster/hunter/is_target_valid(var/obj/effect/overmap/O)
	return istype(O, /obj/effect/overmap/projectile)



