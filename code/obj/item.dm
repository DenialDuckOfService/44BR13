/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'
	var/movement_speed_mod = 0
	var/icon_old = null
	var/abstract = 0.0
	var/force = null
	var/item_state = null
	var/damtype = "brute"
	var/hit_type = DAMAGE_BLUNT // for bleeding system things, options: DAMAGE_BLUNT, DAMAGE_CUT, DAMAGE_STAB in order of how much it affects the chances to increase bleeding
	throwforce = 4
	var/r_speed = 1.0
	var/health = 4 // burn faster
	var/burn_point = 15000  // this already exists but nothing uses it???
	var/burn_possible = 1 //cogwerks fire project - can object catch on fire - let's have all sorts of shit burn at hellish temps
	var/burn_output = 1500 //how hot should it burn
	var/burn_type = 0 // 0 = ash, 1 = melt
	var/burning = null
	var/hitsound = 'sound/weapons/genhit1.ogg'
	var/w_class = 3.0
	var/cant_self_remove = 0 //Can't remove from non-hand slots
	var/cant_other_remove = 0 //Can't be removed from non-hand slots by others
	var/cant_drop = 0 //Cant' be removed in general. I guess.
	flags = FPRINT | TABLEPASS
	pressure_resistance = 50
	var/obj/item/master = null
	var/numattacks = 1
	var/amount = 1
	var/max_stack = 1
	var/stack_type = null // if null, only current type. otherwise uses this
	var/contraband = 0 //If nonzero, bots consider this a thing people shouldn't be carrying without authorization

	var/image/wear_image = null
	var/wear_image_icon = 'icons/mob/belt.dmi'
	var/image/inhand_image = null
	var/inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'

	var/arm_icon = "" //set to an icon state in human.dmi minus _s/_l and l_arm_/r_arm_ to allow use as an arm
	var/over_clothes = 0 //draw over clothes when used as a limb
	var/override_attack_hand = 1 //when used as an arm, attack with item rather than using attack_hand
	var/can_hold_items = 0 //when used as an arm, can it hold things?

	var/stamina_damage = STAMINA_ITEM_DMG //amount of stamina removed from target per hit.
	var/stamina_cost = STAMINA_ITEM_COST  //amount of stamina removed from USER per hit. This cant bring you below 10 points and you will not be able to attack if it would.
	var/stamina_crit_chance = STAMINA_CRIT_CHANCE //Crit chance when attacking with this.

	var/list/module_research = list()
	var/module_research_type = null
	var/module_research_no_diminish = 0

	var/edible = 0 // can you eat the thing?

	var/duration_put    = -1 //If set to something other than -1 these will control
	var/duration_remove = -1 //how long it takes to remove or put the item onto a person. 1/10ths of a second.

	var/rand_pos = 0
	var/useInnerItem = 0 //Should this item use a contained item (in contents) to attack with instead?

/obj/item/onMaterialChanged()
	..()
	if (istype(material))
		stamina_damage = initial(stamina_damage) + (material.hasProperty(PROP_COMPRESSIVE) ? round(material.getProperty(PROP_COMPRESSIVE) / 8) : -4)
		stamina_crit_chance = initial(stamina_crit_chance) + (material.hasProperty(PROP_HARDNESS) ? round(material.getProperty(PROP_HARDNESS) / 8) : -5)
		force = material.hasProperty(PROP_HARDNESS) ? round(material.getProperty(PROP_HARDNESS) / 3) : force
		burn_point = material.hasProperty(PROP_MELTING) ? material.getProperty(PROP_MELTING) : burn_point
		burn_output = initial(burn_output) + (100 * material.getProperty(PROP_FLAMMABILITY)) + (100 * material.getProperty(PROP_ENERGY))
		burn_possible = material.getProperty(PROP_FLAMMABILITY) ? 1 : 0

		if (src.material.material_flags & MATERIAL_METAL || src.material.material_flags & MATERIAL_CRYSTAL || src.material.material_flags & MATERIAL_RUBBER)
			burn_type = 1
		else
			burn_type = 0

/obj/item/New()
	// this is dumb but it won't let me initialize vars to image() for some reason
	wear_image = image(wear_image_icon)
	inhand_image = image(inhand_image_icon)
	if (rand_pos)
		if (!pixel_x) // just in case
			pixel_x = rand(-8,8)
		if (!pixel_y) // same as above
			pixel_y = rand(-8,8)
	..()

