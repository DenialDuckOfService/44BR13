/obj/machinery/compressor
	name = "compressor"
	desc = "The compressor stage of a gas turbine generator."
	icon = 'icons/obj/atmospherics/pipes.dmi'
	icon_state = "compressor"
	anchored = 1
	density = 1
	var/obj/machinery/power/turbine/turbine
	var/gas_mixture/gas_contained
	var/turf/simulated/inturf
	var/starter = 0
	var/rpm = 0
	var/rpmtarget = 0
	var/capacity = 1e6
	var/comp_id = 0

/obj/machinery/power/turbine
	name = "gas turbine generator"
	desc = "A gas turbine used for backup power generation."
	icon = 'icons/obj/atmospherics/pipes.dmi'
	icon_state = "turbine"
	anchored = 1
	density = 1
	var/obj/machinery/compressor/compressor
	directwired = 1
	var/turf/simulated/outturf
	var/lastgen

/obj/machinery/computer/turbine_computer
	name = "Gas turbine control computer"
	desc = "A computer to remotely control a gas turbine"
	icon = 'icons/obj/computer.dmi'
	icon_state = "airtunnel0e"
	anchored = 1
	density = 1
	var/obj/machinery/compressor/compressor
	var/list/obj/machinery/door/poddoor/doors
	var/id = 0
	var/door_status = 0

// the inlet stage of the gas turbine electricity generator

/obj/machinery/compressor/New()
	..()

	gas_contained = new
	inturf = get_step(src, dir)

	spawn (5)
		turbine = locate() in get_step(src, get_dir(inturf, src))
		if (!turbine)
			stat |= BROKEN


#define COMPFRICTION 5e5
#define COMPSTARTERLOAD 2800

/obj/machinery/compressor/process()
	if (!starter)
		return
	overlays = null
	if (stat & BROKEN)
		return
	if (!turbine)
		stat |= BROKEN
		return
	rpm = 0.9* rpm + 0.1 * rpmtarget
	var/gas_mixture/environment = inturf.return_air()
	var/transfer_moles = environment.total_moles()/10
	//var/transfer_moles = rpm/10000*capacity
	var/gas_mixture/removed = inturf.remove_air(transfer_moles)
	gas_contained.merge(removed)

	rpm = max(0, rpm - (rpm*rpm)/COMPFRICTION)


	if (starter && !(stat & NOPOWER))
		use_power(2800)
		if (rpm<1000)
			rpmtarget = 1000
	else
		if (rpm<1000)
			rpmtarget = 0



	if (rpm>50000)
		overlays += image('icons/obj/atmospherics/pipes.dmi', "comp-o4", FLY_LAYER)
	else if (rpm>10000)
		overlays += image('icons/obj/atmospherics/pipes.dmi', "comp-o3", FLY_LAYER)
	else if (rpm>2000)
		overlays += image('icons/obj/atmospherics/pipes.dmi', "comp-o2", FLY_LAYER)
	else if (rpm>500)
		overlays += image('icons/obj/atmospherics/pipes.dmi', "comp-o1", FLY_LAYER)
	 //TODO: DEFERRED

/obj/machinery/power/turbine/New()
	..()

	outturf = get_step(src, dir)

	spawn (5)

		compressor = locate() in get_step(src, get_dir(outturf, src))
		if (!compressor)
			stat |= BROKEN


#define TURBPRES 9000000
#define TURBGENQ 20000
#define TURBGENG 0.8

