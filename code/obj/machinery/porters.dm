// Contains:
// - Portable machinery remote parent
// - Broken decal remote
// - Port-a-Brig & remote
// - Port-a-Medbay & remote
// - Port-a-NanoMed & remote
// - Port-a-Sci & remote

///////////////////////////// Remote parent ///////////////////////////////////

// Adapted from the PDA program in portable_machinery_control.dm (Convair880).
/obj/item/remote/porter
	name = "Remote"
	icon = 'icons/obj/device.dmi'
	desc = "You shouldn't be able to see this!"
	icon_state = "locator"
	item_state = "electronic"
	density = 0
	anchored = 0
	w_class = 2
	mats = 4
	var/list/machinerylist = list()
	var/machinery_name = "" // For user prompt stuff.
	var/anti_spam = 0 // In relation to world time.

	proc/get_machinery()
		return

	// As to avoid a separate lookup for every remote.
	proc/teleport_sanity_check(var/obj/machinery/test_machinery, var/mob/test_mob, var/turf/test_turf, var/no_zlevel_check = 0)
		// Failure states:
		// 0: Tele-blocked loc, src/dest.loc/remote is null or related errors.
		// 1: Pass.
		// 2: On cooldown.
		// 3: There's an occupant and type of machinery requires lock to be engaged.
		// 4: Obstacle at dest.loc.
		// 5: Obstacle at home.loc.

		if (!test_machinery || !src || (test_turf && !isturf(test_turf)))
			return FALSE
		if (anti_spam && world.time < anti_spam + 50)
			return 2
		// If we're in a pod etc and want to summon the device, or if the machinery is on the MULE.
		// Both can have unexpected and bad results.
		if (!isturf(test_machinery.loc) || (!test_turf && !isturf(test_mob.loc)))
			return 4
		if (hasvar(test_machinery, "occupant"))
			if (istype(test_machinery, /obj/machinery/port_a_brig))
				var/obj/machinery/port_a_brig/PB = test_machinery
				if (PB.occupant && (test_mob && ismob(test_mob)) && (PB.occupant == test_mob))
					return FALSE // It's not a Port-a-Sci, okay.
				if (PB.occupant && !PB.locked)
					return 3
			if (istype(test_machinery, /obj/machinery/port_a_medbay))
				var/obj/machinery/port_a_medbay/PM = test_machinery
				if (PM.occupant && (test_mob && ismob(test_mob)) && (PM.occupant == test_mob))
					return FALSE // It's not a Port-a-Sci, okay.

		var/turf/our_loc = get_turf(src)

		// We don't have to loop through the remote.loc checks as well if we send the device back to its home turf.
		if (test_turf)
			if (!no_zlevel_check && (isrestrictedz(test_turf.z) || isrestrictedz(our_loc.z))) // Somebody will find a way to abuse it if I don't put this here.
				return FALSE
			if (test_turf.density)
				return 5
			for (var/obj/thing in view(0, test_turf))
				if (thing.density && !(thing.flags & ON_BORDER))
					return 5
			for (var/obj/machinery/door/D in view(0, test_turf))
				return 5
			for (var/turf/simulated/wall/W in view(0, test_turf))
				return 5

		else
			if (!our_loc || !isturf(our_loc))
				return FALSE
			if (!no_zlevel_check && isrestrictedz(our_loc.z)) // Somebody will find a way to abuse it if I don't put this here.
				return FALSE
			if (our_loc.density)
				return 4
			for (var/obj/thing2 in view(0, our_loc))
				if (thing2.density && !(thing2.flags & ON_BORDER))
					return 4
			for (var/obj/machinery/door/D in view(0, our_loc))
				return 4
			for (var/turf/simulated/wall/W in view(0, our_loc))
				return 4

		return TRUE

	attack_self(mob/user as mob)
		add_fingerprint(user)

		if (anti_spam && world.time < anti_spam + 50)
			user.show_text("The [machinery_name] is recharging!", "red")
			return

		machinerylist = list()
		get_machinery()
		if (!machinerylist || (machinerylist && machinerylist.len == 0))
			user.show_text("Couldn't find any linkable machinery.", "red")
			return

		var/t1 = input("Please select a [machinery_name] to control", "Target Selection", null, null) as null|anything in machinerylist
		if (!t1)
			return
		if ((user.equipped() != src) || user.stat || user.restrained())
			return

		var/obj/P = machinerylist[t1]
		var/turf/our_loc = get_turf(src)
		var/turf/machinery_loc = get_turf(P)
		var/turf/home_loc = null
		if (hasvar(P, "homeloc"))
			home_loc = get_turf(P:homeloc) // I have sinned, though the BAD OPERATOR might be unproblematic here.

		if (!home_loc || !isturf(home_loc))
			user.show_text("No home turf assigned to [machinery_name], can't teleport!", "red")
			return

		// Z-level check bypass for Port-a-Sci.
		var/zlevel_check_bypass = 0
		if (istype(P, /obj/storage/closet/port_a_sci))
			zlevel_check_bypass = 1

		switch (teleport_sanity_check(P, user, machinery_loc != home_loc ? home_loc : null, zlevel_check_bypass))
			if (0)
				user.show_text("Teleportation failed due to unknown interference!", "red")
				return
			if (2)
				user.show_text("The [machinery_name] is recharging!", "red")
				return
			if (3)
				user.show_text("Cannot teleport unlocked [machinery_name] with someone inside!", "red")
				return
			if (4)
				user.show_text("Teleportation failed due to obstacle!", "red")
				return
			if (5)
				user.show_text("Teleportation failed due to obstacle at home turf!", "red")
				return

			else
				anti_spam = world.time

				if (machinery_loc == home_loc)
					P.set_loc(our_loc) // We're at home, so let's summon the thing to our location.
					user.show_text("[machinery_name] summoned successfully.", "blue")
				else
					P.set_loc(home_loc) // Send back to home location.
					user.show_text("[machinery_name] send to home turf.", "blue")

				if (hasvar(P, "occupant"))
					if (istype(P, /obj/machinery/port_a_brig))
						var/obj/machinery/port_a_brig/PB = P
						if (PB.occupant)
							PB.occupant.set_loc(PB)
					if (istype(P, /obj/machinery/port_a_medbay))
						var/obj/machinery/port_a_medbay/PM = P
						if (PM.occupant)
							PM.occupant.set_loc(PM)
				if (istype(P, /obj/storage/closet/port_a_sci))
					var/obj/storage/closet/port_a_sci/PS = P
					PS.on_teleport()

				var/effects/system/spark_spread/s = unpool(/effects/system/spark_spread)
				s.set_up(5, 1, P)
				s.start()

		return