/obj/item/proc/Eat(var/mob/M as mob, var/mob/user)
	if (!edible)
		return FALSE
	if (!iscarbon(M) && !istype(M, /mob/living/critter))
		return FALSE

	if (M == user)
		M.visible_message("<span style=\"color:blue\">[M] takes a bite of [src]!</span>",\
		"<span style=\"color:blue\">You take a bite of [src]!</span>")

		if (reagents && reagents.total_volume)
			reagents.reaction(M, INGEST)
			spawn (5) // Necessary.
				reagents.trans_to(M, reagents.total_volume/amount)

		playsound(M.loc,"sound/items/eatfood.ogg", rand(10, 50), 1)
		spawn (10)
			// Why not, I guess. Adds a bit of flavour (Convair880).
			if (iswerewolf(M) && istype(src, /obj/item/organ))
				M.show_text("Mmmmm, tasty organs. How refreshing.", "blue")
				M.HealDamage("All", 5, 5)

			M.visible_message("<span style=\"color:red\">[M] finishes eating [src].</span>",\
			"<span style=\"color:red\">You finish eating [src].</span>")
			user.u_equip(src)
			qdel(src)

			return TRUE
	else
		user.tri_message("<span style=\"color:red\"><strong>[user]</strong> tries to feed [M] [src]!</span>",\
		user, "<span style=\"color:red\">You try to feed [M] [src]!</span>",\
		M, "<span style=\"color:red\"><strong>[user]</strong> tries to feed you [src]!</span>")
		logTheThing("combat", user, M, "attempts to feed %target% [src] [log_reagents(src)]")

		if (!do_mob(user, M))
			return
		user.tri_message("<span style=\"color:red\"><strong>[user]</strong> feeds [M] [src]!</span>",\
		user, "<span style=\"color:red\">You feed [M] [src]!</span>",\
		M, "<span style=\"color:red\"><strong>[user]</strong> feeds you [src]!</span>")
		logTheThing("combat", user, M, "feeds %target% [src] [log_reagents(src)]")

		if (reagents && reagents.total_volume)
			reagents.reaction(M, INGEST)
			spawn (5) // Necessary.
				reagents.trans_to(M, reagents.total_volume)

		playsound(M.loc, "sound/items/eatfood.ogg", rand(10, 50), 1)
		spawn (10)
			// Ditto (Convair880).
			if (iswerewolf(M) && istype(src, /obj/item/organ))
				M.show_text("Mmmmm, tasty organs. How refreshing.", "blue")
				M.HealDamage("All", 5, 5)

			M.visible_message("<span style=\"color:red\">[M] finishes eating [src].</span>",\
			"<span style=\"color:red\">You finish eating [src].</span>")
			user.u_equip(src)
			qdel(src)
			return TRUE

/obj/item/proc/take_damage(brute, burn, tox, disallow_limb_loss)
	// this is a helper for organs and limbs
	return FALSE

/obj/item/proc/heal_damage(brute, burn, tox)
	// this is a helper for organs and limbs
	return FALSE

/obj/item/proc/get_damage()
	// this is a helper for organs and limbs
	return FALSE

/obj/item/proc/equipment_click(var/atom/target, var/atom/user) //Is called together with attackby and afterattack on items the MOB is wearing. Only works for mob/living/carbon s.
	return													   //Can be treated as afterattack that is called on all equiped items, basically. This is not restricted by LOS or anything
															   //You'll have to check for that yourself if you need it.

/*
		var/icon/overlay = icon('icons/effects/96x96.dmi',"smoke")
		if (color)
			overlay.Blend(color,ICON_MULTIPLY)
		var/image/I = image(overlay)
		I.pixel_x = -32
		I.pixel_y = -32

		var/the_dir = NORTH
	for (var/i=0, i<8, i++)
		var/obj/chem_smoke/C = new/obj/chem_smoke(location, holder, max_vol)
		C.overlays += I
		if (rname) C.name = "[rname] smoke"
		spawn (0)
			var/my_dir = the_dir
			var/my_time = rand(80,110)
			var/my_range = 3
			spawn (my_time) qdel(C)
			for (var/b=0, b<my_range, b++)
				sleep(15)
				if (!C) break
				step(C,my_dir)
				C.expose()
		the_dir = turn(the_dir,45)
*/

