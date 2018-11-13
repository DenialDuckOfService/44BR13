/obj/storage/crate/loot
	name = "crate"
	desc = "A crate of unknown contents, probably accidentally lost from some bygone freighter shipment or the like."
	icon_state = "crate"
	icon_opened = "crateopen"
	icon_closed = "crate"
	locked = 1
	var/tier = 1
	var/image/light = null
	var/image/stripes = null
	var/loot_crate_lock/lock = null
	var/loot_crate_trap/trap = null

	New()
		..()
		light = image('icons/obj/crate.dmi',"lootcratelocklight")
		stripes = image('icons/obj/crate.dmi',"lootcratestripes")

		tier = RarityClassRoll(100,0,list(95,70))
		var/kind = rand(1,5)
		// kinds: (1) Civilian (2) Scientific (3) Industrial (4) Military (5) Criminal

		var/list/items = list()
		var/list/item_amounts = list()
		var/picker = 0

		switch(kind)
			if (2)
				name = "research shipment crate"
				desc = "There are laboratory and research company logos on the crate."
				icon_state = "lootsci"
				icon_opened = "lootsciopen"
				icon_closed = "lootsci"

				// SCIENCE GOODS LOOT TABLE
				if (tier == 3)
					picker = rand(1,2)
					switch(picker)
						if (1)
							items += /obj/item/clothing/gloves/psylink_bracelet
							item_amounts += 1
						else
							items += /obj/item/device/voltron
							item_amounts += 1
				else if (tier == 2)
					picker = rand(1,1)
					switch(picker)
						if (1)
							items += pick(/obj/critter/bear)
							item_amounts += 1
				else
					picker = rand(1,3)
					switch(picker)
						if (1)
							items += /obj/item/roboupgrade/efficiency
							item_amounts += 1
							items += /obj/item/roboupgrade/jetpack
							item_amounts += 1
							picker = rand(1,4)
							items += pick(/obj/item/roboupgrade/physshield,/obj/item/roboupgrade/teleport,/*
							/obj/item/roboupgrade/opticthermal,*//obj/item/roboupgrade/speed)
							item_amounts += 1
						if (2)
							items += /obj/item/reagent_containers/glass/beaker/large/antitox
							item_amounts += 1
							items += /obj/item/reagent_containers/glass/beaker/large/brute
							item_amounts += 1
							items += /obj/item/reagent_containers/glass/beaker/large/burn
							item_amounts += 1
							items += /obj/item/reagent_containers/glass/beaker/large/epinephrine
							item_amounts += 1
							items += /obj/item/reagent_containers/hypospray
							item_amounts += 1
						if (3)
							items += pick(/obj/critter/spore)
							item_amounts += 3

			if (3)
				name = "industrial shipment crate"
				desc = "There are industrial company logos on the crate."
				icon_state = "lootind"
				icon_opened = "lootindopen"
				icon_closed = "lootind"

				// INDUSTRIAL GOODS LOOT TABLE
				if (tier == 3)
					items += /obj/item/device/voltron
					item_amounts += 1
				else if (tier == 2)
					picker = rand(1,1)
					switch(picker)
						if (1)
							items += pick(/obj/item/raw_material/telecrystal,/obj/item/raw_material/gemstone,
							/obj/item/raw_material/miracle,/obj/item/raw_material/uqill)
							item_amounts += 30
				else
					picker = rand(1,5)
					switch(picker)
						if (1)
							items += /obj/item/breaching_charge/mining
							item_amounts += 25
						if (2)
							items += /obj/item/clothing/gloves/concussive
							item_amounts += 1
							items += /obj/item/clothing/shoes/industrial
							item_amounts += 1
						if (3)
							items += /obj/item/clothing/head/helmet/space/industrial
							item_amounts += 1
							items += /obj/item/clothing/suit/space/industrial
							item_amounts += 1
						if (4)
							items += pick(/obj/item/raw_material/telecrystal,/obj/item/raw_material/gemstone,
							/obj/item/raw_material/miracle,/obj/item/raw_material/uqill)
							item_amounts += 10
						if (5)
							items += pick(/obj/item/raw_material/syreline,/obj/item/raw_material/bohrum,
							/obj/item/raw_material/claretine,/obj/item/raw_material/cerenkite)
							item_amounts += 40

			if (4)
				name = "military shipment crate"
				desc = "The crate is covered in military insignia."
				icon_state = "lootmil"
				icon_opened = "lootmilopen"
				icon_closed = "lootmil"

				// MILITARY GOODS LOOT TABLE
				if (tier == 3)
					items += /obj/item/device/voltron
					item_amounts += 1
				else if (tier == 2)
					picker = rand(1,10)
					switch(picker)
						if (1)
							items += pick(/obj/item/gun/energy/teleport,/obj/item/gun/energy/laser_gun/pred)
							item_amounts += 1
						if (2 to 6)
							items += /obj/item/gun/energy/phaser_gun
							item_amounts += 1
						if (7 to 10)
							for (var/i = 1, i < rand(4,10), i++)
								items += pick(/obj/item/chem_grenade/incendiary, /obj/item/chem_grenade/cryo, /obj/item/chem_grenade/shock, /obj/item/chem_grenade/pepper, prob(10); /obj/item/chem_grenade/sarin)
								item_amounts += 1
				else
					picker = rand(1,1)
					switch(picker)
						if (1)
							items += /obj/item/reagent_containers/glass/beaker/large/antitox
							item_amounts += 1
							items += /obj/item/reagent_containers/glass/beaker/large/brute
							item_amounts += 1
							items += /obj/item/reagent_containers/glass/beaker/large/burn
							item_amounts += 1
							items += /obj/item/reagent_containers/glass/beaker/large/epinephrine
							item_amounts += 1
							items += /obj/item/reagent_containers/hypospray
							item_amounts += 1

			if (5)
				name = "unmarked shipment crate"
				desc = "This crate seems to have all identifications scratched off."
				icon_state = "lootcrime"
				icon_opened = "lootcrimeopen"
				icon_closed = "lootcrime"

				// CRIMINAL GOODS LOOT TABLE
				if (tier == 3)
					items += /obj/item/device/voltron
					item_amounts += 1
				else if (tier == 2)
					picker = rand(1,3)
					switch(picker)
						if (1)
							items += /obj/item/spacecash/thousand
							item_amounts += 20
						if (2)
							items += /obj/item/material_piece/gold
							item_amounts += 5
						if (3)
							items += /obj/item/plant/herb/cannabis/omega/spawnable
							item_amounts += 10
				else
					picker = rand(1,4)
					switch(picker)
						if (1)
							items += /obj/item/spacecash/thousand
							item_amounts += 5
						if (2)
							items += /obj/item/reagent_containers/food/drinks/bottle/hobo_wine
							item_amounts += 5
						if (3)
							items += /obj/item/material_piece/gold
							item_amounts += 1
						if (4)
							items += pick(/obj/item/plant/herb/cannabis/spawnable,
							/obj/item/plant/herb/cannabis/white/spawnable,
							/obj/item/plant/herb/cannabis/mega/spawnable)
							item_amounts += 10

			else
				name = "goods shipment crate"
				desc = "There are consumer goods company logos on the crate."

				// CIVILIAN GOODS LOOT TABLE
				if (tier == 3)
					items += /obj/item/device/voltron
					item_amounts += 1
				else if (tier == 2)
					picker = rand(1,1)
					switch(picker)
						if (1)
							items += /obj/item/reagent_containers/food/snacks/plant/tomato/explosive
							item_amounts += 5
				else
					picker = rand(1,2)
					switch(picker)
						if (1)
							items += /obj/item/clothing/shoes/moon
							item_amounts += 1
						if (2)
							items += /obj/item/reagent_containers/food/drinks/bottle/hobo_wine
							item_amounts += 5
						if (3)
							items += pick(/obj/item/reagent_containers/food/snacks/burrito,
							/obj/item/reagent_containers/food/snacks/snack_cake,
							/obj/item/reagent_containers/food/snacks/snack_cake/golden,
							/obj/item/reagent_containers/food/snacks/plant/lashberry,
							/obj/item/reagent_containers/food/snacks/plant/tomato)
							item_amounts += 5
						if (4)
							items += /obj/critter/cat
							item_amounts += 1

		var/trap_prob = 100
		var/newlock = null
		var/newtrap = null
		switch(tier)
			if (2)
				newlock = pick(/loot_crate_lock/decacode,/loot_crate_lock/hangman/seven)
				newtrap = pick(/loot_crate_trap/crusher,/loot_crate_trap/spikes,/loot_crate_trap/zap)
				name = "fortified " + name
				desc += " It's pretty heavily secured, too."
			if (3)
				newlock = pick(/loot_crate_lock/hangman/nine)
				newtrap = pick(/loot_crate_trap/bomb,/loot_crate_trap/zap)
				name = "heavily reinforced " + name
				desc += " It's also got more security measures on it than Fort Knox."
			else
				trap_prob = 33
				newlock = pick(/loot_crate_lock/decacode,/loot_crate_lock/hangman)
				newtrap = pick(/loot_crate_trap/crusher,/loot_crate_trap/spikes)

		if (ispath(newlock))
			var/loot_crate_lock/L = new newlock
			L.holder = src
			lock = L
		if (ispath(newtrap) && prob(trap_prob))
			var/loot_crate_trap/T = new newtrap
			T.holder = src
			trap = T

		var/list_counter = 1
		var/temp_counter = 0
		for (var/X in items)
			temp_counter = item_amounts[list_counter]
			while (temp_counter > 0)
				temp_counter--
				new X(src)
			list_counter++

		spawn (0)
			update_icon()

		return

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (istype(trap))
			if (E)
				boutput(user, "<span style=\"color:red\">The crate's anti-tamper system immediately activates in response to [E]! Fuck!</span>")
			else
				visible_message("<span style=\"color:red\">Something sets off [src]'s anti-tamper system!</span>")
			trap.trigger_trap(user)
		else
			..()
		return

	attack_hand(mob/user as mob)
		if (istype(lock) && locked)
			var/success_state = lock.attempt_to_open(user)
			if (success_state == 1) // Succeeded
				boutput(user, "<span style=\"color:blue\">The crate unlocks!</span>")
				locked = 0
				lock = null
				trap = null
				update_icon()
			else if (success_state == 0) // Failed
				lock.fail_attempt(user)
			// Call -1 or something for cancelled attempts
		else
			return ..()

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/device/multitool) && locked)
			if (istype(lock))
				lock.read_device(user)
			if (istype(trap))
				trap.read_device(user)
		else if (istype(W, /obj/item/weldingtool))
			var/obj/item/weldingtool/WELD = W
			if (WELD.welding)
				boutput(user, "<span style=\"color:red\">The crate seems to be resistant to welding.</span>")
				return
			else
				..()
		else
			..()
		return

	update_icon()
		if (open) icon_state = icon_opened
		else icon_state = icon_closed
		overlays = null

		if (locked)
			light.color = "#FF0000"
		else
			light.color = "#00FF00"
		overlays += light

		switch(tier)
			if (2)
				stripes.color = "#EBEB00"
			if (3)
				stripes.color = "#C00000"
			else
				stripes.color = "#00C000"
		overlays += stripes

