var/action_controller/actions = null
//See _setup.dm for interrupt and state definitions

/action_controller
	var/list/running = list() //Associative list of running actions, format: owner=list of action datums

	proc/hasAction(var/atom/owner, var/id) //has this mob an action of a given type running?
		if (running.Find(owner))
			var/list/actions = running[owner]
			for (var/action/A in actions)
				if (A.id == id) return TRUE
		return FALSE

	proc/stop_all(var/atom/owner) //Interrupts all actions of a given owner.
		if (running.Find(owner))
			for (var/action/A in running[owner])
				A.interrupt(INTERRUPT_ALWAYS)
		return

	proc/stop(var/action/A, var/atom/owner) //Manually interrupts a given action of a given owner.
		if (running.Find(owner))
			var/list/actions = running[owner]
			if (actions.Find(A))
				A.interrupt(INTERRUPT_ALWAYS)
		return

	proc/stopId(var/id, var/atom/owner) //Manually interrupts a given action id of a given owner.
		if (running.Find(owner))
			var/list/actions = running[owner]
			for (var/action/A in actions)
				if (A.id == id)
					A.interrupt(INTERRUPT_ALWAYS)
		return

	proc/start(var/action/A, var/atom/owner) //Starts a new action.
		if (!running.Find(owner))
			running.Add(owner)
			running[owner] = list(A)
			A.owner = owner
			A.started = world.time
			A.onStart()
		else
			interrupt(owner, INTERRUPT_ACTION)
			running[owner] += A
			A.owner = owner
			A.started = world.time
			A.onStart()

		return

	proc/interrupt(var/atom/owner, var/flag) //Is called by all kinds of things to check for action interrupts.
		if (running.Find(owner))
			for (var/action/A in running[owner])
				A.interrupt(flag)
		return

	proc/process() //Handles the action countdowns, updates and deletions.
		for (var/X in running)
			for (var/action/A in running[X])

				if ( ((A.duration >= 0 && world.time >= (A.started + A.duration)) && A.state == ACTIONSTATE_RUNNING) || A.state == ACTIONSTATE_FINISH)
					A.state = ACTIONSTATE_ENDED
					A.onEnd()
					//continue //If this is not commented out the deletion will take place the tick after the action ends. This will break things like objects being deleted onEnd with progressbars - the bars will be left behind. But it will look better for things that do not do this.

				if (A.state == ACTIONSTATE_DELETE)
					A.onDelete()
					running[X] -= A
					continue

				A.onUpdate()

			if (length(running[X]) == 0)
				running.Remove(X)
		return

/action
	var/atom/owner = null //Object that owns this action.
	var/duration = 1 //How long does this action take in ticks.
	var/interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION //When and how this action is interrupted.
	var/state = ACTIONSTATE_STOPPED //Current state of the action.
	var/started = -1 //world.time this action was started at
	var/id = "base" //Unique ID for this action. For when you want to remove actions by ID on a person.

	proc/interrupt(var/flag) //This is called by the default interrupt actions
		if (interrupt_flags & flag || flag == INTERRUPT_ALWAYS)
			state = ACTIONSTATE_INTERRUPTED
			onInterrupt(flag)
		return

	proc/onUpdate() //Called every tick this action is running. If you absolutely(!!!) have to you can do manual interrupt checking in here. Otherwise this is mostly used for drawing progress bars and shit.
		return

	proc/onInterrupt(var/flag = 0) //Called when the action fails / is interrupted.
		state = ACTIONSTATE_DELETE
		return

	proc/onStart()				   //Called when the action begins
		state = ACTIONSTATE_RUNNING
		return

	proc/onEnd()				   //Called when the action succesfully ends.
		state = ACTIONSTATE_DELETE
		return

	proc/onDelete()				   //Called when the action is complete and about to be deleted. Usable for cleanup and such.
		return

