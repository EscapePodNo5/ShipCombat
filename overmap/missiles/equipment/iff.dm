/obj/item/missile_equipment/iff
	name = "IFF module"
	desc = "A simple challenge-response transponder to identify missiles - and for missiles to identify ships with. Remember, do not leave sticky notes with your IFF codes laying around."
	icon_state = "iff"
	var/random_iff = FALSE
	var/iff_code //Null initially, just to prevent fuckery - assuming players haven't set the ship's IFF. If they have, well. PDCs will try to shoot down their own missiles.

/obj/item/missile_equipment/iff/examine(mob/user)
	. = ..()
	if(iff_code)
		to_chat(user, SPAN_NOTICE("A small display on the side of [src] with the text 'IFF CODE' above it reads: [iff_code]."))

/obj/item/missile_equipment/iff/Initialize()
	. = ..()
	if(random_iff)
		var/length = rand(0,14)
		randomize_IFF(length)

/obj/item/missile_equipment/iff/proc/randomize_IFF(var/length)
	iff_code = generate_iff(length)
