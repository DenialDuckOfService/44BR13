/obj/dummy/chameleon
	name = ""
	desc = ""
	density = 0
	anchored = 1
	soundproofing = -1
	var/can_move = 1
	var/obj/item/device/chameleon/master = null

	UpdateName()
		name = "[name_prefix(null, 1)][real_name][name_suffix(null, 1)]"

	attackby()
	    // drsingh for cannot execute null.disrupt
		if (isnull(master))
			return
		for (var/mob/M in src)
			boutput(M, "<span style=\"color:red\">Your chameleon-projector deactivates.</span>")
		if (isnull(master))
			return
		master.disrupt()

	attack_hand()
		// drsingh for cannot execute null.disrupt
		if (isnull(master))
			return
		for (var/mob/M in src)
			boutput(M, "<span style=\"color:red\">Your chameleon-projector deactivates.</span>")
		if (isnull(master))
			return
		master.disrupt()

	ex_act(var/severity)
		// drsingh for cannot execute null.disrupt
		if (isnull(master))
			return
		if (isnull(master))
			return

		for (var/mob/M in src)
			boutput(M, "<span style=\"color:red\">Your chameleon-projector deactivates.</span>")
			M.ex_act(severity) //Fuck you and your TTBs.

		if (master)
			master.disrupt()
		else
			qdel(src)

	bullet_act()
		// drsingh for cannot execute null.disrupt
		if (isnull(master))
			return
		for (var/mob/M in src)
			boutput(M, "<span style=\"color:red\">Your chameleon-projector deactivates.</span>")
		if (isnull(master))
			return
		master.disrupt()

	relaymove(var/mob/user, direction)
		if (can_move)
			can_move = 0
			spawn (10)
				can_move = 1
			step(src,direction)
		return

/obj/item/device/chameleon
	name = "chameleon-projector"
	icon_state = "shield0"
	flags = FPRINT | TABLEPASS| CONDUCT | EXTRADELAY | ONBELT | SUPPRESSATTACK
	item_state = "electronic"
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	var/can_use = 0
	var/obj/overlay/anim = null //The toggle animation overlay will also be retained
	var/obj/dummy/chameleon/cham = null //No sense creating / destroying this
	var/active = 0

	is_syndicate = 1
	mats = 14

	New()
		..()
		anim = new /obj/overlay(src)
		anim.icon = 'icons/effects/effects.dmi'
		cham = new (src)
		cham.master = src

	dropped()
		disrupt()

	attack_self()
		toggle()

	get_desc(dist)
		if (dist < 1 && !istype(src, /obj/item/device/chameleon/bomb))
			if (can_use && cham)
				. += "There is a small picture of \a [cham] on its screen."
			else
				. += "The screen on it is blank."
/*
	examine()
		..()
		var/out = ""
		if (can_use && cham)
			out = "There is a small picture of \a [cham] on its screen."
		else
			out = "The screen on it is blank."

		boutput(usr, "<span style=\"color:blue\">[out]</span>")
		return null
*/
	afterattack(atom/target, mob/user , flag)
		scan(target, user)

	proc/scan(obj/target, mob/user)
		if (get_dist(src, target) > 1)
			if (user && ismob(user))
				user.show_text("You are too far away to do that.", "red")
			return
		//Okay, enough scanning shit without actual icons yo.
		if (!isnull(initial(target.icon)) && !isnull(initial(target.icon_state)) && target.icon && target.icon_state && (istype(target, /obj/item) || istype(target, /obj/shrub) || istype(target, /obj/critter) || istype(target, /obj/machinery/bot))) // cogwerks - added more fun
			if (!cham)
				cham = new(src)
				cham.master = src

			playsound(src, "sound/weapons/flash.ogg", 100, 1, 1)
			boutput(user, "<span style=\"color:blue\">Scanned [target].</span>")
			cham.name = target.name
			cham.real_name = target.name
			cham.desc = target.desc
			cham.real_desc = target.desc
			cham.icon = target.icon
			cham.icon_state = target.icon_state
			cham.dir = target.dir
			can_use = 1
		else
			user.show_text("\The [target] is not compatible with the scanner.", "red")

	proc/toggle()
		if (!can_use)
			return

		if (!anim)
			anim = new(src)

		if (active) //active_dummy)
			active = 0
			playsound(src, "sound/effects/pop.ogg", 100, 1, 1)
			for (var/atom/movable/A in cham)
				A.set_loc(get_turf(cham))
			cham.loc = src
			boutput(usr, "<span style=\"color:blue\">You deactivate the [src].</span>")
			anim.loc = get_turf(src)
			flick("emppulse",anim)
			spawn (8)
				anim.loc = src //Back in the box with ye
		else
			if (istype(loc, /obj/dummy/chameleon)) //No recursive chameleon projectors!!
				boutput(usr, "<span style=\"color:red\">As your finger nears the power button, time seems to slow, and a strange silence falls.  You reconsider turning on a second projector.</span>")
				return

			playsound(src, "sound/effects/pop.ogg", 100, 1, 1)
			cham.master = src
			cham.set_loc(get_turf(src))
			usr.set_loc(cham)
			active = 1

			boutput(usr, "<span style=\"color:blue\">You activate the [src].</span>")
			anim.loc = get_turf(src)
			flick("emppulse",anim)
			spawn (8)
				anim.loc = src //Back in the box with ye

	proc/disrupt()
		if (active)
			active = 0
			var/effects/system/spark_spread/spark_system = unpool(/effects/system/spark_spread)
			spark_system.set_up(5, 0, src)
			spark_system.attach(src)
			spark_system.start()
			for (var/atom/movable/A in cham)
				A.set_loc(get_turf(cham))
			cham.loc = src
			can_use = 0
			spawn (100)
				can_use = 1