// LOCKS

/loot_crate_lock
	var/obj/storage/crate/loot/holder = null
	var/attempts_allowed = 0
	var/attempts_remaining = 0

	New()
		scramble_code()

	proc/attempt_to_open(var/mob/living/opener)
		// return TRUE for success, 0 for failiure, anything else for cancelled attempt
		// Otherwise the trap will go off if you reconsider too many times and that'd be Very Rude
		return -1

	proc/fail_attempt(var/mob/living/opener)
		boutput(opener, "<span style=\"color:red\">A red light flashes.</span>")
		attempts_remaining--
		if (attempts_remaining <= 0)
			boutput(opener, "<span style=\"color:red\">The crate's anti-tamper system activates!</span>")
			if (holder && holder.trap)
				holder.trap.trigger_trap(opener)
				if (!holder.trap.destroys_crate)
					scramble_code()
					boutput(opener, "<span style=\"color:red\">Looks like the code changed, too. You'll have to start again.</span>")
			else
				scramble_code()
				boutput(opener, "<span style=\"color:red\">Looks like the code changed. You'll have to start again.</span>")
			return

	proc/inputter_check(var/mob/living/opener)
		if (get_dist(holder.loc,opener.loc) > 2 && !opener.bioHolder.HasEffect("telekinesis"))
			boutput(opener, "You try really hard to press the button all the way over there. Using your mind. Way to go, champ!")
			return FALSE

		if (!istype(opener.loc,/turf) && !opener.bioHolder.HasEffect("telekinesis"))
			boutput(opener, "You can't press the button from inside there, you doofus!")
			return FALSE

		return TRUE

	proc/read_device(var/mob/living/reader)
		return

	proc/scramble_code()
		return