/obj/item/proc/combust() // cogwerks- flammable items project
	if (!burning)
		visible_message("<span style=\"color:red\">[src] catches on fire!</span>")
		burning = 1
		if (burn_output >= 1000)
			overlays += image('icons/effects/fire.dmi', "2old")
		else
			overlays += image('icons/effects/fire.dmi', "1old")
		/*if (reagents && reagents.reagent_list && reagents.reagent_list.len)

			//boutput(world, "<span style=\"color:red\"><strong>[src] is releasing chemsmoke!</strong></span>")
			//cogwerks note for drsingh: this was causing infinite server-killing problems
			//someone brought a couple pieces of cheese into chemistry
			//chlorine trifluoride foam set the cheese on fire causing it to releasee cheese smoke
			//creating a dozen more cheeses on the floor
			//which would catch on fire, releasing more cheese smoke
			//i'm sure you can see where that is going
			//this will happen with any reagents that create more reagent-containing items on turf reactions
			var/location = get_turf(src)
			var/max_vol = reagents.maximum_volume
			var/rname = reagents.get_master_reagent_name()
			var/color = reagents.get_master_color(1)
			var/icon/overlay = icon('icons/effects/96x96.dmi',"smoke")
			if (color)
				overlay.Blend(color,ICON_MULTIPLY)
			var/image/I = image(overlay)
			I.pixel_x = -32
			I.pixel_y = -32

			var/the_dir = NORTH
			for (var/i=0, i<8, i++)
				var/obj/chem_smoke/C = new/obj/chem_smoke(location, reagents, max_vol)
				C.overlays += I
				if (rname) C.name = "[rname] smoke"
				spawn (0)
					var/my_dir = the_dir
					var/my_time = rand(80,110)
					var/my_range = 3
					spawn (my_time) qdel(C)
					for (var/b=0, b<my_range, b++)
						sleep(15)
						if (!C) break
						step(C,my_dir)
						C.expose()
				the_dir = turn(the_dir,45) */
		spawn (5)
			while (health > 0 && burning)
				if (material)
					material.triggerTemp(src, burn_output + rand(1,200))
				var/turf/T = get_turf(loc)
				if (T) // runtime error fix
					T.hotspot_expose((burn_output + rand(1,200)),5)
				sleep(15)

				if (prob(7))
					var/effects/system/spark_spread/s = unpool(/effects/system/spark_spread)
					s.set_up(2, 1, (get_turf(src)))
					s.start()
				if (prob(7))
					var/effects/system/bad_smoke_spread/smoke = new /effects/system/bad_smoke_spread()
					smoke.set_up(1, 0, loc)
					smoke.attach(src)
					smoke.start()
				if (prob(7))
					fireflash(src, 0)
				// Marquesas: this will give paper an average lifetime of 6 seconds while burning.
				if (prob(40))
					if (health > 4)
						health /= 2
					else
						health--
			if (health <= 0 && burning)
				if (burn_type == 1)
					new /obj/decal/cleanable/molten_item(get_turf(src))
				else
					new /obj/decal/cleanable/ash(get_turf(src))

				if (istype(src,/obj/item/parts/human_parts))
					src:holder = null
				qdel(src)
				return
			if (!burning)
				if (burn_output >= 1000)
					overlays -= image('icons/effects/fire.dmi', "2old")
				else
					overlays -= image('icons/effects/fire.dmi', "1old")
				return

/obj/item/temperature_expose(gas_mixture/air, temperature, volume)
	if (burn_possible && !burning)
		if ((temperature > T0C + burn_point) && prob(5))
			combust()
	if (material)
		material.triggerTemp(src, temperature)
	..() // call your fucking parents

/obj/item/proc/update_stack_appearance()

/obj/item/proc/change_stack_amount(var/diff)
	amount += diff
	if (diff)
		if (amount > 0)
			update_stack_appearance()
		else
			spawn (0)
				qdel(src)

/obj/item/proc/stack_item(obj/item/other)
	var/added = 0

	if (other != src && check_valid_stack(other))
		if (amount + other.amount > max_stack)
			added = max_stack - amount
		else
			added = other.amount

		change_stack_amount(added)
		other.change_stack_amount(-added)

	return added

/obj/item/proc/before_stack(atom/movable/O as obj, mob/user as mob)
	user.visible_message("<span style=\"color:blue\">[user] begins quickly stacking [src]!</span>")

/obj/item/proc/after_stack(atom/movable/O as obj, mob/user as mob, var/added)
	boutput(user, "<span style=\"color:blue\">You finish stacking [src].</span>")

