/*
CONTAINS:
RODS
METAL
REINFORCED METAL
MATERIAL

*/

/proc/window_reinforce_callback(var/action/bar/icon/build/B, var/obj/window/reinforced/W)
	W.ini_dir = 2
	if (!istype(W) || !usr) //Wire: Fix for Cannot read null.loc (|| !usr)
		return
	if (B.sheet.reinforcement)
		W.set_reinforcement(B.sheet.reinforcement)
		if (map_setting && map_setting == "COG2")
			W = new /obj/window/auto/reinforced(usr.loc)
		else
			W = new /obj/window/reinforced(usr.loc)

/proc/window_reinforce_full_callback(var/action/bar/icon/build/B, var/obj/window/reinforced/W)
	W.dir = SOUTHWEST
	W.ini_dir = SOUTHWEST
	if (!istype(W))
		return
	if (!usr) //Wire: Fix for Cannot read null.loc
		return
	if (B.sheet.reinforcement)
		W.set_reinforcement(B.sheet.reinforcement)
		if (map_setting && map_setting == "COG2")
			W = new /obj/window/auto/reinforced(usr.loc)
		else
			W = new /obj/window/reinforced(usr.loc)

/obj/item/sheet
	name = "sheet"
	icon = 'icons/obj/metal.dmi'
	icon_state = "sheet"
	desc = "Thin sheets of building material. Can be used to build many things."
	flags = FPRINT | TABLEPASS
	throwforce = 5.0
	throw_speed = 1
	throw_range = 4
	w_class = 3.0
	max_stack = 50
	stamina_damage = 30
	stamina_cost = 30
	stamina_crit_chance = 10
	var/material/reinforcement = null
	module_research = list("metals" = 5)
	rand_pos = 1

	New()
		..()
		spawn (0)
			update_appearance()

	proc/amount_check(var/use_amount,var/mob/user)
		if (amount < use_amount)
			if (user)
				boutput(user, "<span style=\"color:red\">You need at least [use_amount] sheets to do that.</span>")
			return FALSE
		else
			return TRUE

	proc/consume_sheets(var/use_amount)
		if (!isnum(amount))
			return
		amount = max(0,amount - use_amount)
		if (amount < 1)
			if (istype(loc,/mob/living))
				var/mob/living/L = loc
				L.u_equip(src)
				L << browse(null, "window=met_sheet")
				onclose(L, "met_sheet")
			qdel(src)
		return

	proc/set_reinforcement(var/material/M)
		if (!istype(M))
			return
		reinforcement = M
		update_appearance()

	onMaterialChanged()
		..()
		update_appearance()

	proc/update_appearance()
		name = initial(name)
		icon_state = initial(icon_state)
		if (istype(material))
			if (src.material.material_flags & MATERIAL_CRYSTAL)
				icon_state += "-g"
			else
				icon_state += "-m"
			name = "[material.name] " + name
			if (istype(reinforcement))
				name = "[reinforcement.name]-reinforced " + name
				icon_state += "-r"
			color = material.color
			alpha = material.alpha

	attack_hand(mob/user as mob)
		if ((user.r_hand == src || user.l_hand == src) && amount > 1)
			var/splitnum = round(input("How many sheets do you want to take from the stack?","Stack of [amount]",1) as num)
			var/diff = amount - splitnum
			if (splitnum >= amount || splitnum < 1)
				boutput(user, "<span style=\"color:red\">Invalid entry, try again.</span>")
				return
			boutput(usr, "<span style=\"color:blue\">You take [splitnum] sheets from the stack, leaving [diff] sheets behind.</span>")
			amount = diff
			var/obj/item/sheet/new_stack = new /obj/item/sheet(get_turf(usr))
			if (material)
				new_stack.setMaterial(material)
			new_stack.amount = splitnum
			new_stack.attack_hand(user)
			new_stack.add_fingerprint(user)
			new_stack.update_appearance()
		else
			..(user)

	attackby(obj/item/W, mob/user as mob)
		if (istype(W, /obj/item/sheet))
			var/obj/item/sheet/S = W
			if (S.material && src.material && (S.material.mat_id != src.material.mat_id))
				boutput(user, "<span style=\"color:red\">You can't mix different materials!</span>")
				return
			if (S.reinforcement && src.reinforcement && (S.reinforcement.mat_id != src.reinforcement.mat_id))
				boutput(user, "<span style=\"color:red\">You can't mix different reinforcements!</span>")
				return
			if (S.amount >= max_stack)
				boutput(user, "<span style=\"color:red\">You can't put any more sheets in this stack!</span>")
				return
			if (S.amount + amount > max_stack)
				amount = S.amount + amount - max_stack
				S.amount = max_stack
				boutput(user, "<span style=\"color:blue\">You add [S] to the stack. It now has [S.amount] sheets.</span>")
			else
				S.amount += amount
				boutput(user, "<span style=\"color:blue\">You add [S] to the stack. It now has [S.amount] sheets.</span>")
				//SN src = null
				qdel(src)
				return

		else if (istype(W,/obj/item/rods))
			var/obj/item/rods/R = W
			if (reinforcement)
				boutput(user, "<span style=\"color:red\">That's already reinforced!</span>")
				return
			if (!R.material)
				boutput(user, "<span style=\"color:red\">These rods won't work for reinforcing.</span>")
				return

			if (src.material && (src.material.material_flags & MATERIAL_METAL || src.material.material_flags & MATERIAL_CRYSTAL))
				var/makesheets = min(min(R.amount,amount),50)
				var/sheetsinput = input("Reinforce how many sheets?","Min: 1, Max: [makesheets]",1) as num
				if (sheetsinput < 1)
					return
				sheetsinput = min(sheetsinput,makesheets)

				var/obj/item/sheet/S = new /obj/item/sheet(get_turf(user))
				S.setMaterial(material)
				S.set_reinforcement(R.material)
				S.amount = sheetsinput
				R.consume_rods(sheetsinput)
				consume_sheets(sheetsinput)
			else
				boutput(user, "<span style=\"color:red\">You may only reinforce metal or crystal sheets.</span>")
				return
		else
			..()
		return

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span style=\"color:blue\">[user] begins gathering up [src]!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span style=\"color:blue\">You finish gathering sheets.</span>")

	check_valid_stack(atom/movable/O as obj)
		if (!istype(O,/obj/item/sheet))
			//boutput(world, "check valid stack check 1 failed")
			return FALSE
		var/obj/item/sheet/S = O
		if (!S.material)
			return FALSE
		if (S.material.type != src.material.type)
			//boutput(world, "check valid stack check 2 failed")
			return FALSE
		if (S.material && src.material && (S.material.mat_id != src.material.mat_id))
			//boutput(world, "check valid stack check 3 failed")
			return FALSE
		if ((reinforcement && !S.reinforcement) || (S.reinforcement && !reinforcement))
			//boutput(world, "check valid stack check 4 failed")
			return FALSE
		if (reinforcement && S.reinforcement)
			if (src.reinforcement.type != S.reinforcement.type)
				//boutput(world, "check valid stack check 5 failed")
				return FALSE
			if (S.reinforcement.mat_id != src.reinforcement.mat_id)
				//boutput(world, "check valid stack check 6 failed")
				return FALSE
		return TRUE

	examine()
		set src in view(1)

		..()
		boutput(usr, text("There are [] sheet\s on the stack.", amount))
		return

	attack_self(mob/user as mob)
		var/t1 = text("<HTML><HEAD></HEAD><TT>Amount Left: [] <BR>", amount)
		var/counter = 1
		var/list/L = list(  )
		if (src.material && src.material.material_flags & MATERIAL_METAL)
			if (istype(reinforcement))
				L["retable"] = "Reinforced Table Parts (2 Sheets)"
				L["remetal"] = "Remove Reinforcement"
			else
				L["fl_tiles"] = "x4 Floor Tile"
				L["rods"] = "x2 Rods"
				L["rack"] = "Rack Parts"
				L["stool"] = "stool"
				L["chair"] = "chair"
				L["table"] = "Table Parts (2 Sheets)"
				L["light"] = "Light Fixture Parts, Tube (2 Sheets)"
				L["light2"] = "Light Fixture Parts, Bulb (2 Sheets)"
				L["bed"] = "Bed (2 Sheets)"
				L["closet"] = "Closet (2 Sheets)"
				L["construct"] = "Wall Girders (2 Sheets)"
				L["pipef"] = "Pipe Frame (3 Sheets)"
				L["tcomputer"] = "Computer Terminal Frame (3 Sheets)"
				L["computer"] = "Console Frame (5 Sheets)"
				L["hcomputer"] = "Computer Frame (5 Sheets)"
		if (src.material && src.material.material_flags & MATERIAL_CRYSTAL)
			L["smallwindow"] = "Thin Window"
			L["bigwindow"] = "Large Window (2 Sheets)"

		for (var/t in L)
			counter++
			t1 += text("<A href='?src=\ref[];make=[]'>[]</A>  ", src, t, L[t])
			if (counter > 2)
				counter = 1
			t1 += "<BR>"

		t1 += "</TT></HTML>"
		user << browse(t1, "window=met_sheet")
		onclose(user, "met_sheet")
		return

	Topic(href, href_list)
		..()
		if (usr.restrained() || usr.stat)
			if (!istype(usr, /mob/living/silicon/robot))
				return

		//Magtractor holding metal check
		var/atom/equipped = usr.equipped()
		if (equipped != src)
			if (istype(equipped, /obj/item/magtractor) && equipped:holding)
				if (equipped:holding != src)
					return
			else
				return

		if (href_list["make"])
			if (amount < 1)
				consume_sheets(1)
				return

			var/a_type = null
			var/a_amount = 1
			var/a_cost = 1
			var/a_icon = null
			var/a_icon_state = null
			var/a_name = null
			var/a_callback = null

			switch(href_list["make"])
				if ("rods")
					var/makerods = min(amount,25)
					var/rodsinput = input("Use how many sheets? (Get 2 rods for each sheet used)","Min: 2, Max: [makerods]",1) as num
					if (rodsinput < 1) return
					rodsinput = min(rodsinput,makerods)

					a_type = /obj/item/rods
					a_amount = rodsinput * 2
					a_cost = rodsinput
					a_icon = 'icons/obj/metal.dmi'
					a_icon_state = "rods"
					a_name = "rods"

				if ("fl_tiles")
					var/maketiles = min(amount,20)
					var/tileinput = input("Use how many sheets? (Get 4 tiles for each sheet used)","Max: [maketiles]",1) as num
					if (tileinput < 1) return
					tileinput = min(tileinput,maketiles)

					a_type = /obj/item/tile
					a_amount = tileinput * 4
					a_cost = tileinput
					a_icon = 'icons/obj/metal.dmi'
					a_icon_state = "tile"
					a_name = "floor tiles"

				if ("table")
					if (!amount_check(2,usr)) return

					a_type = /obj/item/table_parts
					a_amount = 1
					a_cost = 2
					a_icon = 'icons/obj/metal.dmi'
					a_icon_state = "table_parts"
					a_name = "table parts"

				if ("light")
					if (!amount_check(2,usr)) return

					a_type = /obj/item/light_parts
					a_amount = 1
					a_cost = 2
					a_icon = 'icons/obj/lighting.dmi'
					a_icon_state = "tube-fixture"
					a_name = "a light tube fixture"

				// Added (Convair880).
				if ("light2")
					if (!amount_check(2,usr)) return

					a_type = /obj/item/light_parts/bulb
					a_amount = 1
					a_cost = 2
					a_icon = 'icons/obj/lighting.dmi'
					a_icon_state = "bulb-fixture"
					a_name = "a light bulb fixture"

				if ("stool")
					a_type = /obj/stool
					a_amount = 1
					a_cost = 1
					a_icon = 'icons/obj/objects.dmi'
					a_icon_state = "stool"
					a_name = "a stool"

				if ("chair")
					a_type = /obj/stool/chair
					a_amount = 1
					a_cost = 1
					a_icon = 'icons/obj/objects.dmi'
					a_icon_state = "chair"
					a_name = "a chair"

				if ("rack")
					a_type = /obj/item/rack_parts
					a_amount = 1
					a_cost = 1
					a_icon = 'icons/obj/metal.dmi'
					a_icon_state = "rack_parts"
					a_name = "rack parts"

				if ("closet")
					if (!amount_check(2,usr)) return
					a_type = /obj/storage/closet
					a_amount = 1
					a_cost = 2
					a_icon = 'icons/obj/closet.dmi'
					a_icon_state = "closed"
					a_name = "a closet"

				if ("pipef")
					if (!amount_check(3,usr)) return
					a_type = /obj/item/pipebomb/frame
					a_amount = 1
					a_cost = 3
					a_icon = 'icons/obj/assemblies.dmi'
					a_icon_state = "Pipe_Frame"
					a_name = "a pipe frame"

				if ("bed")
					if (!amount_check(2,usr)) return
					a_type = /obj/stool/bed
					a_amount = 1
					a_cost = 2
					a_icon = 'icons/obj/objects.dmi'
					a_icon_state = "bed"
					a_name = "a bed"

				if ("computer")
					if (!amount_check(5,usr)) return
					a_type = /obj/computerframe
					a_amount = 1
					a_cost = 5
					a_icon = 'icons/obj/computer_frame.dmi'
					a_icon_state = "0"
					a_name = "a console frame"

				if ("hcomputer")
					if (!amount_check(5,usr)) return
					a_type = /obj/computer3frame
					a_amount = 1
					a_cost = 5
					a_icon = 'icons/obj/computer_frame.dmi'
					a_icon_state = "0"
					a_name = "a computer frame"

				if ("tcomputer")
					if (!amount_check(3,usr)) return
					a_type = /obj/computer3frame/terminal
					a_amount = 1
					a_cost = 3
					a_icon = 'icons/obj/terminal_frame.dmi'
					a_icon_state = "0"
					a_name = "a terminal frame"

				if ("construct")
					var/turf/T = get_turf(usr)
					if (!istype(T, /turf/simulated/floor))
						boutput(usr, "<span style=\"color:red\">You can't build girders here.</span>")
						return
					if (!amount_check(2,usr)) return
					a_type = /obj/structure/girder
					a_amount = 1
					a_cost = 2
					a_icon = 'icons/obj/structures.dmi'
					a_icon_state = "girder"
					a_name = "a girder"

				if ("smallwindow")
					if (reinforcement)
						a_type = /obj/window/reinforced
					else
						a_type = /obj/window
					a_amount = 1
					a_cost = 1
					a_icon = 'icons/obj/window.dmi'
					a_icon_state = "window"
					a_name = "an one-directional window"
					a_callback = /proc/window_reinforce_callback

				if ("bigwindow")
					if (!amount_check(2,usr)) return
					if (reinforcement)
						if (map_setting && map_setting == "COG2")
							a_type = /obj/window/auto/reinforced
						else
							a_type = /obj/window/reinforced
					else
						if (map_setting && map_setting == "COG2")
							a_type = /obj/window/auto
						else
							a_type = /obj/window
					a_amount = 1
					a_cost = 2
					a_icon = 'icons/obj/window.dmi'
					a_icon_state = "window"
					a_name = "a full window"
					a_callback = /proc/window_reinforce_full_callback

				if ("retable")
					if (!amount_check(2,usr)) return

					a_type = /obj/item/table_parts/reinforced
					a_amount = 1
					a_cost = 2
					a_icon = 'icons/obj/metal.dmi'
					a_icon_state = "reinf_tableparts"
					a_name = "reinforced table parts"

				if ("remetal")
					// what the fuck is this
					var/obj/item/sheet/C = new /obj/item/sheet(usr.loc)
					var/obj/item/rods/R = new /obj/item/rods(usr.loc)
					if (material)
						C.setMaterial(material)
					if (reinforcement)
						R.setMaterial(reinforcement)
					C.amount = 1
					R.amount = 1
					consume_sheets(1)
			if (a_type)
				actions.start(new /action/bar/icon/build(src, a_type, a_cost, material, a_amount, a_icon, a_icon_state, a_name, a_callback), usr)


		return

