/obj/item/missile_equipment/remote_guidance_module
	name = "remote guidance module"
	desc = "A long range, advanced sensor link directly to the host ship's sensors. This means the missile it's mounted on doesn't have to use it's onboard scanners and is thusly immune to jamming."
	icon_state = "equipment"

/obj/item/missile_equipment/remote_guidance_module/on_install()
	for(var/obj/item/missile_equipment/E in missile.equipment)
		if(istype(E, /obj/item/missile_equipment/targeting_package))
			var/obj/item/missile_equipment/targeting_package/G = E
			G.has_RGM = TRUE