/obj/item/proc/failed_stack(atom/movable/O as obj, mob/user as mob, var/added)
	boutput(user, "<span style=\"color:blue\">You can't hold any more [name] than that!</span>")

/obj/item/proc/check_valid_stack(atom/movable/O as obj)
	if (stack_type)
		return istype(O, stack_type)
	return type == O.type

/obj/item/MouseDrop_T(atom/movable/O as obj, mob/user as mob)
	..()
	if (max_stack > 1 && loc == user && get_dist(O, user) <= 1 && check_valid_stack(O))
		if ( amount >= max_stack)
			failed_stack(O, user)
			return

		var/added = 0
		var/staystill = user.loc
		var/stack_result = 0

		before_stack(O, user)

		for (var/obj/item/other in view(1,user))
			stack_result = stack_item(other)
			if (!stack_result)
				continue
			else
				sleep(3)
				added += stack_result
				if (user.loc != staystill) break
				if (amount >= max_stack)
					failed_stack(O, user)
					return

		after_stack(O, user, added)

/obj/item/Bump(mob/M as mob)
	spawn ( 0 )
		..()
	return

/obj/item/attackby(obj/item/W as obj, mob/user as mob, params)
	if (material)
		material.triggerTemp(src ,1500)
	if (burn_possible && burn_point <= 1500)
		if (istype(W, /obj/item/weldingtool) && W:welding)
			combust()

		if (istype(W, /obj/item/clothing/head/cakehat) && W:on)
			combust()

		if (istype(W, /obj/item/device/igniter))
			combust()

		else if (istype(W, /obj/item/zippo) && W:lit)
			combust()

		if (W.burning)
			combust()
		else
			..(W, user)
	else
		..(W, user)

/obj/item/proc/process()
	processing_items.Remove(src)

	return null

/obj/item/proc/attack_self()
	return

/obj/item/proc/talk_into(mob/M as mob, text, secure, real_name, lang_id)
	return

/obj/item/proc/moved(mob/user as mob, old_loc as turf)
	return

/obj/item/proc/equipped(var/mob/user, var/slot)
	return

/obj/item/proc/unequipped(var/mob/user)
	return

/obj/item/proc/afterattack(atom/target, mob/user, reach, params)
	return

/obj/item/dummy/ex_act()
	return

/obj/item/dummy/blob_act(var/power)
	return

/obj/item/ex_act(severity)
	switch(severity)
		if (1.0)
			if (istype(src,/obj/item/parts/human_parts))
				src:holder = null
			qdel(src)
			return
		if (2.0)
			if (prob(50))

				if (istype(src,/obj/item/parts/human_parts))
					src:holder = null

				qdel(src)
				return
			if (material)
				material.triggerTemp(src ,7500)
			if (burn_possible && !burning && burn_point <= 7500)
				combust()
			if (artifact)
				if (!ArtifactSanityCheck()) return
				ArtifactStimulus("force", 75)
				ArtifactStimulus("heat", 450)
		if (3.0)
			if (prob(5))

				if (istype(src,/obj/item/parts/human_parts))
					src:holder = null

				qdel(src)
				return
			if (material)
				material.triggerTemp(src, 3500)
			if (burn_possible && !burning && burn_point <= 3500)
				combust()
			if (artifact)
				if (!ArtifactSanityCheck()) return
				ArtifactStimulus("force", 25)
				ArtifactStimulus("heat", 380)
		else
	return

/obj/item/blob_act(var/power)
	if (artifact)
		if (!ArtifactSanityCheck()) return
		ArtifactStimulus("force", power)
		ArtifactStimulus("carbtouch", 1)
	return

/obj/item/verb/move_to_top()
	set name = "Move to Top"
	set src in oview(1)
	set category = "Local"

	if (!istype(loc, /turf) || usr.stat || usr.restrained() )
		return

	var/turf/T = loc

	set_loc(null)

	set_loc(T)

/obj/item/verb/pick_up()
	set name = "Pick Up"
	set src in oview(1)
	set category = "Local"

	if (!iscarbon(usr))
		return

	if (!istype(loc, /turf) || usr.stat || usr.restrained() || usr.equipped())
		return

	if (!can_reach(usr, src))
		return

	attack_hand(usr)

