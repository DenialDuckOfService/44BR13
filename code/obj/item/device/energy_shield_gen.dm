/obj/item/shieldwallgen
	name = "Energy-Shield Generator"
	desc = "Organic matter can pass through the shields generated by this generator. Can be secured to the ground using a wrench."
	icon = 'icons/obj/device.dmi'
	icon_state = "cloakgen_off"
	density = 0
	opacity = 0
	anchored = 0
	w_class = 2.0
	pressure_resistance = 2*ONE_ATMOSPHERE
	var/list/tiles = new/list()
	var/active = 0
	var/range = 1
	var/secured = 0
	var/broken_num = 0
	//Save and regenerate weakened parts.

	// For whatever reason, disposing() is never called for this item. Ditto for the cloak generator (Convair880).
	Del()
		//DEBUG("Del() was called for [src].")
		if (active)
			turn_off()
		..()
		return

	disposing()
		//DEBUG("Disposing() was called for [src] at [log_loc(src)].")
		if (active)
			turn_off()
		..()
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W,/obj/item/wrench) && isturf(loc) && !istype(loc,/turf/space))
			if (secured)
				boutput(usr, "<span style=\"color:red\">You unsecure the generator.</span>")
				secured = 0
				playsound(src, "sound/items/Ratchet.ogg", 60, 1)
			else
				boutput(usr, "<span style=\"color:red\">You secure the generator.</span>")
				secured = 1
				playsound(src, "sound/items/Ratchet.ogg", 60, 1)

	attack_hand(mob/user as mob)
		if (secured)
			boutput(user, "<span style=\"color:red\">Its secured to the ground.</span>")
			return
		else
			return ..()

	verb/increase_range()
		set src in view(1)
		if (!istype(usr,/mob/living)) return
		if (!isturf(loc))
			boutput(usr, "<span style=\"color:red\">You must place the generator on the ground to use it.</span>")
			return
		range = min(range+1,3)
		boutput(usr, "<span style=\"color:blue\">Range set to : [range]</span>")
		if (active)
			turn_off()
			turn_on()

	verb/decrease_range()
		set src in view(1)
		if (!istype(usr,/mob/living)) return
		if (!isturf(loc))
			boutput(usr, "<span style=\"color:red\">You must place the generator on the ground to use it.</span>")
			return
		range = max(range-1,1)
		boutput(usr, "<span style=\"color:blue\">Range set to : [range]</span>")
		if (active)
			turn_off()
			turn_on()

	pickup(var/mob/living/M)
		if (active)
			turn_off()

	proc/turn_on()
		var/xa
		var/ya
		var/piece
		var/atom/A

		for (xa=(-range), xa<((range*2)+(1-range)), xa++)
			for (ya=(-range), ya<((range*2)+(1-range)), ya++)
				if ( (xa != range && xa != -range) && (ya != range && ya != -range) )
					continue
				if (xa == -range && ya == range) piece = NORTHWEST
				if (xa == range && ya == range) piece = NORTHEAST
				if (xa == -range && ya == -range) piece = SOUTHWEST
				if (xa == range && ya == -range) piece = SOUTHEAST
				if ( (xa != range && xa != -range) && ya == range) piece = NORTH
				if ( (xa != range && xa != -range) && ya == -range) piece = SOUTH
				if ( xa == range && (ya != range && ya != -range)) piece = EAST
				if ( xa == -range && (ya != range && ya != -range)) piece = WEST

				A = locate((x + xa),(y + ya),z)
				if (!A.density)
					var/obj/shieldwall/created = new /obj/shieldwall ( locate((x + xa),(y + ya),z) )
					created.dir = piece
					tiles += created
					created.health_max = 16 - (range*2)
					created.health = 16 - (range*2)

		icon_state = "cloakgen_on"
		anchored = 1
		active = 1

		var/list/breakables = tiles.Copy()
		for (var/i=0, i<broken_num, i++)
			if (!breakables.len) break
			var/obj/shieldwall/S = pick(breakables)
			S.broken = 1
			S.health = 0
			S.icon_state = "shield0"
			S.name = "weakened shield"
			spawn (200)
				if (S)
					S.health = S.health_max
					S.check()
			breakables -= S

	proc/turn_off()
		broken_num = 0
		for (var/obj/shieldwall/A in tiles)
			if (A.broken) broken_num++
			qdel(A)
		tiles = new/list()
		icon_state = "cloakgen_off"
		anchored = 0
		active = 0

	verb/toggle()
		set src in view(1)
		if (!istype(usr,/mob/living)) return
		if (!isturf(loc))
			boutput(usr, "<span style=\"color:red\">You must place the generator on the ground to use it.</span>")
			return

		if (!active)
			turn_on()
			boutput(usr, "<span style=\"color:blue\">You activate the generator.</span>")
		else
			turn_off()
			boutput(usr, "<span style=\"color:blue\">You deactivate the generator.</span>")

/obj/shieldwall
	name = "shield"
	desc = "An energy shield."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield1"
	density = 1
	opacity = 0
	anchored = 1
	layer=12
	var/health_max = 10
	var/health = 10
	var/broken = 0

	CanPass(atom/A, turf/T)
		if (broken) return TRUE
		if (ismob(A)) return TRUE
		else return FALSE

	ex_act(severity)
		if (broken) return
		health--
		check()

	meteorhit(var/obj/O as obj)
		if (broken) return
		health--
		check()
		playsound(src, "sound/effects/shieldhit2.ogg", 40, 1)
		qdel(O)

	proc/check()
		if (health <= 0)
			broken = 1
			icon_state = "shield0"
			name = "weakened shield"
			playsound(src, "sound/effects/shielddown2.ogg", 45, 1)
			spawn (450)
				health = health_max
				check()
		else
			broken = 0
			icon_state = "shield1"
			name = "energy shield"