/action/bar //This subclass has a progressbar that attaches to the owner to show how long we need to wait.
	var/obj/actions/bar/bar
	var/obj/actions/border/border

	onStart()
		..()
		if (owner != null)
			bar = unpool(/obj/actions/bar)
			bar.loc = owner.loc
			border = unpool(/obj/actions/border)
			border.loc = owner.loc
			bar.pixel_y = 5
			border.pixel_y = 5
			owner.attached_objs.Add(bar)
			owner.attached_objs.Add(border)

	onDelete()
		..()
		if (owner != null)
			owner.attached_objs.Remove(bar)
			owner.attached_objs.Remove(border)
		if (bar)
			pool(bar)
			bar = null
		if (border)
			pool(border)
			border = null

	onEnd()
		bar.color = "#00FF00"
		bar.transform = matrix() //Tiny cosmetic fix. Makes it so the bar is completely filled when the action ends.
		bar.pixel_x = 0
		..()

	onInterrupt(var/flag)
		if (state != ACTIONSTATE_DELETE)
			bar.color = "#FF0000"
		..()

	onUpdate()
		var/done = world.time - started
		var/complete = max(min((done / duration), 1), 0)
		bar.transform = matrix(complete, 1, MATRIX_SCALE)
		bar.color = "#0000FF"
		bar.pixel_x = -nround( ((30 - (30 * complete)) / 2) )
		..()

/action/bar/blob_health // WOW HACK
	onUpdate()
		var/obj/blob/B = owner
		if (!owner || !istype(owner))
			return
		if (B.health == B.health_max)
			border.invisibility = 101
			bar.invisibility = 101
		else
			border.invisibility = 0
			bar.invisibility = 0
		var/complete = B.health / B.health_max
		bar.color = "#00FF00"
		bar.transform = matrix(complete, 1, MATRIX_SCALE)
		bar.pixel_x = -nround( ((30 - (30 * complete)) / 2) )

/action/bar/bullethell
	var/obj/actions/bar/shield_bar
	var/obj/actions/bar/armor_bar

	onStart()
		..()
		if (owner != null)
			shield_bar = unpool(/obj/actions/bar)
			shield_bar.loc = owner.loc
			armor_bar = unpool(/obj/actions/bar)
			armor_bar.loc = owner.loc
			shield_bar.pixel_y = 5
			armor_bar.pixel_y = 5
			owner.attached_objs.Add(shield_bar)
			owner.attached_objs.Add(armor_bar)
			shield_bar.layer = initial(shield_bar.layer) + 2
			armor_bar.layer = initial(armor_bar.layer) + 1

	onDelete()
		..()
		shield_bar.invisibility = 0
		armor_bar.invisibility = 0
		bar.invisibility = 0
		border.invisibility = 0
		if (owner != null)
			owner.attached_objs.Remove(shield_bar)
			owner.attached_objs.Remove(armor_bar)
		pool(shield_bar)
		shield_bar = null
		pool(armor_bar)
		armor_bar = null

	onUpdate()
		var/obj/bullethell/B = owner
		if (!owner || !istype(owner))
			return
		var/h_complete = B.health / B.max_health
		bar.color = "#00FF00"
		bar.transform = matrix(h_complete, 1, MATRIX_SCALE)
		bar.pixel_x = -nround( ((30 - (30 * h_complete)) / 2) )
		if (B.max_armor && B.armor)
			armor_bar.invisibility = 0
			var/a_complete = B.armor / B.max_armor
			armor_bar.color = "#FF8800"
			armor_bar.transform = matrix(a_complete, 1, MATRIX_SCALE)
			armor_bar.pixel_x = -nround( ((30 - (30 * a_complete)) / 2) )
		else
			armor_bar.invisibility = 101
		if (B.max_shield && B.shield)
			shield_bar.invisibility = 0
			var/s_complete = B.shield / B.max_shield
			shield_bar.color = "#3333FF"
			shield_bar.transform = matrix(s_complete, 1, MATRIX_SCALE)
			shield_bar.pixel_x = -nround( ((30 - (30 * s_complete)) / 2) )
		else
			shield_bar.invisibility = 101