/obj/item/get_desc()
	var/t
	switch(w_class)
		if (1.0) t = "tiny"
		if (2.0) t = "small"
		if (3.0) t = "normal-sized"
		if (4.0) t = "bulky"
		if (5.0) t = "huge"
		else
	if (usr.bioHolder.HasEffect("clumsy") && prob(50)) t = "funny-looking"
	return "It is a [t] item."

/obj/item/attack_hand(mob/user as mob)
	var/checkloc = loc
	while (checkloc && !istype(checkloc,/turf))
		if (istype(checkloc,/mob/living) && checkloc != user)
			return
		checkloc = checkloc:loc
	throwing = 0
	if (loc == user)
		if (!cant_self_remove || (!cant_drop && (user.l_hand == src || user.r_hand == src)))
			user.u_equip(src)
		else
			boutput(user, "<span style=\"color:red\">You can't remove this item.</span>")
			return
	else
		//pickup(user) //This is called by the later put_in_hand() call
		if (user.pulling == src)
			user.pulling = null

	if (!user)
		return

	var/atom/oldloc = loc
	set_loc(user) // this is to fix some bugs with storage items
	if (istype(oldloc, /obj/item/storage))
		var/obj/item/storage/S = oldloc 
		S.hud.remove_item(src)
	if (src in bible_contents)
		bible_contents.Remove(src) // UNF
		for (var/obj/item/storage/bible/bible in world)
			bible.hud.remove_item(src)
	user.put_in_hand_or_drop(src)

	if (artifact)
		if (ArtifactSanityCheck())
			ArtifactTouched(user)

/obj/item/proc/attack(mob/M as mob, mob/user as mob, def_zone)
	if (!M || !user) // not sure if this is the right thing...
		return
	if (edible && (ishuman(M) || istype(M, /mob/living/critter)))
		if (!Eat(M, user))
			return ..()

	if (flags & SUPPRESSATTACK)
		logTheThing("combat", user, M, "uses [src] ([type], object name: [initial(name)]) on %target%")
		return

	if (user.mind && user.mind.special_role == "vampthrall" && isvampire(M) && user.is_mentally_dominated_by(M))
		boutput(user, "<span style=\"color:red\">You cannot harm your master!</span>") //This message was previously sent to the attacking item. YEP.
		return

	if (user.traitHolder && !user.traitHolder.hasTrait("glasscannon"))
		if (!user.process_stamina(stamina_cost))
			logTheThing("combat", user, M, "tries to attack %target% with [src] ([type], object name: [initial(name)]) but is out of stamina")
			return

	var/obj/item/affecting = M.get_affecting(user, def_zone)
	var/hit_area
	var/d_zone
	if (istype(affecting, /obj/item/organ))
		var/obj/item/organ/O = affecting
		hit_area = parse_zone(O.organ_name)
		d_zone = O.organ_name
	else if (istype(affecting, /obj/item/parts))
		var/obj/item/parts/P = affecting
		hit_area = parse_zone(P.slot)
		d_zone = P.slot
	else
		hit_area = parse_zone(affecting)
		d_zone = affecting

	if (!M.melee_attack_test(user, d_zone))
		logTheThing("combat", user, M, "attacks %target% with [src] ([type], object name: [initial(name)]) but the attack is blocked!")
		return

	if (material)
		material.triggerOnAttack(src, user, M)
	for (var/atom/A in M)
		if (A.material)
			A.material.triggerOnAttacked(A, user, M, src)

	M.violate_hippocratic_oath()

	for (var/mob/V in viewers(world.view, user))
		if (prob(8) && V.traitHolder && V.traitHolder.hasTrait("nervous"))
			if (M != V)
				V.emote("scream")
				V.stunned += 3

	var/attackResults/msgs = new(user)
	msgs.clear(M)
	msgs.played_sound = hitsound
	msgs.affecting = affecting
	msgs.logs = list()
	msgs.logc("attacks %target% with [src] ([type], object name: [initial(name)])")

	var/power = force

	var/attack_resistance = M.check_attack_resistance(src)
	if (attack_resistance)
		power = 0
		if (istext(attack_resistance))
			msgs.show_message_target(attack_resistance)

	msgs.visible_message_target(user.item_attack_message(M, src, hit_area))
	if (damtype == "fire" || damtype == "burn")
		msgs.damage_type = DAMAGE_BURN
	else
		msgs.damage_type = hit_type

	var/armor_mod = 0
	if (d_zone == "head")
		armor_mod = M.get_head_armor_modifier()
	else if (d_zone == "chest")
		armor_mod = M.get_chest_armor_modifier()

	power -= armor_mod

	if (w_class > STAMINA_MIN_WEIGHT_CLASS)
		msgs.stamina_target -= max(stamina_damage - armor_mod, 0)

	if (prob(STAMINA_CRIT_CHANCE))
		msgs.stamina_crit = 1
		msgs.played_sound = "sound/misc/critpunch.ogg"
		msgs.visible_message_target("<span style=\"color:red\"><strong><em>... and lands a devastating hit!</strong></em></span>")

	if (M.traitHolder && M.traitHolder.hasTrait("deathwish"))
		power *= 2

	if (user.traitHolder && user.traitHolder.hasTrait("glasscannon"))
		power *= 2

	msgs.damage = power
	msgs.flush()
	add_fingerprint(user)
	return