/obj/item/sheet/steel

	New()
		..()
		var/material/M = getCachedMaterial("steel")
		setMaterial(M)

	reinforced

		New()
			..()
			var/material/M = getCachedMaterial("steel")
			set_reinforcement(M)

/obj/item/sheet/glass

	New()
		..()
		var/material/M = getCachedMaterial("glass")
		setMaterial(M)

	reinforced

		New()
			..()
			var/material/M = getCachedMaterial("steel")
			set_reinforcement(M)

	crystal

		New()
			..()
			var/material/M = getCachedMaterial("plasmaglass")
			setMaterial(M)

		reinforced

			New()
				..()
				var/material/M = getCachedMaterial("steel")
				set_reinforcement(M)

// RODS
/obj/item/rods
	name = "rods"
	desc = "A set of metal rods, useful for constructing grilles and other objects, and decent for hitting people."
	icon = 'icons/obj/metal.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "rods"
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = 3.0
	force = 9.0
	throwforce = 15.0
	throw_speed = 5
	throw_range = 20
	m_amt = 1875
	max_stack = 50
	stamina_damage = 10
	stamina_cost = 15
	stamina_crit_chance = 30
	rand_pos = 1

	check_valid_stack(atom/movable/O as obj)
		if (!istype(O,/obj/item/rods))
			return FALSE
		var/obj/item/rods/S = O
		if (!S.material || !material)
			return FALSE
		if (S.material.type != src.material.type)
			return FALSE
		if (S.material.mat_id != src.material.mat_id)
			return FALSE
		return TRUE

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span style=\"color:blue\">[user] begins gathering up [src]!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span style=\"color:blue\">You finish gathering rods.</span>")

	examine()
		set src in view(1)

		..()
		boutput(usr, text("There are [amount] rods in this stack."))
		return

	attack_hand(mob/user as mob)
		if ((user.r_hand == src || user.l_hand == src) && amount > 1)
			var/splitnum = round(input("How many rods do you want to take from the stack?","Stack of [amount]",1) as num)
			var/diff = amount - splitnum
			if (splitnum >= amount || splitnum < 1)
				boutput(user, "<span style=\"color:red\">Invalid entry, try again.</span>")
				return
			boutput(usr, "<span style=\"color:blue\">You take [splitnum] rods from the stack, leaving [diff] rods behind.</span>")
			amount = diff
			var/obj/item/rods/new_stack = new type(usr.loc, diff)
			if (material)
				new_stack.setMaterial(material)
			new_stack.amount = splitnum
			new_stack.attack_hand(user)
			new_stack.add_fingerprint(user)
		else
			..(user)

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weldingtool))
			var/obj/item/weldingtool/WELD = W
			if (WELD.welding)
				if (amount < 2)
					boutput(user, "<span style=\"color:red\">You need at least two rods to make a material sheet.</span>")
					return
				if (WELD.get_fuel() < 1)
					boutput(user, "<span style=\"color:red\">You need more fuel to weld the rods.</span>")
					return
				if (!istype(loc,/turf))
					if (istype(user,/mob/living/silicon))
						boutput(user, "<span style=\"color:red\">Hardcore as it sounds, smelting parts of yourself off isn't big or clever.</span>")
					else
						boutput(user, "<span style=\"color:red\">You should probably put the rods down first.</span>")
					return

				var/weldinput = 1
				if (amount > 3)
					var/makemetal = round(amount / 2)
					boutput(user, "<span style=\"color:blue\">You could make up to [makemetal] sheets by welding this stack.</span>")
					weldinput = input("How many sheets do you want to make?","Welding",1) as num
					if (weldinput < 1) return
					if (weldinput > makemetal) weldinput = makemetal
				var/obj/item/sheet/M = new /obj/item/sheet/steel(usr.loc)
				if (material) M.setMaterial(material)
				M.amount = weldinput
				consume_rods(weldinput * 2)

				WELD.eyecheck(user)
				WELD.use_fuel(1)
				playsound(loc, "sound/items/Welder.ogg", 50, 1, -6)
				user.visible_message("<span style=\"color:red\"><strong>[user]</strong> welds the rods together into sheets.</span>")
				if (amount < 1)	qdel(src)
				return
		if (istype(W, /obj/item/rods))
			var/obj/item/rods/R = W
			if (R.amount == max_stack)
				boutput(user, "<span style=\"color:red\">You can't put any more rods in this stack!</span>")
				return
			if (W.material && src.material && (W.material.mat_id != src.material.mat_id))
				boutput(user, "<span style=\"color:red\">You can't mix 2 stacks of different metals!</span>")
				return
			if (R.amount + amount > max_stack)
				amount = R.amount + amount - max_stack
				R.amount = max_stack
				boutput(user, "<span style=\"color:blue\">You add the rods to the stack. It now has [R.amount] rods.</span>")
			else
				R.amount += amount
				boutput(user, "<span style=\"color:blue\">You add [R.amount] rods to the stack. It now has [R.amount] rods.</span>")
				//SN src = null
				qdel(src)
				return
		if (istype(W, /obj/item/organ/head))
			user.visible_message("<span style=\"color:red\"><strong>[user] impales [W.name] on a spike!</strong></span>")
			var/obj/head_on_spike/HS = new /obj/head_on_spike(get_turf(src))
			HS.heads += W
			user.u_equip(W)
			W.set_loc(HS)
			/*	Can't do this because it colours the heads as well as the spike itself.
			if (material) HS.setMaterial(material)*/
			amount -= 1
			if (amount < 1)	qdel(src)
		return

	attack_self(mob/user as mob)
		if (user.weakened | user.stunned)
			return
		if (locate(/obj/grille, usr.loc))
			for (var/obj/grille/G in usr.loc)
				if (G.ruined)
					G.health = G.health_max
					G.density = 1
					G.ruined = 0
					G.update_icon()
					if (material)
						G.setMaterial(material)
					boutput(user, "<span style=\"color:blue\">You repair the broken grille.</span>")
					consume_rods(1)
				else
					boutput(user, "<span style=\"color:red\">There is already a grille here.</span>")
				break
		else
			if (amount < 2)
				boutput(user, "<span style=\"color:red\">You need at least two rods to build a grille.</span>")
				return
			user.visible_message("<span style=\"color:blue\"><strong>[user]</strong> begins building a grille.</span>")
			var/turf/T = usr.loc
			spawn (15)
				if (T == usr.loc && !usr.weakened && !usr.stunned)
					consume_rods(2)
					var/atom/G = new /obj/grille(usr.loc)
					G.setMaterial(material)
					logTheThing("station", usr, null, "builds a grille (<strong>Material:</strong> [G.material && G.material.mat_id ? "[G.material.mat_id]" : "*UNKNOWN*"]) at [log_loc(usr)].")
		add_fingerprint(user)
		return

	proc/consume_rods(var/use_amount)
		if (!isnum(amount))
			return
		amount = max(0,amount - use_amount)
		if (amount < 1)
			if (istype(loc,/mob/living))
				var/mob/living/L = loc
				L.u_equip(src)
			qdel(src)
		return

