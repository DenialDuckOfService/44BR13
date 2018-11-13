/puzzlewizard/door
	name = "AB CREATE: Door"
	var/door_name = ""
	var/door_type
	var/color_rgb = ""

	initialize()
		door_type = input("Door type", "Door type", "normal") in list("normal", "glass", "ancient", "shuttle", "wall", "runes")
		color_rgb = input("Color", "Color", "#ffffff") as color
		door_name = input("Door name", "Door name", "[door_type] door") as text
		boutput(usr, "<span style=\"color:blue\">Left click to place doors, right click doors to toggle state. Ctrl+click anywhere to finish.</span>")

	build_click(var/mob/user, var/buildmode_holder/holder, var/list/pa, var/atom/object)
		if (pa.Find("left"))
			var/turf/T = get_turf(object)
			if (pa.Find("ctrl"))
				finished = 1
				return
			if (T)
				var/obj/adventurepuzzle/triggerable/door/door = new /obj/adventurepuzzle/triggerable/door(T)
				door.name = door_name
				door.icon_state = "door_[door_type]_closed"
				door.dir = holder.dir
				door.door_type = door_type
				if (door_type == "glass" || door_type == "runes")
					door.opacity = 0
				spawn (10)
					door.color = color_rgb
		else if (pa.Find("right"))
			if (istype(object, /obj/adventurepuzzle/triggerable/door))
				object:toggle()

/obj/adventurepuzzle/triggerable/door
	name = "door"
	desc = "A doorway that seems to be blocking your path."
	density = 1
	opacity = 1
	var/orig_opacity = 1
	var/secured_open = 0
	var/secured_closed = 0
	anchored = 1
	icon_state = "door_normal_closed"
	var/opening = 0
	var/door_type

	var/static/list/triggeracts = list("Close" = "close", "Do nothing" = "nop", "Lock closed" = "secclose", "Lock open" = "secopen", "Open" = "open", "Toggle" = "toggle", "Unlock" = "unlock")

	trigger_actions()
		return triggeracts

	trigger(var/act)
		switch (act)
			if ("open")
				open()
			if ("close")
				close()
			if ("toggle")
				toggle()
			if ("secclose")
				secured_closed = 1
				close()
			if ("secopen")
				secured_open = 1
				open()
			if ("unlock")
				secured_open = 0
				secured_closed = 0
			else
				return

	Bump(var/atom/A)
		if (ismob(A))
			flick("door_[door_type]_deny", src)

	proc/toggle()
		if (opening)
			return
		if (density)
			open()
		else
			close()

	proc/close()
		if (secured_open)
			return
		if (density)
			return
		if (opening == -1)
			return
		opening = -1
		if (opacity != orig_opacity)
			RL_SetOpacity(orig_opacity)	
		density = 1
		flick("door_[door_type]_closing", src)
		icon_state = "door_[door_type]_closed"			
		spawn (10)
			opening = 0

	proc/open()
		if (secured_closed)
			return
		if (!density)
			return
		if (opening == 1)
			return
		opening = 1
		flick("door_[door_type]_opening", src)
		spawn (10)
			density = 0
			if (opacity != 0)
				orig_opacity = opacity
				RL_SetOpacity(0)
			icon_state = "door_[door_type]_open"
			opening = 0

	attack_hand(mob/user as mob)
		if (density)
			usr.show_message("<span style=\"color:red\">[src] won't open. Perhaps you need a key?</span>")
		flick("door_[door_type]_deny", src)

	serialize(var/savefile/F, var/path, var/sandbox/sandbox)
		..()
		F["[path].orig_opacity"] << orig_opacity
		F["[path].door_type"] << door_type

	deserialize(var/savefile/F, var/path, var/sandbox/sandbox)
		. = ..()
		F["[path].orig_opacity"] >> orig_opacity
		F["[path].door_type"] >> door_type