/obj/screen/ability/critter
	clicked(params)
		var/targetable/critter/spell = owner
		if (!istype(spell))
			return
		if (!spell.holder)
			return
		if (!isturf(usr.loc))
			return
		if (spell.targeted && usr:targeting_spell == owner)
			usr:targeting_spell = null
			usr.update_cursor()
			return
		if (spell.targeted)
			if (world.time < spell.last_cast)
				return
			usr:targeting_spell = owner
			usr.update_cursor()
		else
			spawn
				spell.handleCast()

/abilityHolder/critter
	usesPoints = 0
	regenRate = 0
	tabName = "Abilities"

// ----------------------------------------
// Generic abilities that critters may have
// ----------------------------------------

/targetable/critter
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "template"  // TODO.
	cooldown = 0
	last_cast = 0
	var/disabled = 0
	var/toggled = 0
	var/is_on = 0   // used if a toggle ability
	preferred_holder_type = /abilityHolder/critter

	New()
		var/obj/screen/ability/critter/B = new /obj/screen/ability/critter(null)
		B.icon = icon
		B.icon_state = icon_state
		B.owner = src
		B.name = name
		B.desc = desc
		object = B

	updateObject()
		..()
		if (!object)
			object = new /obj/screen/ability/critter()
			object.icon = icon
			object.owner = src
		if (disabled)
			object.name = "[name] (unavailable)"
			object.icon_state = icon_state + "_cd"
		else if (last_cast > world.time)
			object.name = "[name] ([round((last_cast-world.time)/10)])"
			object.icon_state = icon_state + "_cd"
		else if (toggled)
			if (is_on)
				object.name = "[name] (on)"
				object.icon_state = icon_state
			else
				object.name = "[name] (off)"
				object.icon_state = icon_state + "_cd"
		else
			object.name = name
			object.icon_state = icon_state

	proc/incapacitationCheck()
		var/mob/living/M = holder.owner
		return M.restrained() || M.stat || M.paralysis || M.stunned || M.weakened

	castcheck()
		if (incapacitationCheck())
			boutput(holder.owner, __red("Not while incapacitated."))
			return FALSE
		if (disabled)
			boutput(holder.owner, __red("You cannot use that ability at this time."))
			return FALSE
		return TRUE

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)