/obj/head_on_spike
	name = "head on a spike"
	desc = "A human head impaled on a spike, dim-eyed, grinning faintly, blood blackening between the teeth."
	icon = 'icons/obj/metal.dmi'
	icon_state = "head_spike"
	anchored = 0
	density = 1
	var/list/heads = list()
	var/head_offset = 0 //so the ones at the botton don't teleport upwards when a head is removed
	var/bloodiness = 0 //

	New()
		spawn (0) //wait for the head to be added
			update()

	attack_hand(mob/user as mob)
		if (heads.len)
			var/obj/item/organ/head/head = heads[heads.len]

			user.visible_message("<span style=\"color:red\"><strong>[user.name] pulls [head.name] off of the spike!</strong></span>")
			head.set_loc(user.loc)
			head.attack_hand(user)
			head.add_fingerprint(user)
			head.pixel_x = rand(-8,8)
			head.pixel_y = rand(-8,8)
			heads -= head

			if (!heads.len)
				head_offset = 0
			else
				head_offset++

			update()
		else
			..(user)

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weldingtool))
			var/obj/item/weldingtool/WELD = W
			if (WELD.welding)

				if (WELD.get_fuel() < 1)
					boutput(user, "<span style=\"color:red\">You don't have enough fuel.</span>")
					return

				if (!anchored && !istype(loc,/turf/simulated/floor) && !istype(loc,/turf/unsimulated/floor))
					boutput(user, "<span style=\"color:red\">There's nothing to weld that to.</span>")
					return

				WELD.eyecheck(user)
				WELD.use_fuel(1)
				playsound(loc, "sound/items/Welder.ogg", 50, 1, -6)
				if (!anchored) user.visible_message("<span style=\"color:red\"><strong>[user.name] welds the [name] to the floor.</strong></span>")
				else user.visible_message("<span style=\"color:red\"><strong>[user.name] cuts the [name] free from the floor.</strong></span>")
				anchored = !(anchored)

				update()

		else if (istype(W,/obj/item/organ/head))
			if (!has_space())
				boutput(user, "<span style=\"color:red\">There isn't room on that spike for another head.</span>")
				return

			if (!heads.len) user.visible_message("<span style=\"color:red\"><strong>[user.name] impales [W.name] on the [name]!</strong></span>")
			else user.visible_message("<span style=\"color:red\"><strong>[user.name] adds [W.name] to the spike!</strong></span>")

			if (head_offset > 0) head_offset--

			heads += W
			user.u_equip(W)
			W.set_loc(src)

			update()

		return

	proc/update()
		overlays = null

		if ((heads.len < 3 && head_offset > 0) || heads.len == 0)
			overlays += icon('icons/obj/metal.dmi',"head_spike_blood")

		switch(heads.len) //fuck it
			if (0)
				name = "bloody spike"
				desc = "A bloody spike."
			if (1)
				/*	This shit doesn't work ugh
				name = "[heads[1]:donor] on a spike"*/
				var/obj/item/organ/head/head1 = heads[1]
				name = "[head1.name] on a spike"
				desc = "A human head impaled on a spike, dim-eyed, grinning faintly, blood blackening between the teeth."
			if (2)
				name = "heads on a spike"
				var/obj/item/organ/head/head1 = heads[1]
				var/obj/item/organ/head/head2 = heads[2]
				desc = "The heads of [head1.donor] and [head2.donor] impaled on a spike."
				/*	This shit doesn't work ugh
				desc = "The heads of [heads[1]:donor] and [heads[2]:donor] impaled on a spike."*/
			if (3)
				name = "heads on a spike"
				var/obj/item/organ/head/head1 = heads[1]
				var/obj/item/organ/head/head2 = heads[2]
				var/obj/item/organ/head/head3 = heads[3]
				desc = "The heads of [head1.donor], [head2.donor] and [head3.donor] impaled on a spike."
				/*	This shit doesn't work ugh
				desc = "The heads of [heads[1]:donor], [heads[2]:donor] and [heads[3]:donor] impaled on a spike."*/


		if (heads.len > 0)
			var/pixely = 8 - 8*head_offset - 8*heads.len
			for (var/obj/item/organ/head/H in heads)
				H.pixel_x = 0
				H.pixel_y = pixely
				pixely += 8
				H.dir = SOUTH
				overlays += H

			overlays += icon('icons/obj/metal.dmi',"head_spike_flies")

		if (anchored)
			overlays += icon('icons/obj/metal.dmi',"head_spike_weld")

		return


	proc/has_space()
		if (heads.len < 3) return TRUE

		return FALSE

	suicide(var/mob/user as mob)
		if (!has_space() || !hasvar(user,"organHolder")) return FALSE

		user.visible_message("<span style=\"color:red\"><strong>[user] headbutts the spike, impaling \his head on it!</strong></span>")
		user.TakeDamage("head", 50, 0)
		user.stunned = 50
		playsound(loc, "sound/effects/bloody_stab.ogg", 50, 1)
		if (prob(40)) user.emote("scream")

		spawn (10)
			user.visible_message("<span style=\"color:red\"><strong>[user] tears \his body away from the spike, leaving \his head behind!</strong></span>")
			var/obj/head = user:organHolder.drop_organ("head")
			head.set_loc(src)
			heads += head
			update()
			new /obj/decal/cleanable/blood(user.loc)
			playsound(loc, "sound/effects/gib.ogg", 50, 1)
			user.updatehealth()

		spawn (100)
			if (user)
				user.suiciding = 0

		return TRUE


