/obj/item/cloaking_device
	name = "cloaking device"
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	var/active = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	throwforce = 10.0
	throw_speed = 2
	throw_range = 10
	w_class = 2.0
	is_syndicate = 1
	mats = 15
	desc = "An illegal device that bends light around the user, rendering them invislbe to regular vision."
	stamina_damage = 10
	stamina_cost = 10
	stamina_crit_chance = 15

	attack_self(mob/user as mob)
		add_fingerprint(user)
		if (active)
			user.show_text("The [name] is now inactive.", "blue")
			deactivate(user)
		else
			switch (activate(user))
				if (0)
					user.show_text("You can't have more than one active [name] on your person.", "red")
				if (1)
					user.show_text("The [name] is now active.", "blue")
		return

	proc/activate(mob/user as mob)
		// Multiple active devices can lead to weird effects, okay (Convair880).
		var/list/number_of_devices = list()
		for (var/obj/item/cloaking_device/C in user)
			if (C.active)
				number_of_devices += C
		if (number_of_devices.len > 0)
			return FALSE

		active = 1
		icon_state = "shield1"
		if (user && ismob(user))
			user.update_inhands()
			user.update_clothing()
		return TRUE

	proc/deactivate(mob/user as mob)
		active = 0
		icon_state = "shield0"
		if (user && ismob(user))
			user.update_inhands()
			user.update_clothing()

	// Fix for the backpack exploit. Spawn call is necessary for some reason (Convair880).
	dropped(var/mob/user)
		..()
		spawn (0)
			if (!src) return
			if (!user)
				deactivate()
				return
			if (ismob(loc) && loc == user) // Pockets are okay.
				if (ishuman(user))
					var/mob/living/carbon/human/H = user
					if (H.l_store && H.l_store == src)
						return
					if (H.r_store && H.r_store == src)
						return

			deactivate(user)
			// Need to update other mob sprite when force-equipping the cloak. Not quite sure how and
			// what even calls update_clothing() (giving the other mob invisibility and overlay) BEFORE
			// we set active to 0 here. But yeah, don't comment this out or you'll end up with in-
			// visible dudes equipped with technically inactive cloaking devices.
			deactivate(loc)
			return

	emp_act()
		usr.visible_message("<span style=\"color:blue\"><strong>[usr]'s cloak is disrupted!</strong></span>")
		deactivate(usr)
		return