///////////////////////////////// Remotes //////////////////////////////////

/obj/item/remote/porter/port_a_brig
	name = "Port-A-Brig Remote"
	desc = "A remote that summons a Port-A-Brig."
	machinery_name = "Port-a-Brig"

	get_machinery()
		if (!src)
			return

		for (var/obj/machinery/port_a_brig/M in world)
			var/turf/M_loc = get_turf(M)
			if (M && M_loc && isturf(M_loc) && isrestrictedz(M_loc.z)) // Don't show stuff in "somewhere", okay.
				continue
			if (!(M in machinerylist))
				machinerylist["[machinery_name] #[machinerylist.len + 1] at [get_area(M)]"] += M // Don't remove the #[number] part here.
		return

/obj/item/remote/porter/port_a_medbay
	name = "Port-A-Medbay Remote"
	icon = 'icons/obj/porters.dmi'
	icon_state = "remote"
	item_state = "electronic"
	desc = "A remote that summons a Port-A-Medbay."
	machinery_name = "Port-a-Medbay"

	get_machinery()
		if (!src)
			return

		for (var/obj/machinery/port_a_medbay/M in world)
			var/turf/M_loc = get_turf(M)
			if (M && M_loc && isturf(M_loc) && isrestrictedz(M_loc.z)) // Don't show stuff in "somewhere", okay.
				continue
			if (!(M in machinerylist))
				machinerylist["[machinery_name] #[machinerylist.len + 1] at [get_area(M)]"] += M // Don't remove the #[number] part here.
		return

