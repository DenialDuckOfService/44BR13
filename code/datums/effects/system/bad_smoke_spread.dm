/////////////////////////////////////////////
//// SMOKE SYSTEMS
// direct can be optinally added when set_up, to make the smoke always travel in one direction
// in case you wanted a vent to always smoke north for example
/////////////////////////////////////////////

/effects/system/bad_smoke_spread
	var/number = 3
	var/cardinals = 0
	var/turf/location
	var/atom/holder
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction
	var/color = null

/effects/system/bad_smoke_spread/proc/set_up(n = 5, c = 0, loca, direct, color)
	if (n > 20)
		n = 20
	number = n
	cardinals = c
	color = color
	if (istype(loca, /turf))
		location = loca
	else
		location = get_turf(loca)
	if (direct)
		direction = direct


/effects/system/bad_smoke_spread/proc/attach(atom/atom)
	holder = atom

/effects/system/bad_smoke_spread/proc/start()
	var/i = 0
	for (i=0, i<number, i++)
		if (total_smoke > 20)
			return
		spawn (0)
			if (holder)
				location = get_turf(holder)
			var/obj/effects/bad_smoke/smoke = unpool(/obj/effects/bad_smoke)
			smoke.color = color
			smoke.set_loc(location)
			total_smoke++
			var/_direction = direction
			if (!_direction)
				if (cardinals)
					_direction = pick(cardinal)
				else
					_direction = pick(alldirs)
			for (var/j=0, j<pick(0,1,1,1,2,2,2,3), j++)
				sleep(10)
				step(smoke,_direction)
			spawn (150+rand(10,30))
				if (smoke)
					pool(smoke)
				total_smoke--