/obj/machinery/power/turbine/process()
	if (!compressor.starter)
		return
	overlays = null
	if (stat & BROKEN)
		return
	if (!compressor)
		stat |= BROKEN
		return
	lastgen = ((compressor.rpm / TURBGENQ)**TURBGENG) *TURBGENQ

	add_avail(lastgen)
	var/newrpm = ((compressor.gas_contained.temperature) * compressor.gas_contained.total_moles())/4
	newrpm = max(0, newrpm)

	if (!compressor.starter || newrpm > 1000)
		compressor.rpmtarget = newrpm

	if (compressor.gas_contained.total_moles()>0)
		var/oamount = min(compressor.gas_contained.total_moles(), (compressor.rpm+100)/35000*compressor.capacity)
		var/gas_mixture/removed = compressor.gas_contained.remove(oamount)
		outturf.assume_air(removed)

	if (lastgen > 100)
		overlays += image('icons/obj/atmospherics/pipes.dmi', "turb-o", FLY_LAYER)


	for (var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			interact(M)
	AutoUpdateAI(src)


/obj/machinery/power/turbine/attack_ai(mob/user)

	if (stat & (BROKEN|NOPOWER))
		return

	interact(user)

/obj/machinery/power/turbine/attack_hand(mob/user)

	add_fingerprint(user)

	if (stat & (BROKEN|NOPOWER))
		return

	interact(user)

/obj/machinery/power/turbine/proc/interact(mob/user)

	if ( (get_dist(src, user) > 1 ) || (stat & (NOPOWER|BROKEN)) && (!istype(user, /mob/living/silicon/ai)) )
		user.machine = null
		user << browse(null, "window=turbine")
		return

	user.machine = src

	var/t = "<TT><strong>Gas Turbine Generator</strong><HR><PRE>"

	t += "Generated power : [round(lastgen)] W<BR><BR>"

	t += "Turbine: [round(compressor.rpm)] RPM<BR>"

	t += "Starter: [ compressor.starter ? "<A href='?src=\ref[src];str=1'>Off</A> <strong>On</strong>" : "<strong>Off</strong> <A href='?src=\ref[src];str=1'>On</A>"]"

	t += "</PRE><HR><A href='?src=\ref[src];close=1'>Close</A>"

	t += "</TT>"
	user << browse(t, "window=turbine")
	onclose(user, "turbine")

	return

/obj/machinery/power/turbine/Topic(href, href_list)
	..()
	if (stat & BROKEN)
		return
	if (usr.stat || usr.restrained() )
		return

	if (( usr.machine==src && ((get_dist(src, usr) <= 1) && istype(loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
		if ( href_list["close"] )
			usr << browse(null, "window=turbine")
			usr.machine = null
			return

		else if ( href_list["str"] )
			compressor.starter = !compressor.starter

		spawn (0)
			for (var/mob/M in viewers(1, src))
				if ((M.client && M.machine == src))
					interact(M)

	else
		usr << browse(null, "window=turbine")
		usr.machine = null

	return





/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



/obj/machinery/computer/turbine_computer/New()
	..()
	spawn (5)
		for (var/obj/machinery/compressor/C in machines)
			if (id == C.comp_id)
				compressor = C
		doors = new /list()
		for (var/obj/machinery/door/poddoor/P)
			if (P.id == id)
				doors += P

/obj/machinery/computer/turbine_computer/attackby(I as obj, user as mob)
	if (istype(I, /obj/item/screwdriver))
		playsound(loc, "sound/items/Screwdriver.ogg", 50, 1)
		if (do_after(user, 20))
			if (stat & BROKEN)
				boutput(user, "<span style=\"color:blue\">The broken glass falls out.</span>")
				var/obj/computerframe/A = new /obj/computerframe( loc )
				if (material) A.setMaterial(material)
				new /obj/item/raw_material/shard/glass( loc )
				var/obj/item/circuitboard/turbine_control/M = new /obj/item/circuitboard/turbine_control( A )
				for (var/obj/C in src)
					C.set_loc(loc)
				M.id = id
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				qdel(src)
			else
				boutput(user, "<span style=\"color:blue\">You disconnect the monitor.</span>")
				var/obj/computerframe/A = new /obj/computerframe( loc )
				if (material) A.setMaterial(material)
				var/obj/item/circuitboard/turbine_control/M = new /obj/item/circuitboard/turbine_control( A )
				for (var/obj/C in src)
					C.set_loc(loc)
				M.id = id
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				qdel(src)
	else
		attack_hand(user)
	return

/obj/machinery/computer/turbine_computer/attack_hand(var/mob/user as mob)
	user.machine = src
	var/dat
	if (compressor)
		dat += {"<BR><strong>Gas turbine remote control system</strong><HR>
		<br>Turbine status: [ compressor.starter ? "<A href='?src=\ref[src];str=1'>Off</A> <strong>On</strong>" : "<strong>Off</strong> <A href='?src=\ref[src];str=1'>On</A>"]
		<br><BR>
		<br>Turbine speed: [compressor.rpm]rpm<BR>
		<br>Power currently being generated: [compressor.turbine.lastgen]W<BR>
		<br>Internal gas temperature: [compressor.gas_contained.temperature]K<BR>
		<br>Vent doors: [ door_status ? "<A href='?src=\ref[src];doors=1'>Closed</A> <strong>Open</strong>" : "<strong>Closed</strong> <A href='?src=\ref[src];doors=1'>Open</A>"]
		<br></PRE><HR><A href='?src=\ref[src];view=1'>View</A>
		<br></PRE><HR><A href='?src=\ref[src];close=1'>Close</A>
		<br><BR>
		<br>"}
	else
		dat += "<span style=\"color:red\"><strong>No compatible attached compressor found.</span>"

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return



/obj/machinery/computer/turbine_computer/Topic(href, href_list)
	if (..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src

		if ( href_list["view"] )
			usr.client.eye = compressor
		else if ( href_list["str"] )
			compressor.starter = !compressor.starter
		else if (href_list["doors"])
			for (var/obj/machinery/door/poddoor/D in doors)
				if (door_status == 0)
					spawn ( 0 )
						D.open()
						door_status = 1
				else
					spawn ( 0 )
						D.close()
						door_status = 0
		else if ( href_list["close"] )
			usr << browse(null, "window=computer")
			usr.machine = null
			return

		add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/turbine_computer/process()
	updateDialog()
	return