// I suppose this device would be sorta useless with tele-block checks?
/obj/item/remote/porter/port_a_sci
	name = "Port-A-Sci Remote"
	icon = 'icons/obj/porters.dmi'
	icon_state = "remote"
	item_state = "electronic"
	desc = "A remote that summons a Port-A-Sci."
	machinery_name = "Port-a-Sci"

	get_machinery()
		if (!src)
			return

		for (var/obj/storage/closet/port_a_sci/M in world)
			/*var/turf/M_loc = get_turf(M)
			if (M && M_loc && isturf(M_loc) && isrestrictedz(M_loc.z)) // Don't show stuff in "somewhere", okay.
				continue*/
			if (!(M in machinerylist))
				machinerylist["[machinery_name] #[machinerylist.len + 1] at [get_area(M)]"] += M // Don't remove the #[number] part here.
		return

/obj/item/remote/porter/port_a_nanomed
	name = "Port-A-NanoMed Remote"
	icon = 'icons/obj/porters.dmi'
	icon_state = "remote"
	item_state = "electronic"
	desc = "A remote that summons a Port-A-NanoMed."
	machinery_name = "Port-a-NanoMed"

	get_machinery()
		if (!src)
			return

		for (var/obj/machinery/vending/port_a_nanomed/M in world)
			var/turf/M_loc = get_turf(M)
			if (M && M_loc && isturf(M_loc) && isrestrictedz(M_loc.z)) // Don't show stuff in "somewhere", okay.
				continue
			if (!(M in machinerylist))
				machinerylist["[machinery_name] #[machinerylist.len + 1] at [get_area(M)]"] += M // Don't remove the #[number] part here.
		return

/obj/item/remote/busted
	name = "Port-A-Busted Remote"
	icon = 'icons/obj/porters.dmi'
	icon_state = "remote_busted"
	desc = "A remote for a teleportation device. Looks like it's been through the laundry... or something..."

///////////////////////////////////// Port-a-Brig /////////////////////////////////////

/obj/machinery/port_a_brig
	name = "Port-A-Brig"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_0"
	desc = "A portable holding cell with teleporting capabilites."
	density = 1
	anchored = 0
	req_access = list(access_security)
	mats = 30
	var/mob/occupant = null
	var/locked = 0
	var/homeloc = null

	New()
		..()
		UnsubscribeProcess()
		build_icon()
		homeloc = loc

	examine()
		..()
		boutput(usr, "Home turf: [get_area(homeloc)]. The interface is [locked ? "locked" : "unlocked"].")
		return

	// Could be useful (Convair880).
	MouseDrop(over_object, src_location, over_location)
		..()
		if (isobserver(usr) || isintangible(usr))
			return
		if (usr == occupant || !isturf(usr.loc))
			return
		if (usr.stat || usr.stunned || usr.weakened)
			return
		if (get_dist(src, usr) > 1)
			usr.show_text("You are too far away to do this!", "red")
			return
		if (get_dist(over_object, src) > 1)
			usr.show_text("The [name] is too far away from the target!", "red")
			return
		if (!istype(over_object,/turf/simulated/floor))
			usr.show_text("You can't set this target as the home location.", "red")
			return

		if (alert("Set selected turf as home location?",,"Yes","No") == "Yes")
			homeloc = over_object
			usr.visible_message("<span style=\"color:blue\"><strong>[usr.name]</strong> changes the [name]'s home turf.</span>", "<span style=\"color:blue\">New home turf selected: [get_area(homeloc)].</span>")
			// The crusher, hell fires etc. This feature enables quite a bit of mischief.
			logTheThing("station", usr, null, "sets [name]'s home turf to [log_loc(homeloc)].")
		return

	allow_drop()
		return FALSE

	relaymove(mob/user as mob)
		if (usr.stat != 0 || usr.stunned != 0)
			return
		go_out()
		return

	attackby(obj/item/W, mob/user as mob)
		if (istype(W, /obj/item/device/pda2) && W:ID_card)
			W = W:ID_card
		if (istype(W, /obj/item/card/id))
			if (allowed(usr, req_only_one_required))
				locked = !locked
				boutput(user, "You [ locked ? "lock" : "unlock"] the [src].")
				if (occupant)
					logTheThing("station", user, occupant, "[locked ? "locks" : "unlocks"] [name] with %target% inside at [log_loc(src)].")
			else
				boutput(user, "<span style=\"color:red\">This [src] doesn't seem to accept your authority.</span>")

		else if (istype(W, /obj/item/grab))
			if (!ismob(W:affecting))
				return
			if (occupant)
				boutput(user, "<span style=\"color:red\">The Port-A-Brig is already occupied!</span>")
				return
			if (locked)
				boutput(user, "<span style=\"color:red\">The Port-A-Brig is locked!</span>")
				return
			var/mob/M = W:affecting
			M.set_loc(src)
			occupant = M
			for (var/obj/O in src)
				O.set_loc(loc)
			add_fingerprint(user)
			build_icon()
			qdel(W)

		else if (istype(W, /obj/item/crowbar))
			var/turf/T = user.loc
			boutput(user, "<span style=\"color:blue\">Prying door open.</span>")
			playsound(loc, "sound/items/Crowbar.ogg", 100, 1)
			sleep(100)
			if ((user.loc == T && user.equipped() == W))
				locked = 0
				boutput(user, "<span style=\"color:blue\">You pried the door open.</span>")
			else if ((istype(user, /mob/living/silicon/robot) && (user.loc == T)))
				locked = 0
				boutput(user, "<span style=\"color:blue\">You pried the door open.</span>")

	proc/build_icon()
		if (occupant)
			icon_state = "pod_1"
		else
			icon_state = "pod_0"

	proc/go_out()
		if (!occupant)
			return
		if (locked)
			boutput(usr, "<span style=\"color:red\">The Port-A-Brig is locked!</span>")
			return
		occupant.set_loc(loc)
		occupant = null
		build_icon()
		for (var/obj/item/I in src) //What if you drop something while inside? WHAT THEN HUH?
			I.set_loc(loc)
		return

	verb/move_eject()
		set src in oview(1)
		set category = "Local"
		if (usr.stat != 0 || usr.stunned != 0)
			return
		go_out()
		add_fingerprint(usr)
		return

	verb/move_inside()
		set src in oview(1)
		set category = "Local"
		if (occupant)
			boutput(usr, "<span style=\"color:red\">The Port-A-Brig is already occupied!</span>")
			return
		if (locked)
			boutput(usr, "<span style=\"color:red\">The Port-A-Brig is locked!</span>")
			return
		if (usr.stat != 0 || usr.stunned != 0)
			return
		usr.pulling = null
		usr.set_loc(src)
		occupant = usr
		add_fingerprint(usr)
		build_icon()
		return

