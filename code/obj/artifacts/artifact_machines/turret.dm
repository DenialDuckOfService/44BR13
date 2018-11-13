/obj/machinery/artifact/turret
	name = "artifact turret"
	associated_datum = /artifact/turret

/artifact/turret
	associated_object = /obj/machinery/artifact/turret
	rarity_class = 3
	validtypes = list("wizard","eldritch","precursor")
	validtriggers = list(/artifact_trigger/force,/artifact_trigger/electric,/artifact_trigger/heat,
	/artifact_trigger/radiation,/artifact_trigger/carbon_touch,/artifact_trigger/silicon_touch)
	activated = 0
	activ_text = "uncovers an array of guns!"
	deact_text = "retracts the guns back into itself and falls quiet!"
	react_xray = list(9,40,80,8,"SEGMENTED")
	var/cycles_without_target = 0
	var/cycles_until_shutdown = 10
	var/capricious = 0
	var/shot_range = 3
	var/projectile/artifact/bullet = null
	var/mob/living/friend = null
	var/mob/living/current_target = null
	examine_hint = "It is covered in very conspicuous markings."

	New()
		bullet = new /projectile/artifact
		shot_range = rand(2,6)
		if (prob(20))
			capricious = 1
		bullet.randomise()

	effect_touch(var/obj/O,var/mob/living/user)
		if (..())
			return
		if (capricious > -1)
			if (!friend || capricious)
				friend = user

	effect_process(var/obj/O)
		if (..())
			return
		var/turf/T = get_turf(O)
		if (!current_target)
			var/list/valid_targets = list()
			for (var/mob/living/M in view(shot_range,O))
				if (!target_is_valid(M,O))
					continue
				valid_targets += M
			if (valid_targets.len > 0)
				current_target = pick(valid_targets)
				T.visible_message("<strong>[O]</strong> turns to face [current_target]!")
				cycles_without_target = 0
			else
				cycles_without_target++
				if (cycles_without_target >= cycles_until_shutdown)
					cycles_without_target = 0
					O.ArtifactDeactivated()
		else
			if (target_is_valid(current_target,O) && istype(bullet,/projectile/artifact))
				shoot_projectile_ST(O, bullet, current_target)
			else
				current_target = null

	proc/target_is_valid(var/mob/living/M,var/obj/O)
		if (!M || !O)
			return FALSE
		if (M.stat == 2)
			return FALSE
		if (M == friend)
			return FALSE
		if (get_dist(M,O) > shot_range)
			return FALSE
		return TRUE