/obj/item/device/chameleon/bomb
	name = "chameleon bomb"
	icon = 'icons/obj/items.dmi'
	icon_state = "cham_bomb"
	burn_possible = 0
	var/strength = 32 // same as syndie pipebombs, calls the same proc

	dropped()
		return

	UpdateName()
		name = "[name_prefix(null, 1)][real_name][name_suffix(null, 1)]"

	attackby(obj/item/W as obj, mob/user as mob)
		if (active)
			if (user)
				message_admins("[key_name(user)] triggers a chameleon bomb ([src]) by hitting it with [W] at [log_loc(user)].")
				logTheThing("bombing", user, null, "triggers a chameleon bomb ([src]) by hitting it with [W] at [log_loc(user)].")
			disrupt()
		else
			return ..()

	attack_hand(var/mob/user)
		if (active && isturf(loc))
			message_admins("[key_name(user)] picks up and triggers a chameleon bomb ([src]) at [log_loc(user)].")
			logTheThing("bombing", user, null, "picks up and triggers a chameleon bomb ([src]) at [log_loc(user)].")
			disrupt()
		else
			return ..()

	ex_act()
		if (active)
			disrupt()
		else
			return ..()

	bullet_act()
		if (active)
			disrupt()
		else
			return ..()

	scan(obj/target, mob/user)
		if (get_dist(src, target) > 1)
			if (user && ismob(user))
				user.show_text("You are too far away to do that.", "red")
			return
		if (!isnull(initial(target.icon)) && !isnull(initial(target.icon_state)) && target.icon && target.icon_state && (istype(target, /obj/item) || istype(target, /obj/shrub) || istype(target, /obj/critter) || istype(target, /obj/machinery/bot))) // cogwerks - added more fun
			playsound(src, "sound/weapons/flash.ogg", 100, 1, 1)
			boutput(user, "<span style=\"color:blue\">Scanned [target].</span>")
			name = target.name
			real_name = target.name
			desc = target.desc
			real_desc = target.desc
			icon = target.icon
			icon_state = target.icon_state
			dir = target.dir
			can_use = 1
		else
			user.show_text("\The [target] is not compatible with the scanner.", "red")

	toggle()
		if (!can_use)
			return

		if (!anim)
			anim = new(src)

		if (active)
			active = 0
			playsound(src, "sound/effects/pop.ogg", 100, 1, 1)
			boutput(usr, "<span style=\"color:blue\">You disarm the [src].</span>")
			message_admins("[key_name(usr)] disarms a chameleon bomb ([src]) at [log_loc(usr)].")
			logTheThing("bombing", usr, null, "disarms a chameleon bomb ([src]) at [log_loc(usr)].")

		else
			playsound(src, "sound/effects/pop.ogg", 100, 1, 1)
			active = 1
			boutput(usr, "<span style=\"color:blue\">You arm the [src].</span>")
			message_admins("[key_name(usr)] arms a chameleon bomb ([src]) at [log_loc(usr)].")
			logTheThing("bombing", usr, null, "arms a chameleon bomb ([src]) at [log_loc(usr)].")

	disrupt()
		if (active)
			var/effects/system/spark_spread/spark_system = unpool(/effects/system/spark_spread)
			spark_system.set_up(5, 0, src)
			spark_system.attach(src)
			spark_system.start()
			blowthefuckup(strength)