//Ye olde filter of yore (Pre-dev adjustable filter)

//TODO: Hacking.
/obj/machinery/atmospherics/retrofilter
	icon = 'icons/obj/atmospherics/retro_filter.dmi'
	icon_state = "intact_off"
//
	name = "Gas filter"

	dir = SOUTH
	initialize_directions = SOUTH|NORTH|WEST

	req_access = list(access_engineering_atmos)

	var/gas_mixture/air_in
	var/gas_mixture/air_out1
	var/gas_mixture/air_out2

	var/obj/machinery/atmospherics/node_in
	var/obj/machinery/atmospherics/node_out1 //This is where filtered air comes out. It's this one.
	var/obj/machinery/atmospherics/node_out2

	var/pipe_network/network_in
	var/pipe_network/network_out1
	var/pipe_network/network_out2

	var/target_pressure = ONE_ATMOSPHERE
	var/transfer_ratio = 0.80 //Percentage of passing gas to consider for transfer.

	var/filter_mode = 0 //Bitfield determining gases to filter.
	var/const/MODE_OXYGEN = 1 //Let oxygen through
	var/const/MODE_NITROGEN = 2 //Let nitrogen through
	var/const/MODE_CO2 = 4 //Let CO2 through
	var/const/MODE_PLASMA = 8 //Let plasma through.
	var/const/MODE_TRACE = 16 //Let trace gases (Like N2O) through.

	var/locked = 1
	var/open = 0
	var/hacked = 0
	var/emagged = 0

	var/frequency = 0
	var/radio_frequency/radio_connection
	var/net_id = null

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, "[frequency]")
			frequency = new_frequency
			if (frequency)
				radio_connection = radio_controller.add_object(src, "[frequency]")

	New()
		..()
		tag = ""
		switch(dir)
			if (NORTH)
				initialize_directions = NORTH|EAST|SOUTH
			if (SOUTH)
				initialize_directions = NORTH|SOUTH|WEST
			if (EAST)
				initialize_directions = EAST|WEST|SOUTH
			if (WEST)
				initialize_directions = NORTH|EAST|WEST
		if (radio_controller)
			initialize()

		air_in = unpool(/gas_mixture)
		air_out1 = unpool(/gas_mixture)
		air_out2 = unpool(/gas_mixture)

		air_in.volume = 200
		air_out1.volume = 200
		air_out2.volume = 200

	disposing()
		loc = null

		if (node_out1)
			node_out1.disconnect(src)
			if (network_out1)
				network_out1.dispose()

		if (node_out2)
			node_out2.disconnect(src)
			if (network_out2)
				network_out2.dispose()

		else if (node_in)
			node_in.disconnect(src)
			if (network_in)
				network_in.dispose()

		node_out1 = null
		node_out2 = null
		node_in = null
		network_out1 = null
		network_out2 = null
		network_in = null

		if (air_in)
			pool(air_in)
		if (air_out1)
			pool(air_out1)
		if (air_out2)
			pool(air_out2)

		air_in = null
		air_out1 = null
		air_out2 = null

		..()

	network_disposing(pipe_network/reference)
		if (network_in == reference)
			network_in = null
		if (network_out1 == reference)
			network_out1 = null
		if (network_out2 == reference)
			network_out2 = null

	update_icon()
		if (node_out1&&node_out2&&node_in)
			icon_state = "intact_[(stat & NOPOWER)?("off"):("on")]"
		else
			var/node_out1_direction = get_dir(src, node_out1)
			var/node_out2_direction = get_dir(src, node_out2)

			var/node_in_bit = (node_in)?(1):(0)

			icon_state = "exposed_[node_out1_direction|node_out2_direction]_[node_in_bit]_off"

		return

	attack_hand(mob/user as mob)
		if (..())
			user << browse(null, "window=pipefilter")
			user.machine = null
			return

		var/list/gases = list("O2", "N2", "CO2", "Plasma", "OTHER")
		user.machine = src
		var/dat = "<head><title>Gas Filtration Unit Mk VII</title></head><body><hr>"// "Filter Release Rate:<BR><br><A href='?src=\ref[src];fp=-[num2text(maxrate, 9)]'>M</A> <A href='?src=\ref[src];fp=-100000'>-</A> <A href='?src=\ref[src];fp=-10000'>-</A> <A href='?src=\ref[src];fp=-1000'>-</A> <A href='?src=\ref[src];fp=-100'>-</A> <A href='?src=\ref[src];fp=-1'>-</A> [f_per] <A href='?src=\ref[src];fp=1'>+</A> <A href='?src=\ref[src];fp=100'>+</A> <A href='?src=\ref[src];fp=1000'>+</A> <A href='?src=\ref[src];fp=10000'>+</A> <A href='?src=\ref[src];fp=100000'>+</A> <A href='?src=\ref[src];fp=[num2text(maxrate, 9)]'>M</A><BR><br>"
		for (var/i = 1; i <= gases.len; i++)
			if (!issilicon(user) && locked)
				dat += "[gases[i]]: [(filter_mode & (1 << (i - 1))) ? "Releasing" : "Passing"]<br>"
			else
				dat += "[gases[i]]: <a href='?src=\ref[src];toggle_gas=[1 << (i - 1)]'>[(filter_mode & (1 << (i - 1))) ? "Releasing" : "Passing"]</a><br>"

		var/pressure = air_in.return_pressure()
		var/total_moles = air_in.total_moles()

		dat += "<hr>Gas Levels: <br>Gas Pressure: [round(pressure,0.1)] kPa<br><br>"

		if (total_moles)
			var/o2_level = air_in.oxygen/total_moles
			var/n2_level = air_in.nitrogen/total_moles
			var/co2_level = air_in.carbon_dioxide/total_moles
			var/plasma_level = air_in.toxins/total_moles
			var/unknown_level =  1-(o2_level+n2_level+co2_level+plasma_level)

			dat += "Nitrogen: [round(n2_level*100)]%<br>"

			dat += "Oxygen: [round(o2_level*100)]%<br>"

			dat += "Carbon Dioxide: [round(co2_level*100)]%<br>"

			dat += "Plasma: [round(plasma_level*100)]%<br>"

			if (unknown_level > 0.01)
				dat += "OTHER: [round(unknown_level)]%<br>"
		else
			dat += "Nitrogen: 0%<br>Oxygen: 0%<br>Carbon Dioxide: 0%<br>Plasma: 0%<br>"

		dat += "<br><A href='?src=\ref[src];close=1'>Close</A>"

		user << browse(dat, "window=pipefilter;size=300x365")
		onclose(user, "pipefilter")
		return

	Topic(href, href_list)
		if (..() || (stat & NOPOWER))
			return

		usr.machine = src

		add_fingerprint(usr)
		if (href_list["toggle_gas"] && (!locked || issilicon(usr)))
			var/gasToToggle = text2num(href_list["toggle_gas"])
			if (!gasToToggle)
				return
			gasToToggle = max(1, min(gasToToggle, 16))
			if (filter_mode & gasToToggle)
				filter_mode &= ~gasToToggle
			else
				filter_mode |= gasToToggle

			updateUsrDialog()
			update_overlays()

		else if (href_list["close"])
			usr << browse(null, "window=pipefilter")
			usr.machine = null
			return
		return

	//Draw the nice little blinky lights that give an at-a-glance indication of filter state.
	proc/update_overlays()
		overlays.len = 0

		if (open)
			overlays += image(icon, "filter-open")
		if (hacked)
			overlays += image(icon, "filter-bypass")

		if (stat & NOPOWER)
			return

		if (emagged)
			overlays += image(icon, "filter-emag")
		else
			if (filter_mode & MODE_OXYGEN)
				overlays += image(icon, "filter-o2")
			if (filter_mode & MODE_NITROGEN)
				overlays += image(icon, "filter-n2")
			if (filter_mode & MODE_CO2)
				overlays += image(icon, "filter-co2")
			if (filter_mode & (MODE_PLASMA | MODE_TRACE))
				overlays += image(icon, "filter-tox")

		return

	process()
		..()
		if (stat & NOPOWER)
			return

		if (!air_out2)
			return

		var/output_starting_pressure = air_out1.return_pressure()

		if (output_starting_pressure >= target_pressure)
			//No need to mix if target is already full!
			return TRUE

		//Calculate necessary moles to transfer using PV=nRT

		var/pressure_delta = target_pressure - output_starting_pressure
		var/transfer_moles = 0

		if (air_in.temperature > 0)
			transfer_moles = ((pressure_delta*air_out2.volume)/(air_in.temperature * R_IDEAL_GAS_EQUATION))

		//Actually transfer the gas

		if (transfer_moles > 0)
			var/gas_mixture/removed = air_in.remove_ratio(transfer_ratio)//air_in.remove(transfer_moles)

			var/gas_mixture/filtered_out = unpool(/gas_mixture)
			if (air_in.temperature)
				filtered_out.temperature = air_in.temperature

			//Unlike the regular filter, we can pick and choose the gas to remove!
			//One might say that a little filter being this advanced is rather unrealistic
			//However, who gives a fuck.
			if (filter_mode & MODE_PLASMA)
				if (removed.toxins)
					filtered_out.toxins = removed.toxins
					removed.toxins = 0
			if (filter_mode & MODE_OXYGEN)
				if (removed.oxygen)
					filtered_out.oxygen = removed.oxygen
					removed.oxygen = 0
			if (filter_mode & MODE_NITROGEN)
				if (removed.nitrogen)
					filtered_out.nitrogen = removed.nitrogen
					removed.nitrogen = 0
			if (filter_mode & MODE_CO2)
				if (removed.carbon_dioxide)
					filtered_out.carbon_dioxide = removed.carbon_dioxide
					removed.carbon_dioxide = 0
			if (filter_mode & MODE_TRACE)
				if (removed && removed.trace_gases && removed.trace_gases.len)
					for (var/gas/trace_gas in removed.trace_gases)
						if (trace_gas)
							removed.trace_gases -= trace_gas
							if (!removed.trace_gases.len)
								removed.trace_gases = null
							if (!filtered_out.trace_gases)
								filtered_out.trace_gases = list()
							filtered_out.trace_gases += trace_gas

			air_out1.merge(filtered_out)
			air_out2.merge(removed)

		if ((network_out2 && network_in) && (network_out2 != network_in))
			network_in.merge(network_out2)
			network_out2 = network_in

		if (network_out1)
			network_out1.update = 1

		if (network_out2)
			network_out2.update = 1

		else if (network_in)
			network_in.update = 1

		return TRUE

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (emagged)
			return FALSE
		emagged = 1
		if (user)
			add_fingerprint(user)
			visible_message("<span style=\"color:red\">[user] has shorted out the [name] with an electromagnetic card!</span>")
		update_overlays()
		return TRUE

	demag(var/mob/user)
		if (!emagged)
			return FALSE
		if (user)
			user.show_message("You repair the [name]'s wiring!", "blue")
		emagged = 1
		update_overlays()
		return TRUE

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/device/pda2) && W:ID_card)
			W = W:ID_card
		if (istype(W, /obj/item/card/id))
			add_fingerprint(user)
			if (hacked)
				boutput(user, "<span style=\"color:red\">Remove the foreign wires first!</span>")
				return
			if (allowed(user, req_only_one_required))
				locked = !locked
				boutput(user, "Controls are now [locked ? "locked." : "unlocked."]")
				updateUsrDialog()
				update_overlays()
			else
				boutput(user, "<span style=\"color:red\">Access denied.</span>")
		else if (istype(W, /obj/item/screwdriver))
			if (hacked)
				user.show_message("<span style=\"color:red\">Remove the foreign wires first!</span>", 1)
				return
			add_fingerprint(user)
			user.show_message("<span style=\"color:red\">Now [src.open ? "re" : "un"]securing the access system panel...</span>", 1)
			if (!do_after(user, 30))
				return
			open = !open
			user.show_message("<span style=\"color:red\">Done!</span>",1)
			update_overlays()
			return
		else if (istype(W, /obj/item/cable_coil) && !hacked)
			if (!open)
				user.show_message("<span style=\"color:red\">You must remove the panel first!</span>",1)
				return
			var/obj/item/cable_coil/C = W
			if (C.amount >= 4)
				user.show_message("<span style=\"color:red\">You unravel some cable..</span>",1)
			else
				user.show_message("<span style=\"color:red\">Not enough cable! <em>(Requires four pieces)</em></span>",1)
				return
			add_fingerprint(user)
			user.show_message("<span style=\"color:red\">Now bypassing the access system... <em>(This may take a while)</em></span>", 1)
			if (!do_after(user, 100))
				return
			C.use(4)
			hacked = 1
			locked = 0
			update_overlays()
			return
		else if (istype(W, /obj/item/wirecutters) && hacked)
			add_fingerprint(user)
			user.show_message("<span style=\"color:red\">Now removing the bypass wires... <em>(This may take a while)</em></span>", 1)
			if (!do_after(user, 50))
				return
			hacked = 0
			update_overlays()
			return
		else
			..()

