/targetable/cruiser/cancel_camera
	name = "Cancel camera view"
	desc = "Cancels your current camera view."
	icon_state = "cancelcam"
	cooldown = 0
	targeted = 0
	target_anything = 0
	dont_lock_holder = 1
	ignore_holder_lock = 1

	cast(atom/target)
		if (..())
			return TRUE

		var/mob/M = holder.owner
		M.set_eye(null)
		M.client.view = world.view
		holder.removeAbility(/targetable/cruiser/cancel_camera)

/targetable/cruiser/exit_pod
	name = "Exit Pod"
	desc = "Exit the pod you are currently in."
	icon_state = "cruiser_exit"
	cooldown = 0
	targeted = 0
	target_anything = 0
	dont_lock_holder = 1 // Dunno about your WIP stuff. Adjust as needed.
	ignore_holder_lock = 1


	cast(atom/target)
		if (..())
			return TRUE

		if (istype(holder.owner.loc, /obj/machinery/cruiser_destroyable/cruiser_pod))
			var/obj/machinery/cruiser_destroyable/cruiser_pod/C = holder.owner.loc
			C.exitPod(holder.owner)

/targetable/cruiser/warp
	name = "Warp"
	desc = "Warp to a beacon."
	icon_state = "warp"
	cooldown = 10
	targeted = 0
	target_anything = 0
	dont_lock_holder = 1
	ignore_holder_lock = 1

	cast(atom/target)
		if (..())
			return TRUE

		var/obj/machinery/cruiser_destroyable/cruiser_pod/C = holder.owner.loc
		var/area/ship_interior/I = C.loc.loc
		var/obj/machinery/cruiser/P = I.ship
		P.warp()

/targetable/cruiser/fire_weapons
	name = "Fire Weapons"
	desc = "Fire the cruisers main weapons at the specified target."
	icon_state = "cruiser_shoot"
	cooldown = 10
	targeted = 1
	target_anything = 1
	sticky = 1
	dont_lock_holder = 1
	ignore_holder_lock = 1

	cast(atom/target)
		if (..())
			return TRUE

		var/obj/machinery/cruiser_destroyable/cruiser_pod/C = holder.owner.loc
		var/area/ship_interior/I = C.loc.loc
		var/obj/machinery/cruiser/P = I.ship
		cooldown = P.fireAt(target)

/targetable/cruiser/shield_overload
	name = "Overload shield (90 Power/5)"
	desc = "Overloads the cruiser's shields, providing increased shield regeneration even during sustained damage, for 15 seconds."
	icon_state = "shieldboost"
	cooldown = 200
	targeted = 0
	target_anything = 0
	dont_lock_holder = 1
	ignore_holder_lock = 1

	cast(atom/target)
		if (..())
			return TRUE

		var/obj/machinery/cruiser_destroyable/cruiser_pod/C = holder.owner.loc
		var/area/ship_interior/I = C.loc.loc
		var/obj/machinery/cruiser/P = I.ship
		P.overload_shields()

/targetable/cruiser/weapon_overload
	name = "Overload weapons (90 Power/5)"
	desc = "Overloads the cruiser's weapons, reducing cooldown times for 10 seconds."
	icon_state = "weaponboost"
	cooldown = 250
	targeted = 0
	target_anything = 0
	dont_lock_holder = 1
	ignore_holder_lock = 1

	cast(atom/target)
		if (..())
			return TRUE

		var/obj/machinery/cruiser_destroyable/cruiser_pod/C = holder.owner.loc
		var/area/ship_interior/I = C.loc.loc
		var/obj/machinery/cruiser/P = I.ship
		P.overload_weapons()

/targetable/cruiser/shield_modulation
	name = "Modulate shields (90 Power, Toggle)"
	desc = "Continually modulates the frequency of the cruiser's shields while active, eliminating the weakness to energy weapons."
	icon_state = "shieldmod"
	cooldown = 10
	targeted = 0
	target_anything = 0
	dont_lock_holder = 1
	ignore_holder_lock = 1

	cast(atom/target)
		if (..())
			return TRUE

		var/obj/machinery/cruiser_destroyable/cruiser_pod/C = holder.owner.loc
		var/area/ship_interior/I = C.loc.loc
		var/obj/machinery/cruiser/P = I.ship
		P.toggleShieldModulation()

/targetable/cruiser/firemode
	name = "Switch fire mode"
	desc = "Changes which weapons fire."
	icon_state = "firemode"
	cooldown = 0
	targeted = 0
	target_anything = 0
	dont_lock_holder = 1
	ignore_holder_lock = 1

	cast(atom/target)
		if (..())
			return TRUE

		var/obj/machinery/cruiser_destroyable/cruiser_pod/C = holder.owner.loc
		var/area/ship_interior/I = C.loc.loc
		var/obj/machinery/cruiser/P = I.ship
		P.switchFireMode()

/targetable/cruiser/ram
	name = "Ramming mode"
	desc = "Enabled ramming mode."
	icon_state = "ram"
	cooldown = 100
	targeted = 0
	target_anything = 0
	dont_lock_holder = 1
	ignore_holder_lock = 1

	cast(atom/target)
		if (..())
			return TRUE

		var/obj/machinery/cruiser_destroyable/cruiser_pod/C = holder.owner.loc
		var/area/ship_interior/I = C.loc.loc
		var/obj/machinery/cruiser/P = I.ship
		P.enableRamming()