/obj/item/rods/steel

	New()
		..()
		var/material/M = getCachedMaterial("steel")
		setMaterial(M)

// TILES

/obj/item/tile
	name = "floor tile"
	desc = "They keep the floor in a good and walkable condition."
	icon = 'icons/obj/metal.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "tile"
	w_class = 3.0
	m_amt = 937.5
	throw_speed = 5
	throw_range = 20
	force = 6.0
	throwforce = 7.0
	max_stack = 80
	stamina_damage = 25
	stamina_cost = 25
	stamina_crit_chance = 15

	New()

		pixel_x = rand(0, 14)
		pixel_y = rand(0, 14)
		return

	check_valid_stack(atom/movable/O as obj)
		if (!istype(O,/obj/item/tile))
			return FALSE
		var/obj/item/tile/S = O
		if (!S.material || !material)
			return FALSE
		if (S.material.type != src.material.type)
			return FALSE
		if (S.material.mat_id != src.material.mat_id)
			return FALSE
		return TRUE

	get_desc(dist)
		if (dist <= 1)
			. += "<br>There are [amount] tile[s_es(amount)] left on the stack."

	attack_hand(mob/user as mob)

		if ((user.r_hand == src || user.l_hand == src))
			add_fingerprint(user)
			var/obj/item/tile/F = new /obj/item/tile( user )
			if (material)
				F.setMaterial(material)
			else
				F.setMaterial(getCachedMaterial("steel"))
			F.amount = 1
			amount--
			user.put_in_hand_or_drop(F)
			if (amount < 1)
				//SN src = null
				qdel(src)
				return
		else
			..()
		return

	attack_self(mob/user as mob)

		if (usr.stat)
			return
		var/T = user.loc
		if (!( istype(T, /turf) ))
			boutput(user, "<span style=\"color:blue\">You must be on the ground!</span>")
			return
		else
			var/S = T
			if (!( istype(S, /turf/space) ))
				boutput(user, "You cannot build on or repair this turf!")
				return
			else
				build(S)
				amount--
		if (amount < 1)
			user.u_equip(src)
			//SN src = null
			qdel(src)
			return
		add_fingerprint(user)
		return

	attackby(obj/item/tile/W as obj, mob/user as mob)

		if (!( istype(W, /obj/item/tile) ))
			return
		if (W.amount == max_stack)
			return
		W.add_fingerprint(user)
		if (W.amount + amount > max_stack)
			amount = W.amount + amount - max_stack
			W.amount = max_stack
		else
			W.amount += amount
			//SN src = null
			qdel(src)
			return
		return

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span style=\"color:blue\">[user] begins stacking [src]!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span style=\"color:blue\">You finish stacking tiles.</span>")

	proc/build(turf/S as turf)
		var/turf/simulated/floor/W = S.ReplaceWithFloor()
		if (!W.icon_old)
			W.icon_old = "floor"
		W.to_plating()

		if (ismob(usr) && !istype(material, /material/metal/steel))
			logTheThing("station", usr, null, "constructs a floor (<strong>Material:</strong>: [material && material.name ? "[material.name]" : "*UNKNOWN*"]) at [log_loc(S)].")

		return

/obj/item/tile/steel

	New()
		..()
		var/material/M = getCachedMaterial("steel")
		setMaterial(M)

/obj/item/sheet/electrum
	New()
		..()
		setMaterial(getCachedMaterial("electrum"))

	consume_sheets(var/use_amount)
		if (!isnum(use_amount))
			return
		if (istype(usr, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = usr
			R.cell.use(use_amount * 200)

// kinda needed for some stuff I'm making - haine
/obj/item/sheet/steel/fullstack
	amount = 50
/obj/item/sheet/steel/reinforced/fullstack
	amount = 50
/obj/item/sheet/glass/fullstack
	amount = 50
/obj/item/sheet/glass/reinforced/fullstack
	amount = 50
/obj/item/sheet/glass/crystal/fullstack
	amount = 50
/obj/item/sheet/glass/crystal/reinforced/fullstack
	amount = 50
/obj/item/rods/steel/fullstack
	amount = 50
/obj/item/tile/steel/fullstack
	amount = 80