// Housekeeping and pipe network stuff below
	power_change()

		if ( powered(ENVIRON) )
			stat &= ~NOPOWER
		else
			spawn (rand(0, 15))
				stat |= NOPOWER

		update_overlays()
		return

	network_expand(pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
		if (reference == node_out1)
			if (!isnull(node_out1))
				network_out1 = new_network

		else if (reference == node_out2)
			//network_out2 = new_network
			if (!isnull(node_out2))
				return node_out2.network_expand(new_network, src)

		else if (reference == node_in)
			//network_in = new_network
			if (!isnull(node_in))
				return node_in.network_expand(new_network, src)

		if (new_network.normal_members.Find(src))
			return FALSE

		new_network.normal_members += src

		return null

	initialize()
		if (node_out1 && node_in) return

		var/node_in_connect = turn(dir, -180)
		var/node_out1_connect = turn(dir, -90)
		var/node_out2_connect = dir


		for (var/obj/machinery/atmospherics/target in get_step(src,node_out1_connect))
			if (target.initialize_directions & get_dir(target,src))
				node_out1 = target
				break

		for (var/obj/machinery/atmospherics/target in get_step(src,node_out2_connect))
			if (target.initialize_directions & get_dir(target,src))
				node_out2 = target
				break

		for (var/obj/machinery/atmospherics/target in get_step(src,node_in_connect))
			if (target.initialize_directions & get_dir(target,src))
				node_in = target
				break

		update_icon()

		set_frequency(frequency)

	build_network()
		if (!network_out1 && node_out1)
			network_out1 = new /pipe_network()
			network_out1.normal_members += src
			network_out1.build_network(node_out1, src)

		if (!network_out2 && node_out2)
			network_out2 = new /pipe_network()
			network_out2.normal_members += src
			network_out2.build_network(node_out2, src)

		if (!network_in && node_in)
			network_in = new /pipe_network()
			network_in.normal_members += src
			network_in.build_network(node_in, src)


	return_network(obj/machinery/atmospherics/reference)
		build_network()

		if (reference==node_out1)
			return network_out1

		if (reference==node_out2)
			return network_out2

		if (reference==node_in)
			return network_in

		return null

	reassign_network(pipe_network/old_network, pipe_network/new_network)
		// Todo shouldnt this remove the gas mixture? Not sure, this system is complex...
		if (network_out1 == old_network)
			network_out1 = new_network

		if (network_out2 == old_network)
			network_out2 = new_network

		if (network_in == old_network)
			network_in = new_network

		return TRUE

	return_network_air(pipe_network/reference)
		var/list/results = list()

		if (network_out1 == reference)
			results += air_out1

		if (network_out2 == reference)
			results += air_out2

		if (network_in == reference)
			results += air_in

		return results

	disconnect(obj/machinery/atmospherics/reference)
		if (reference==node_out1)
			if (network_out1)
				network_out1.dispose()
				network_out1 = null
			node_out1 = null

		else if (reference==node_out2)
			if (network_out2)
				network_out2.dispose()
				network_out2 = null
			node_out2 = null

		else if (reference==node_in)
			if (network_in)
				network_in.dispose()
				network_in = null
			node_in = null

		return null