/obj/item/onVarChanged(variable, oldval, newval)
	. = 0
	switch(variable)
		if ("color")
			if (wear_image) wear_image.color = newval
			if (inhand_image) inhand_image.color = newval
			. = 1
		if ("alpha")
			if (wear_image) wear_image.alpha = newval
			if (inhand_image) inhand_image.alpha = newval
			. = 1
		if ("blend_mode")
			if (wear_image) wear_image.blend_mode = newval
			if (inhand_image) inhand_image.blend_mode = newval
			. = 1
		if ("icon_state")
			. = 1
		if ("item_state")
			. = 1
		if ("wear_image")
			. = 1
		if ("inhand_image")
			. = 1
	if (. && loc && ismob(loc))
		var/mob/M = loc
		M.update_inhands()

/obj/item/proc/attach(var/mob/living/carbon/human/attachee,var/mob/attacher)
	if (!arm_icon) return

	var/obj/item/parts/human_parts/arm/new_arm = null
	if (attacher.zone_sel.selecting == "l_arm")
		new_arm = new /obj/item/parts/human_parts/arm/left/item(attachee)
		attachee.limbs.l_arm = new_arm
	else
		new_arm = new /obj/item/parts/human_parts/arm/right/item(attachee)
		attachee.limbs.r_arm = new_arm
	if (!new_arm) return //who knows

	new_arm.holder = attachee
	attacher.remove_item(src)
	new_arm.remove_stage = 2

	new_arm:set_item(src)
	cant_drop = 1

	for (var/mob/O in AIviewers(attachee, null))
		if (O == (attacher || attachee))
			continue
		if (attacher == attachee)
			O.show_message("<span style=\"color:red\">[attacher] attaches [src] to \his own stump!</span>", 1)
		else
			O.show_message("<span style=\"color:red\">[attachee] has [src] attached to \his stump by [attacher].</span>", 1)

	if (attachee != attacher)
		boutput(attachee, "<span style=\"color:red\">[attacher] attaches [src] to your stump. It doesn't look very secure!</span>")
		boutput(attacher, "<span style=\"color:red\">You attach [src] to [attachee]'s stump. It doesn't look very secure!</span>")
	else
		boutput(attacher, "<span style=\"color:red\">You attach [src] to your own stump. It doesn't look very secure!</span>")

	attachee.set_body_icon_dirty()

	//qdel(src)

	spawn (rand(150,200))
		if (new_arm.remove_stage == 2) new_arm.remove()

	return

/obj/item/proc/handle_other_remove(var/mob/source, var/mob/living/carbon/human/target)
	//Refactor of the item removal code. Fuck having that shit defined in human.dm >>>>>>:C
	//Return something true (lol byond) to allow removal
	//Return something false to disallow
	return (!cant_other_remove && !cant_drop)

/obj/item/disposing()
	var/turf/T = loc
	if (!istype(T))
		return ..()
	var/area/Ar = T.loc
	if (!(locate(/obj/table) in T) && !(locate(/obj/rack) in T))
		Ar.sims_score = min(Ar.sims_score + 4, 100)

	..()

/obj/item/proc/on_spin_emote(var/mob/living/carbon/human/user as mob)
	if ((user.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(50)) || (user.reagents && prob(user.reagents.get_reagent_amount("ethanol") / 2)) || prob(5))
		user.visible_message("<span style=\"color:red\"><strong>[user] fumbles [src]!</strong></span>")
		throw_impact(user)
	return
	
/obj/item/proc/resinize()
	name = "resin [uncapitalize(name)]"
	color = "#FF00FF"
