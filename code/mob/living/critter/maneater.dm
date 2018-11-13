/proc/vegetablegibs(turf/T, viral_list, list/ejectables, bdna, btype)
	var/list/vegetables = list(/obj/item/reagent_containers/food/snacks/plant/soylent, \
		                       /obj/item/reagent_containers/food/snacks/plant/lettuce, \
		                       /obj/item/reagent_containers/food/snacks/plant/cucumber, \
		                       /obj/item/reagent_containers/food/snacks/plant/carrot, \
		                       /obj/item/reagent_containers/food/snacks/plant/slurryfruit)

	var/list/dirlist = list(list(NORTH, NORTHEAST, NORTHWEST), \
		                    list(SOUTH, SOUTHEAST, SOUTHWEST), \
		                    list(WEST, NORTHWEST, SOUTHWEST),  \
		                    list(EAST, NORTHEAST, SOUTHEAST))

	var/list/produce = list()

	for (var/i = 1, i <= 4, i++)
		var/PT = pick(vegetables)
		var/obj/item/reagent_containers/food/snacks/plant/P = new PT(T)
		P.streak(dirlist[i])
		produce += P

	var/extra = rand(2,4)
	for (var/i = 1, i <= extra, i++)
		var/PT = pick(vegetables)
		var/obj/item/reagent_containers/food/snacks/plant/P = new PT(T)
		P.streak(alldirs)
		produce += P

	return produce

/mob/living/critter/maneater
	name = "man-eating plant"
	real_name = "man-eating plant"
	desc = "It looks hungry..."
	density = 1
	icon_state = "maneater"
	icon_state_dead = "maneater-dead"
	custom_gib_handler = /proc/vegetablegibs
	blood_id = "poo"
	hand_count = 2
	can_throw = 1
	can_grab = 1
	can_disarm = 1

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

	setup_equipment_slots()
		equipment += new /equipmentHolder/ears(src)
		equipment += new /equipmentHolder/head(src)

	setup_hands()
		..()
		var/handHolder/HH = hands[1]
		HH.name = "tentacles"
		HH = hands[2]
		HH.name = "mouth"					// designation of the hand - purely for show
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"				// the icon state of the hand UI background
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.limb = new /limb/mouth		// if not null, the special limb to use when attack_handing
		HH.can_hold_items = 0

	New()
		..()
		abilityHolder.addAbility(/targetable/critter/slam)
		abilityHolder.addAbility(/targetable/critter/devour)

	setup_healths()
		add_hh_flesh(-50, 50, 1)
		add_hh_flesh_burn(-50, 50, 1.25)
		add_health_holder(/healthHolder/toxin)