/action/bar/blob_replicator
	onUpdate()
		var/obj/blob/deposit/replicator/B = owner
		if (!owner)
			return
		if (!B.converting || (B.converting && !B.converting.maximum_volume))
			border.invisibility = 101
			bar.invisibility = 101
			return
		else
			border.invisibility = 0
			bar.invisibility = 0
		var/complete = 1 - (B.converting.total_volume / B.converting.maximum_volume)
		bar.color = "#0000FF"
		bar.transform = matrix(complete, 1, MATRIX_SCALE)
		bar.pixel_x = -nround( ((30 - (30 * complete)) / 2) )

	onDelete()
		bar.invisibility = 0
		border.invisibility = 0
		..()

/action/bar/icon //Visible to everyone and has an icon.
	var/icon
	var/icon_state
	var/icon_y_off = 20
	var/icon_x_off = 0
	var/image/icon_image

	onStart()
		..()
		if (icon && icon_state && owner)
			icon_image = image(icon, border ,icon_state, 7)
			icon_image.pixel_y = icon_y_off
			icon_image.pixel_x = icon_x_off
			border.overlays += icon_image

	onDelete()
		bar.overlays.Cut()
		del(icon_image)
		..()

/action/bar/icon/build
	duration = 30
	var/obj/item/sheet/sheet
	var/objtype
	var/cost
	var/material/mat
	var/amount
	var/objname
	var/callback = null

	New(var/obj/item/sheet/csheet, var/cobjtype, var/ccost, var/material/cmat, var/camount, var/cicon, var/cicon_state, var/cobjname, var/post_action_callback = null)
		..()
		icon = cicon
		icon_state = cicon_state
		sheet = csheet
		objtype = cobjtype
		cost = ccost
		mat = cmat
		amount = camount
		objname = cobjname
		callback = post_action_callback

	onStart()
		..()
		if (istype(owner, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter"))
				duration = round(duration / 2)

		owner.visible_message("<span style=\"color:blue\">[owner] begins assembling [objname]!</span>")

	onEnd()
		..()
		owner.visible_message("<span style=\"color:blue\">[owner] assembles [objname]!</span>")
		var/obj/item/R = new objtype(get_turf(owner))
		R.setMaterial(mat)
		if (istype(R))
			R.amount = amount
		R.dir = owner.dir
		sheet.consume_sheets(cost)
		logTheThing("station", owner, null, "builds [objname] (<strong>Material:</strong> [mat && istype(mat) && mat.mat_id ? "[mat.mat_id]" : "*UNKNOWN*"]) at [log_loc(owner)].")
		if (callback)
			call(callback)(src, R)

/action/bar/icon/cruiser_repair
	id = "genproc"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 30
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/machinery/cruiser_destroyable/repairing
	var/obj/item/using

	New(var/obj/machinery/cruiser_destroyable/D, var/obj/item/U, var/duration_i)
		..()
		repairing = D
		using = U
		duration = duration_i

	onUpdate()
		..()
		if (get_dist(owner, repairing) > 1 || repairing == null || owner == null || using == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/mob/source = owner
		if (using != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		owner.visible_message("<span style=\"color:blue\">[owner] begins repairing [repairing]!</span>")

	onEnd()
		..()
		owner.visible_message("<span style=\"color:blue\">[owner] successfully repairs [repairing]!</span>")
		repairing.adjustHealth(repairing.health_max)

/action/bar/private //This subclass is only visible to the owner of the action
	onStart()
		..()
		bar.icon = null
		border.icon = null
		owner << bar.img
		owner << border.img

	onDelete()
		bar.icon = 'icons/ui/actions.dmi'
		border.icon = 'icons/ui/actions.dmi'
		del(bar.img)
		del(border.img)
		..()

/action/bar/private/icon //Only visible to the owner and has a little icon on the bar.
	var/icon
	var/icon_state
	var/icon_y_off = 25
	var/icon_x_off = 0
	var/image/icon_image

	onStart()
		..()
		if (icon && icon_state && owner)
			icon_image = image(icon ,owner,icon_state,7)
			icon_image.pixel_y = icon_y_off
			icon_image.pixel_x = icon_x_off
			owner << icon_image

	onDelete()
		del(icon_image)
		..()

//ACTIONS
/action/bar/icon/genericProc //Calls a specific proc with the given arguments when the action succeeds. TBI
	id = "genproc"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"

/action/bar/icon/otherItem//Putting items on or removing items from others.
	id = "otheritem"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"

	var/mob/living/carbon/human/source  //The person doing the action
	var/mob/living/carbon/human/target  //The target of the action
	var/obj/item/item				    //The item if any. If theres no item, we tried to remove something from that slot instead of putting an item there.
	var/slot						    //The slot number

	New(var/Source, var/Target, var/Item, var/Slot)
		source = Source
		target = Target
		item = Item
		slot = Slot

		if (item)
			if (item.duration_put > 0)
				duration = item.duration_put
			else
				duration = 45
		else
			var/obj/item/I = target.get_slot(slot)
			if (I)
				if (I.duration_remove > 0)
					duration = I.duration_remove
				else
					duration = 25
		..()

	onStart()
		..()

		target.add_fingerprint(source) // Added for forensics (Convair880).

		if (item)
			if (!target.can_equip(item, slot))
				boutput(source, "<span style=\"color:red\">[item] can not be put there.</span>")
				interrupt(INTERRUPT_ALWAYS)
				return
			logTheThing("combat", source, target, "tries to put \an [item] on %target% at at [log_loc(target)].")
			for (var/mob/O in AIviewers(owner))
				O.show_message("<span style=\"color:red\"><strong>[source] tries to put [item] on [target]!</strong></span>", 1)
		else
			var/obj/item/I = target.get_slot(slot)

			if (!I)
				boutput(source, "<span style=\"color:red\">There's nothing in that slot.</span>")
				interrupt(INTERRUPT_ALWAYS)
				return
			/* Some things use handle_other_remove to do stuff (ripping out staples, wiz hat probability, etc) should only be called once per removal.
			if (!I.handle_other_remove(source, target))
				boutput(source, "<span style=\"color:red\">[I] can not be removed.</span>")
				interrupt(INTERRUPT_ALWAYS)
				return
			*/

			logTheThing("combat", source, target, "tries to remove \an [I] from %target% at [log_loc(target)].")

			for (var/mob/O in AIviewers(owner))
				O.show_message("<span style=\"color:red\"><strong>[source] tries to remove something from [target]!</strong></span>", 1)

	onEnd()
		..()

		if (get_dist(source, target) > 1 || target == null || source == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/obj/item/I = target.get_slot(slot)

		if (item)
			if (item == source.equipped() && !I)
				if (target.can_equip(item, slot))
					logTheThing("combat", source, target, "successfully puts \an [item] on %target% at at [log_loc(target)].")
					for (var/mob/O in AIviewers(owner))
						O.show_message("<span style=\"color:red\"><strong>[source] puts [item] on [target]!</strong></span>", 1)
					source.u_equip(item)
					target.force_equip(item, slot)
		else if (I) //Wire: Fix for Cannot execute null.handle other remove().
			if (I.handle_other_remove(source, target))
				logTheThing("combat", source, target, "successfully removes \an [I] from %target% at [log_loc(target)].")
				for (var/mob/O in AIviewers(owner))
					O.show_message("<span style=\"color:red\"><strong>[source] removes [I] from [target]!</strong></span>", 1)

				// Re-added (Convair880).
				if (istype(I, /obj/item/mousetrap))
					var/obj/item/mousetrap/MT = I
					if (MT && MT.armed)
						for (var/mob/O in AIviewers(owner))
							O.show_message("<span style=\"color:red\"><strong>...and triggers it accidentally!</strong></span>", 1)
						MT.triggered(source, source.hand ? "l_hand" : "r_hand")
				else if (istype(I, /obj/item/mine))
					var/obj/item/mine/M = I
					if (M.armed && M.used_up != 1)
						for (var/mob/O in AIviewers(owner))
							O.show_message("<span style=\"color:red\"><strong>...and triggers it accidentally!</strong></span>", 1)
						M.triggered(source)

				target.u_equip(I)
				I.set_loc(target.loc)
				I.dropped(target)
				I.layer = initial(I.layer)
				I.add_fingerprint(source)
			else
				boutput(source, "<span style=\"color:red\">You fail to remove [I] from [target].</span>")
	onUpdate()
		..()
		if (get_dist(source, target) > 1 || target == null || source == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (item)
			if (item != source.equipped() || target.get_slot(slot))
				interrupt(INTERRUPT_ALWAYS)
		else
			if (!target.get_slot(slot=slot))
				interrupt(INTERRUPT_ALWAYS)

/action/bar/icon/internalsOther //This is used when you try to set someones internals
	duration = 40
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "internalsother"
	icon = 'icons/obj/clothing/item_masks.dmi'
	icon_state = "breath"
	var/mob/living/carbon/human/target
	var/remove_internals

	New(Target)
		target = Target
		..()

	onUpdate()
		..()
		if (get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if (get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		for (var/mob/O in AIviewers(owner))
			if (target.internal)
				O.show_message("<span style=\"color:red\"><strong>[owner] attempts to remove [target]'s internals!</strong></span>", 1)
				remove_internals = 1
			else
				O.show_message("<span style=\"color:red\"><strong>[owner] attempts to set [target]'s internals!</strong></span>", 1)
				remove_internals = 0
	onEnd()
		..()
		if (owner && target && get_dist(owner, target) <= 1)
			if (remove_internals)
				target.internal.add_fingerprint(owner)
				for (var/obj/ability_button/tank_valve_toggle/T in target.internal.ability_buttons)
					T.icon_state = "airoff"
				target.internal = null
				for (var/mob/O in AIviewers(owner))
					O.show_message("<span style=\"color:red\"><strong>[owner] removes [target]'s internals!</strong></span>", 1)
			else
				if (!istype(target.wear_mask, /obj/item/clothing/mask))
					interrupt(INTERRUPT_ALWAYS)
					return
				else
					if (istype(target.back, /obj/item/tank))
						target.internal = target.back
						for (var/obj/ability_button/tank_valve_toggle/T in target.internal.ability_buttons)
							T.icon_state = "airon"
						for (var/mob/M in AIviewers(target, 1))
							M.show_message(text("[] is now running on internals.", target), 1)
						target.internal.add_fingerprint(owner)

/action/bar/icon/handcuffSet //This is used when you try to handcuff someone.
	duration = 40
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "handcuffsset"
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	var/mob/living/carbon/human/target
	var/obj/item/handcuffs/cuffs

	New(Target, Cuffs)
		target = Target
		cuffs = Cuffs
		..()

	onUpdate()
		..()
		if (get_dist(owner, target) > 1 || target == null || owner == null || cuffs == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (target.handcuffed)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if (get_dist(owner, target) > 1 || target == null || owner == null || cuffs == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		for (var/mob/O in AIviewers(owner))
			O.show_message("<span style=\"color:red\"><strong>[owner] attempts to handcuff [target]!</strong></span>", 1)

	onEnd()
		..()
		var/mob/ownerMob = owner
		if (owner && ownerMob && target && cuffs && !target.handcuffed && cuffs == ownerMob.equipped() && get_dist(owner, target) <= 1)

			var/obj/item/handcuffs/cuffs2

			if (issilicon(ownerMob))
				cuffs2 = new /obj/item/handcuffs
			else
				if (cuffs.amount >= 2)
					cuffs2 = new /obj/item/handcuffs/tape
					cuffs.amount--
					boutput(ownerMob, "<span style=\"color:blue\">The [cuffs.name] now has [cuffs.amount] lengths of [istype(cuffs, /obj/item/handcuffs/tape_roll) ? "tape" : "ziptie"] left.</span>")
				else if (cuffs.amount == 1 && cuffs.delete_on_last_use == 1)
					cuffs2 = new /obj/item/handcuffs/tape
					ownerMob.u_equip(cuffs)
					boutput(ownerMob, "<span style=\"color:red\">You used up the remaining length of [istype(cuffs, /obj/item/handcuffs/tape_roll) ? "tape" : "ziptie"].</span>")
					qdel(cuffs)
				else
					ownerMob.u_equip(cuffs)

			logTheThing("combat", ownerMob, target, "handcuffs %target% with [cuffs2 ? "[cuffs2]" : "[cuffs]"] at [log_loc(ownerMob)].")

			if (cuffs2 && istype(cuffs2))
				cuffs2.set_loc(target)
				target.handcuffed = cuffs2
			else
				cuffs.set_loc(target)
				target.handcuffed = cuffs
			target.drop_from_slot(target.r_hand)
			target.drop_from_slot(target.l_hand)
			target.drop_juggle()
			target.update_clothing()

			for (var/mob/O in AIviewers(ownerMob))
				O.show_message("<span style=\"color:red\"><strong>[owner] handcuffs [target]!</strong></span>", 1)

/action/bar/icon/handcuffRemovalOther //This is used when you try to remove someone elses handcuffs.
	duration = 70
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "handcuffsother"
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	var/mob/living/carbon/human/target

	New(Target)
		target = Target
		..()

	onUpdate()
		..()
		if (get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!target.handcuffed)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if (get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		for (var/mob/O in AIviewers(owner))
			O.show_message("<span style=\"color:red\"><strong>[owner] attempts to remove [target]'s handcuffs!</strong></span>", 1)

	onEnd()
		..()
		if (owner && target && target.handcuffed)
			var/mob/living/carbon/human/H = target
			H.handcuffed:set_loc(H.loc)
			H.handcuffed.unequipped(H)
			H.handcuffed = null
			H.update_clothing()
			for (var/mob/O in AIviewers(H))
				O.show_message("<span style=\"color:red\"><strong>[owner] manages to remove [target]'s handcuffs!</strong></span>", 1)

/action/bar/private/icon/handcuffRemoval //This is used when you try to resist out of handcuffs.
	duration = 600
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "handcuffs"
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"

	New(var/dur)
		duration = dur
		..()

	onStart()
		..()
		for (var/mob/O in AIviewers(owner))
			O.show_message(text("<span style=\"color:red\"><strong>[] attempts to remove the handcuffs!</strong></span>", owner), 1)

	onInterrupt(var/flag)
		..()
		boutput(owner, "<span style=\"color:red\">Your attempt to remove your handcuffs was interrupted!</span>")

	onEnd()
		..()
		if (owner != null && istype(owner, /mob/living/carbon/human) && owner:handcuffed)
			var/mob/living/carbon/human/H = owner
			H.handcuffed:set_loc(H.loc)
			H.handcuffed.unequipped(H)
			H.handcuffed = null
			H.update_clothing()
			if (H.handcuffed)
				H.handcuffed.layer = initial(H.handcuffed.layer)
			for (var/mob/O in AIviewers(H))
				O.show_message("<span style=\"color:red\"><strong>[H] manages to remove the handcuffs!</strong></span>", 1)
			boutput(H, "<span style=\"color:blue\">You successfully remove your handcuffs.</span>")

/action/bar/private/icon/shackles_removal // Resisting out of shackles (Convair880).
	duration = 450
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "shackles"
	icon = 'icons/obj/clothing/item_shoes.dmi'
	icon_state = "orange1"

	New(var/dur)
		duration = dur
		..()

	onStart()
		..()
		for (var/mob/O in AIviewers(owner))
			O.show_message(text("<span style=\"color:red\"><strong>[] attempts to remove the shackles!</strong></span>", owner), 1)

	onInterrupt(var/flag)
		..()
		boutput(owner, "<span style=\"color:red\">Your attempt to remove the shackles was interrupted!</span>")

	onEnd()
		..()
		if (owner != null && ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.shoes && H.shoes.chained)
				var/obj/item/clothing/shoes/SH = H.shoes
				H.u_equip(SH)
				SH.set_loc(H.loc)
				H.update_clothing()
				if (SH)
					SH.layer = initial(SH.layer)
				for (var/mob/O in AIviewers(H))
					O.show_message("<span style=\"color:red\"><strong>[H] manages to remove the shackles!</strong></span>", 1)
				H.show_text("You successfully remove the shackles.", "blue")

//CLASSES & OBJS

/obj/actions //These objects are mostly used for the attached_objs var on mobs to attach progressbars to mobs.
	icon = 'icons/ui/actions.dmi'
	anchored = 1
	density = 0
	opacity = 0
	layer = 5
	name = ""
	desc = ""
	mouse_opacity = 0

/obj/actions/bar
	icon_state = "bar"
	layer = 6
	var/image/img
	New()
		img = image('icons/ui/actions.dmi',src,"bar",6)

	unpooled()
		img = image('icons/ui/actions.dmi',src,"bar",6)
		icon = initial(icon)
		icon_state = initial(icon_state)

	pooled()
		loc = null
		attached_objs = list()
		overlays.len = 0

/obj/actions/border
	icon_state = "border"
	var/image/img
	New()
		img = image('icons/ui/actions.dmi',src,"border",5)

	unpooled()
		img = image('icons/ui/actions.dmi',src,"border",5)
		icon = initial(icon)
		icon_state = initial(icon_state)

	pooled()
		loc = null
		attached_objs = list()
		overlays.len = 0

//Use this to start the action
//actions.start(new/action/bar/private/icon/magPicker(item, picker), usr)
/action/bar/private/icon/magPicker
	duration = 30 //How long does this action take in ticks.
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "magpicker"
	icon = 'icons/obj/items.dmi' //In these two vars you can define an icon you want to have on your little progress bar.
	icon_state = "magtractor-small"

	var/obj/item/target = null //This will contain the object we are trying to pick up.
	var/obj/item/magtractor/picker = null //This is the magpicker.

	New(Target, Picker)
		target = Target
		picker = Picker
		..()

	onUpdate() //check for special conditions that could interrupt the picking-up here.
		..()
		if (get_dist(owner, target) > 1 || picker == null || target == null || owner == null) //If the thing is suddenly out of range, interrupt the action. Also interrupt if the user or the item disappears.
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if (get_dist(owner, target) > 1 || picker == null || target == null || owner == null || picker.working)  //If the thing is out of range, interrupt the action. Also interrupt if the user or the item disappears.
			interrupt(INTERRUPT_ALWAYS)
			return
		else
			picker.working = 1
			playsound(picker.loc, "sound/machines/whistlebeep.ogg", 50, 1)
			out(owner, "<span style='color: blue;'>The [picker.name] whirs and beeps as it charges it's coils. You must hold still...</span>")

	onInterrupt(var/flag) //They did something else while picking it up. I guess you dont have to do anything here unless you want to.
		..()
		picker.working = 0

	onEnd()
		..()
		//Shove the item into the picker here!!!
		picker.pickupItem(target, owner)
		actions.start(new/action/magPickerHold(picker, picker.highpower), owner)


/action/magPickerHold
	duration = 30
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
	id = "magpickerhold"

	var/obj/item/magtractor/picker = null //This is the magpicker.

	New(Picker, hpm)
		if (hpm)
			interrupt_flags &= ~INTERRUPT_MOVE
		picker = Picker
		picker.holdAction = src
		..()

	onUpdate() //Again, check here for special conditions that are not normally handled in here. You probably dont need to do anything.
		..()
		if (picker == null || owner == null) //Interrupt if the user or the magpicker disappears.
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		state = ACTIONSTATE_INFINITE //We can hold it indefinitely unless we move.
		if (picker == null || owner == null) //Interrupt if the user or the magpicker dont exist.
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		picker.dropItem()

	onInterrupt(var/flag)
		..()
		picker.dropItem()

//DEBUG STUFF

/action/bar/private/bombtest
	duration = 100
	id = "bombtest"

	onEnd()
		..()
		qdel(owner)

/obj/bombtest
	name = "large cartoon bomb"
	desc = "It looks like it's gonna blow."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "dumb_bomb"
	density = 1

	New()
		actions.start(new/action/bar/private/bombtest(), src)
		..()