/loot_crate_lock/decacode
	attempts_allowed = 3
	var/code = null
	var/lastattempt = null

	attempt_to_open(var/mob/living/opener)
		boutput(opener, "<span style=\"color:blue\">The crate is locked with a deca-code lock.</span>")
		var/input = input(usr, "Enter digit from 1 to 10.", "Deca-Code Lock") as null|num
		if (input < 1 || input > 10)
			boutput(opener, "You leave the crate alone.")
			return -1

		if (!inputter_check(opener))
			return

		lastattempt = input

		if (input == code)
			return TRUE
		else
			return FALSE

	read_device(var/mob/living/reader)
		boutput(reader, "<strong>DECA-CODE LOCK REPORT:</strong>")
		if (attempts_allowed == 1)
			boutput(reader, "<span style=\"color:red\">* Anti-tamper system will activate on next failed access attempt.</span>")
		else
			boutput(reader, "* Anti-tamper system will activate after [attempts_remaining] failed access attempts.")

		if (lastattempt == null)
			boutput(reader, "* No attempt has been made to open the crate thus far.")
			return

		if (code > lastattempt)
			boutput(reader, "* Last access attempt lower than expected code.")
		else
			boutput(reader, "* Last access attempt higher than expected code.")

	scramble_code()
		code = rand(1,10)
		attempts_remaining = attempts_allowed
		lastattempt = null

