/mob/living/critter/wendigo
	name = "wendigo"
	real_name = "wendigo"
	desc = "Oh god."
	density = 1
	icon_state = "wendigo"
	icon_state_dead = "wendigo-dead"
	custom_gib_handler = /proc/gibs
	hand_count = 2
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	blood_id = "beff"
	burning_suffix = "humanoid"

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (emote_check(voluntary, 50))
					playsound(get_turf(src), "sound/misc/wendigo_roar.ogg", 80, 1)
					return "<strong><span style='color:red'>[src] howls!</span></strong>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	setup_equipment_slots()
		equipment += new /equipmentHolder/suit(src)
		equipment += new /equipmentHolder/ears(src)
		equipment += new /equipmentHolder/head(src)

	setup_hands()
		..()
		var/handHolder/HH = hands[1]
		HH.limb = new /limb/wendigo
		HH.icon_state = "handl"				// the icon state of the hand UI background
		HH.limb_name = "left wendigo arm"

		HH = hands[2]
		HH.limb = new /limb/wendigo
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"				// the icon state of the hand UI background
		HH.limb_name = "right wendigo arm"

	New()
		..()
		abilityHolder.addAbility(/targetable/critter/fadeout/wendigo)
		abilityHolder.addAbility(/targetable/critter/tackle)
		abilityHolder.addAbility(/targetable/critter/frenzy)

	setup_healths()
		add_hh_flesh(-100, 100, 0.85)
		add_hh_flesh_burn(-100, 100, 1.4)
		add_health_holder(/healthHolder/toxin)
		add_health_holder(/healthHolder/brain)
