/proc/tomatogibs(turf/T, viral_list, list/ejectables, bdna, btype)
	var/PT = /obj/item/reagent_containers/food/snacks/plant/tomato

	var/list/dirlist = list(list(NORTH, NORTHEAST, NORTHWEST), \
		                    list(SOUTH, SOUTHEAST, SOUTHWEST), \
		                    list(WEST, NORTHWEST, SOUTHWEST),  \
		                    list(EAST, NORTHEAST, SOUTHEAST))

	var/list/produce = list()

	for (var/i = 1, i <= 4, i++)
		var/obj/item/reagent_containers/food/snacks/plant/P = new PT(T)
		P.streak(dirlist[i])
		produce += P

	var/extra = rand(2,4)
	for (var/i = 1, i <= extra, i++)
		var/obj/item/reagent_containers/food/snacks/plant/P = new PT(T)
		P.streak(alldirs)
		produce += P

	return produce


/mob/living/critter/killertomato
	name = "killer tomato"
	real_name = "killer tomato"
	desc = "Today, Space Station 13 - tomorrow, THE WORLD!"
	density = 1
	icon_state = "ktomato"
	custom_gib_handler = /proc/tomatogibs
	hand_count = 1
	can_throw = 0
	blood_id = "juice_tomato"

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/voice/MEraaargh.ogg", 70, 1)
					return "<strong><span style='color:red'>[src] roars!</span></strong>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	setup_hands()
		..()
		var/handHolder/HH = hands[1]
		HH.name = "mouth"					// designation of the hand - purely for show
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"				// the icon state of the hand UI background
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.limb = new /limb/mouth		// if not null, the special limb to use when attack_handing
		HH.can_hold_items = 0

	New()
		..()
		abilityHolder.addAbility(/targetable/critter/slam)
		abilityHolder.addAbility(/targetable/critter/bite)

	death(var/gibbed)
		if (!gibbed)
			playsound(loc, "sound/effects/splat.ogg", 100, 1)
			var/obj/decal/cleanable/blood/B = new(loc)
			B.name = "ruined tomato"
			ghostize()
			qdel(src)
		else
			..()

	setup_healths()
		add_hh_flesh(-25, 25, 1)
		add_hh_flesh_burn(-25, 25, 1.25)
		add_health_holder(/healthHolder/toxin)