/obj/item/paper/Port_A_Brig
	name = "paper - 'A-97 Port-A-Brig Manual"
	info = {"<h4>Getting Started</h4>
	Congratulations, your station has purchased the A-97 Port-A-Brig Security device!<br>
	Using the A-97 is as simple as beating a criminal to death! Simply Summon the A-97 with the remote, put the criminal inside, lock the door with your ID and send it back!<br>
	<strong>That's all there is to it!</strong><br>
	<em>Notice, the Port-A-Brig teleporter system may fail if you are not in a open space.</em><br>
	<font size=1>This technology produced under license from  Quantum Movement Inc, LTD.</font>"}

////////////////////////////////////////// Port-a-Medbay /////////////////////////////////////

/obj/machinery/port_a_medbay
	name = "Port-A-Medbay"
	icon = 'icons/obj/porters.dmi'
	icon_state = "med_0"
	desc = "An emergency transportation device for critically injured patients."
	density = 1
	anchored = 0
	mats = 30
	var/mob/occupant = null
	var/homeloc = null

	New()
		..()
		UnsubscribeProcess()
		build_icon()
		homeloc = loc

	examine()
		..()
		boutput(usr, "Home turf: [get_area(homeloc)].")
		return

	// Could be useful (Convair880).
	MouseDrop(over_object, src_location, over_location)
		..()
		if (isobserver(usr) || isintangible(usr))
			return
		if (usr == occupant || !isturf(usr.loc))
			return
		if (usr.stat || usr.stunned || usr.weakened)
			return
		if (get_dist(src, usr) > 1)
			usr.show_text("You are too far away to do this!", "red")
			return
		if (get_dist(over_object, src) > 1)
			usr.show_text("The [name] is too far away from the target!", "red")
			return
		if (!istype(over_object,/turf/simulated/floor))
			usr.show_text("You can't set this target as the home location.", "red")
			return

		if (alert("Set selected turf as home location?",,"Yes","No") == "Yes")
			homeloc = over_object
			usr.visible_message("<span style=\"color:blue\"><strong>[usr.name]</strong> changes the [name]'s home turf.</span>", "<span style=\"color:blue\">New home turf selected: [get_area(homeloc)].</span>")
			// The crusher, hell fires etc. This feature enables quite a bit of mischief.
			logTheThing("station", usr, null, "sets [name]'s home turf to [log_loc(homeloc)].")
		return

	allow_drop()
		return FALSE

	relaymove(mob/user as mob)
		if (usr.stat != 0 || usr.stunned != 0)
			return
		go_out()
		return

	attackby(obj/item/W, mob/user as mob)
		if (istype(W, /obj/item/grab))
			if (!ismob(W:affecting))
				return
			if (occupant)
				boutput(user, "<span style=\"color:red\">The Port-A-Medbay is already occupied!</span>")
				return
			var/mob/M = W:affecting
			M.set_loc(src)
			occupant = M
			for (var/obj/O in src)
				O.set_loc(loc)
			add_fingerprint(user)
			build_icon()
			qdel(W)

	proc/build_icon()
		if (occupant)
			icon_state = "med_1"
		else
			icon_state = "med_0"

	proc/go_out()
		if (!( occupant))
			return
		occupant.set_loc(loc)
		occupant = null
		build_icon()
		for (var/obj/item/I in src) //Sometimes people drop stuff OKAY
			I.set_loc(loc)
		return

	verb/move_eject()
		set src in oview(1)
		set category = "Local"
		if (usr.stat != 0 || usr.stunned != 0)
			return
		go_out()
		add_fingerprint(usr)
		return

	verb/move_inside()
		set src in oview(1)
		set category = "Local"
		if (occupant)
			boutput(usr, "<span style=\"color:red\">The Port-A-Medbay is already occupied!</span>")
			return
		if (usr.stat != 0 || usr.stunned != 0)
			return
		usr.pulling = null
		usr.set_loc(src)
		occupant = usr
		add_fingerprint(usr)
		build_icon()
		return

/////////////////////////////////////// Port-a-Sci ///////////////////////////////////////////

/obj/storage/closet/port_a_sci
	name = "Port-A-Sci"
	desc = "This has gotta be the fanciest locker you've ever seen. The ones in highscool sure didn't have li'l TVs in 'em! They probably couldn't teleport, either."
	icon_state = "portasci"
	icon_closed = "portasci"
	icon_opened = "portasci-open"
	density = 1
	anchored = 0
	//mats = 30 // Nope! We don't need multiple personal teleporters without any z-level restrictions (Convair880).
	var/homeloc = null

	var/unsafe_mode = 1 //Hilarious accident mode, more like
	var/list/possible_new_friend = list()
	//Debug vars that should never ever be used maliciously, no sir
	var/force_failure = 0
	var/force_body_swap = 0

	New()
		..()
		homeloc = loc

		possible_new_friend = typesof(/obj/critter/bear) + typesof(/obj/critter/spider/ice) + typesof(/obj/critter/cat) + typesof(/obj/critter/parrot) +\
						list(/obj/critter/aberration, /obj/critter/domestic_bee, /obj/critter/domestic_bee/chef, /obj/critter/bat/buff, /obj/critter/bat, /obj/critter/bloodling, /obj/critter/wraithskeleton, /obj/critter/magiczombie, /obj/critter/wendigo) -\
						list(/obj/critter/spider/ice/queen)

	examine()
		..()
		boutput(usr, "Home turf: [get_area(homeloc)].")
		return

	// This thing isn't z-level-restricted except for the homeloc.
	// Somebody WILL find an exploit otherwise (Convair880).
	MouseDrop(over_object, src_location, over_location)
		..()
		if (isobserver(usr) || isintangible(usr))
			return
		if ((usr in contents) || !isturf(usr.loc))
			return
		if (usr.stat || usr.stunned || usr.weakened)
			return
		if (get_dist(src, usr) > 1)
			usr.show_text("You are too far away to do this!", "red")
			return
		if (get_dist(over_object, src) > 1)
			usr.show_text("The [name] is too far away from the target!", "red")
			return
		if (!istype(over_object,/turf/simulated/floor))
			usr.show_text("You can't set this target as the home location.", "red")
			return
		var/turf/check_loc = over_object
		if (check_loc && isturf(check_loc) && isrestrictedz(check_loc.z))
			usr.show_text("You can't set this target as the home location.", "red")
			return

		if (alert("Set selected turf as home location?",,"Yes","No") == "Yes")
			homeloc = over_object
			usr.visible_message("<span style=\"color:blue\"><strong>[usr.name]</strong> changes the [name]'s home turf.</span>", "<span style=\"color:blue\">New home turf selected: [get_area(homeloc)].</span>")
			// The crusher, hell fires etc. This feature enables quite a bit of mischief.
			logTheThing("station", usr, null, "sets [name]'s home turf to [log_loc(homeloc)].")
		return

	allow_drop()
		return FALSE

	attackby(obj/item/W as obj, mob/user as mob)
		if (open && istype(W, /obj/item/wrench))
			return
		else
			return ..()

	proc/on_teleport()
		if (unsafe_mode)
			var/has_mob = 0
			for (var/mob/living/carbon/M in contents)
				if (M.client && M.stat != 2) //We want a logged-in and living mob otherwise fucklers could spam this without consequence.
					has_mob = 1
					break

			//Body swapping
			if ((force_body_swap || prob(5)) && has_mob)
				var/list/mob/body_list = list()
				for (var/mob/living/M in contents) //Don't think you're gonna get lucky, ghosts!
					if (M.stat != 2) body_list += M
				if (body_list.len > 1)

					for (var/I = 1, I <= body_list.len , I++)
						var/next_in_line = ((I % body_list.len) + 1)

						var/mob/M = body_list[I] //What the actual fuck is this motherfucking nonsense shit fuck I hate you byond what the hell.
						if (M.mind)
							logTheThing("combat", src, body_list[next_in_line], "swapped [key_name(M)] and %target%'s bodies!")
							M.mind.swap_with(body_list[next_in_line])
							I++ //Step once more to prevent us from hitting the swapped mob

			//Other fuckery
			if ( has_mob && (prob(20) || force_failure) ) //This is totally safe.

				switch( force_failure ? force_failure : rand(1,100) )

					if (81 to INFINITY) //Travel sickness!
						for (var/mob/living/carbon/M in contents)
							spawn (rand(10,40))
								M.visible_message("<span style=\"color:red\">[M] pukes all over \himself.</span>", "<span style=\"color:red\">Oh god, that was terrible!</span>", "<span style=\"color:red\">You hear a splat!</span>")
								M.change_misstep_chance(40)
								M.drowsyness += 2
								playsound(M.loc, "sound/effects/splat.ogg", 50, 1)
								new /obj/decal/cleanable/vomit(M.loc)

					if (51 to 70) //A nice tan
						for (var/mob/living/carbon/M in contents)
							if (M.irradiate(20))	M.show_text("\The [src] buzzes oddly.", "red")
					if (31 to 50) //A very nice tan
						for (var/mob/living/carbon/M in contents)
							if (M.irradiate(40))	M.show_text("You feel a warm tingling sensation.", "red")
					if (21 to 30) //The nicest tan
						for (var/mob/living/carbon/human/M in contents)
							if (M.irradiate(100))
								M.show_text("<strong>You feel a wave of searing heat wash over you!</strong>", "red")
								if (M.bioHolder && M.bioHolder.mobAppearance) //lol
									M.bioHolder.mobAppearance.s_tone  = max(M.bioHolder.mobAppearance.s_tone - 40, -185)
									for (var/obj/item/parts/human_parts/HP in M.contents)
										HP.set_skin_tone()

									M.bioHolder.mobAppearance.UpdateMob()

					if (11 to 20) //Mechanical failure aaaaaa
						var/list/temp = contents.Copy()
						open()
						visible_message("<span style=\"color:red\"><strong>\the [src]'s door flies open and a gout of flame erupts from within!</span>")
						fireflash(src, 2)
						for (var/mob/living/carbon/M in temp)
							spawn (0)
								M.update_burning(100)
								var/turf/T = get_edge_target_turf(M, turn(NORTH, rand(0,7) * 45))
								M.throw_at(T,100, 2)

					if (3 to 10) //Hitchhiker friend!
						var/obj/critter/C = pick(possible_new_friend)
						new C(src)

						for (var/mob/M in contents)
							M.show_text("Did it just get more cramped in here...?", "red")

					if (1 to 2) //Hilarious accident
						for (var/mob/living/carbon/human/M in contents)
							M.set_mutantrace(/mutantrace/roach)
							M.bioHolder.mobAppearance.UpdateMob()
							M.show_text("You feel different...", "red")


//////////////////////////////////////// Port-a-NanoMed ///////////////////////////////////////////

/obj/machinery/vending/port_a_nanomed
	name = "Port-A-NanoMed"
	desc = "A compact and portable version of the NanoMed Plus."
	icon = 'icons/obj/porters.dmi'
	icon_state = "vend"
	icon_deny = "vend-deny"
	layer = FLOOR_EQUIP_LAYER1
	req_access_txt = "5"
	acceptcard = 0
	anchored = 0
	can_fall = 0
	mats = 30
	var/homeloc = null

	New()
		..()
		//animate_bumble(src, -1, 10, 1, -1)
		animate_bumble(src, Y1 = 1, Y2 = -1, slightly_random = 0)
		homeloc = loc
		//Products
		product_list += new/data/vending_product("/obj/item/reagent_containers/patch/bruise", 20)
		product_list += new/data/vending_product("/obj/item/reagent_containers/patch/burn", 20)
		product_list += new/data/vending_product("/obj/item/reagent_containers/emergency_injector/epinephrine", 10)
		product_list += new/data/vending_product("/obj/item/reagent_containers/emergency_injector/charcoal", 10)
		product_list += new/data/vending_product("/obj/item/reagent_containers/emergency_injector/saline", 10)
		product_list += new/data/vending_product("/obj/item/reagent_containers/emergency_injector/atropine", 4)
		product_list += new/data/vending_product("/obj/item/reagent_containers/emergency_injector/mannitol", 8)
		product_list += new/data/vending_product("/obj/item/reagent_containers/emergency_injector/salbutamol", 8)
		product_list += new/data/vending_product("/obj/item/reagent_containers/emergency_injector/antihistamine", 6)
		product_list += new/data/vending_product("/obj/item/reagent_containers/emergency_injector/salicylic_acid", 4)
		product_list += new/data/vending_product("/obj/item/reagent_containers/emergency_injector/anti_rad", 8)
		product_list += new/data/vending_product("/obj/item/reagent_containers/emergency_injector/spaceacillin", 4)
		product_list += new/data/vending_product("/obj/item/reagent_containers/emergency_injector/insulin", 4)
		product_list += new/data/vending_product("/obj/item/reagent_containers/emergency_injector/calomel", 6)
		product_list += new/data/vending_product("/obj/item/reagent_containers/pill/mutadone", 5)
		product_list += new/data/vending_product("/obj/item/bandage", 6)
		product_list += new/data/vending_product("/obj/item/device/healthanalyzer", 4)
		product_list += new/data/vending_product("/obj/item/device/healthanalyzer_upgrade", 4)

		//Hidden
		product_list += new/data/vending_product("/obj/item/reagent_containers/emergency_injector/random", rand(1, 3), hidden=1)

	examine()
		..()
		boutput(usr, "Home turf: [get_area(homeloc)].")
		return

	// Could be useful (Convair880).
	MouseDrop(over_object, src_location, over_location)
		..()
		if (isobserver(usr) || isintangible(usr))
			return
		if (!isturf(usr.loc))
			return
		if (usr.stat || usr.stunned || usr.weakened)
			return
		if (get_dist(src, usr) > 1)
			usr.show_text("You are too far away to do this!", "red")
			return
		if (get_dist(over_object, src) > 1)
			usr.show_text("The [name] is too far away from the target!", "red")
			return
		if (!istype(over_object,/turf/simulated/floor))
			usr.show_text("You can't set this target as the home location.", "red")
			return

		if (alert("Set selected turf as home location?",,"Yes","No") == "Yes")
			homeloc = over_object
			usr.visible_message("<span style=\"color:blue\"><strong>[usr.name]</strong> changes the [name]'s home turf.</span>", "<span style=\"color:blue\">New home turf selected: [get_area(homeloc)].</span>")
			// The crusher, hell fires etc. This feature enables quite a bit of mischief...well, if it wouldn't be the NanoMed.
			//logTheThing("station", usr, null, "sets [name]'s home turf to [log_loc(homeloc)].")
		return

	allow_drop()
		return FALSE

	powered()
		return

	use_power()
		return

	power_change()
		return