/loot_crate_lock/hangman
	attempts_allowed = 8
	var/code = null
	var/revealed_code = "*****"
	var/code_pool = "five"

	seven
		attempts_allowed = 8
		revealed_code = "*******"
		code_pool = "seven"

	nine
		attempts_allowed = 8
		revealed_code = "*********"
		code_pool = "nine"

	attempt_to_open(var/mob/living/opener)
		boutput(opener, "<span style=\"color:blue\">The crate is locked with a password lock. You'll need a multitool to get very far here.</span>")
		var/input = input(usr, "Enter one letter to reveal part of the password, or attempt to guess the password.", "Password Lock") as null|text
		input = lowertext(input)

		if (!istext(input) || length(input) < 1)
			boutput(opener, "You leave the crate alone.")
			return -1

		if (!inputter_check(opener))
			return

		if (length(input) == 1)
			if (attempts_remaining <= 1)
				boutput(opener, "<span style=\"color:red\">Trying to reveal any more of the password would set off the anti-tamper system. You'll have to make a guess.</span>")
				return -1

			var/chars_found = 0
			var/loops = length(code)

			for (var/i = 1, i <= loops, i++)
				if (chs(code, i) == input)
					chars_found++
					revealed_code = copytext(revealed_code,1,i) + input + copytext(revealed_code,i+1)

			if (chars_found)
				boutput(opener, "Found [input] in password.")
			else
				boutput(opener, "Did not find [input] in password.")
				attempts_remaining--

			return -1
		else
			if (input == code)
				return TRUE
			else
				return FALSE

	read_device(var/mob/living/reader)
		boutput(reader, "<strong>PASSWORD LOCK REPORT:</strong>")
		boutput(reader, "All passwords are fully lower-case and feature no non-alphabetical characters.")
		if (attempts_allowed == 1)
			boutput(reader, "<span style=\"color:red\">* Anti-tamper system will activate on next failed access attempt.</span>")
		else
			boutput(reader, "* Anti-tamper system will activate after [attempts_remaining] failed access attempts.")

		boutput(reader, "* Characters known: [revealed_code]")
		return

	scramble_code()
		code = pick(strings("password_pool.txt", code_pool))
		attempts_remaining = attempts_allowed
		revealed_code = initial(revealed_code)

// TRAPS

/loot_crate_trap
	var/obj/storage/crate/loot/holder = null
	var/destroys_crate = 0
	var/desc = null

	proc/trigger_trap(var/mob/living/opener)
		return TRUE

	proc/read_device(var/mob/living/reader)
		if (istext(desc))
			boutput(reader, "[desc]")
		return

/loot_crate_trap/bomb
	destroys_crate = 1
	desc = "Security Measure Installed: Officer Dan's Anti-Tamper Bomb System Mk 1.4"
	var/list/bomb_yields = list(-1,-1,1,1)

	trigger_trap(var/mob/living/opener)
		if (..())
			return

		var/turf/T = get_turf(holder)
		holder.visible_message("<strong>[holder] beeps, \"Thank you for triggering Officer Dan's Anti-Tamper Bomb system. Have a nice day.\"")
		explosion(holder, T,bomb_yields[1],bomb_yields[2],bomb_yields[3],bomb_yields[4])
		qdel(holder)
		return

	read_device(var/mob/living/reader)

/loot_crate_trap/spikes
	desc = "Security Measure Installed: Robust Solutions Inc. Anti-Thief Sublethal Skewer System"
	var/damage = 20

	trigger_trap(var/mob/living/opener)
		holder.visible_message("<span style=\"color:red\"><strong>Spikes shoot out of [holder]!</strong></span>")
		if (opener)
			random_brute_damage(opener,damage,1)
			playsound(opener.loc, "sound/effects/bloody_stab.ogg", 60, 1)
		return

/loot_crate_trap/zap
	desc = "Security Measure Installed: Robust Solutions Inc. Anti-Thief Electric Shock System"
	var/wattage = 17500

	trigger_trap(var/mob/living/opener)
		if (opener)
			opener.shock(holder,wattage,1,1)
		return

/loot_crate_trap/crusher
	desc = "Security Measure Installed: Dyna*Corp Contingency Crate Grinder System"
	destroys_crate = 1

	trigger_trap(var/mob/living/opener)
		holder.visible_message("<span style=\"color:red\">A loud grinding sound comes from inside [holder] as it unlocks!</span>")
		playsound(holder.loc, "sound/machines/engine_grump1.ogg", 60, 1)

		for (var/obj/I in holder.contents)
			if (istype(I,/obj/critter/cat))
				continue // absolutely fucking not >=I
			new /obj/item/scrap(holder)
			qdel(I)

		holder.locked = 0
		holder.lock = null
		holder.trap = null
		holder.update_icon()
		return

// Items specific to loot crates

/obj/item/clothing/gloves/psylink_bracelet
	name = "jewelled bracelet"
	desc = "Some pretty jewellery."
	icon = 'icons/obj/items.dmi'
	icon_state = "bracelet"
	w_class = 1
	var/image/gemstone = null
	var/obj/item/clothing/gloves/psylink_bracelet/twin

	New()
		gemstone = image('icons/obj/items.dmi',"bracelet-gem")
		var/obj/item/clothing/gloves/psylink_bracelet/two = new /obj/item/clothing/gloves/psylink_bracelet/secondary(loc)
		two.gemstone = image('icons/obj/items.dmi',"bracelet-gem")
		twin = two
		two.twin = src
		var/picker = rand(1,3)
		switch(picker)
			if (2)
				gemstone.color = "#00FF00"
				two.gemstone.color = "#FF00FF"
			if (3)
				gemstone.color = "#FFFF00"
				two.gemstone.color = "#00FFFF"
			else
				gemstone.color = "#FF0000"
				two.gemstone.color = "#0000FF"

		overlays += gemstone
		two.overlays += two.gemstone

	equipped(var/mob/user, var/slot)
		if (!user)
			return
		if (twin && istype(twin.loc,/mob/living/carbon/human))
			var/mob/living/carbon/human/psy = twin.loc
			if (psy.bioHolder && psy.bioHolder.HasEffect("psy_resist"))
				return
			if (psy.gloves == twin)
				boutput(user, "<span style=\"color:red\">You suddenly begin hearing and seeing things. What the hell?</span>")
				boutput(psy, "<span style=\"color:red\">You suddenly begin hearing and seeing things. What the hell?</span>")

	unequipped(var/mob/user)
		if (!user)
			return
		if (twin && istype(twin.loc,/mob/living/carbon/human))
			var/mob/living/carbon/human/psy = twin.loc
			if (psy.bioHolder && psy.bioHolder.HasEffect("psy_resist"))
				return
			if (psy.gloves == twin)
				boutput(user, "<span style=\"color:blue\">The strange hallcuinations suddenly stop. That was weird.</span>")
				boutput(psy, "<span style=\"color:blue\">The strange hallcuinations suddenly stop. That was weird.</span>")

/obj/item/clothing/gloves/psylink_bracelet/secondary

	New()
		return

/mob/proc/get_psychic_link()
	return null

/mob/living/carbon/human/get_psychic_link()
	if (!src)
		return null

	if (istype(gloves,/obj/item/clothing/gloves/psylink_bracelet))
		var/obj/item/clothing/gloves/psylink_bracelet/PB = gloves
		if (PB.twin && istype(PB.twin.loc,/mob/living/carbon/human))
			var/mob/living/carbon/human/psy = PB.twin.loc
			if (psy.bioHolder && psy.bioHolder.HasEffect("psy_resist"))
				return null
			if (psy.gloves == PB.twin)
				return psy

	return null

// Letters, documents, etc

/obj/item/paper/loot_crate_letters
	name = "letter"
	desc = "Some old fashioned paper correspondence."
	var/text_file = null
	var/list/pick_from_these_files = list()

	New()
		if (text_file)
			info = file2text(text_file)
		else
			if (pick_from_these_files.len)
				info = file2text(pick(pick_from_these_files))

/obj/item/paper/loot_crate_letters/generic_science
	name = "scientific document"
	desc = "You recognise a prominent research company's logo on the letterhead."
	pick_from_these_files = list("strings/fluff/cat_planet.txt","strings/fluff/giant_ruby.txt")

/obj/item/paper/loot_crate_letters/generic_crime
	name = "sketchy memo"
	desc = "There's just something really shady about this correspondence."
	pick_from_these_files = list("strings/fluff/fuck_you_pianzi.txt")