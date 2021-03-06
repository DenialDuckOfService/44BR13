/mob/living/carbon/human/glitchy
	var/list/glitchy_noises = list('sound/machines/romhack1.ogg', 'sound/machines/romhack3.ogg', 'sound/machines/fortune_greeting_broken.ogg',
	'sound/effects/glitchy1.ogg', 'sound/effects/glitchy2.ogg', 'sound/effects/glitchy3.ogg', 'sound/items/hellhorn_12.ogg')

	New()
		..()
		spawn (0)
			rename_self()
			sound_burp = pick(glitchy_noises)
			sound_malescream = pick(glitchy_noises)
			sound_femalescream = pick(glitchy_noises)
			sound_fart = pick(glitchy_noises)
			sound_snap = pick(glitchy_noises)
			sound_fingersnap = pick(glitchy_noises)
			reagents.add_reagent("stimulants", 200)
			equip_if_possible(new /obj/item/clothing/shoes/red(src), slot_shoes)
			equip_if_possible(new /obj/item/clothing/under/misc/chaplain(src), slot_w_uniform)
			sleep(10)
			bioHolder.mobAppearance.UpdateMob()

	Life(controller/process/mobs/parent)
		if (..(parent))
			return TRUE

		if (prob(5))
			rename_self()
			for (var/atom/A in range(3,src))
				glitch_up(A)

		glitch_up(src)

		if (prob(33))
			var/turf/T = get_turf(src)
			glitch_up(T)

	Bump(atom/movable/AM, yes)
		..()
		glitch_up(AM)

	get_age_pitch()
		..()
		return 1.0 + 0.5*(30 - rand(1,120))/80

	proc/rename_self()
		var/assembled_name = pick(first_names_male) + " " + pick(last_names)
		assembled_name = corruptText(assembled_name,75)
		real_name = assembled_name

	proc/glitch_up(var/atom/A)
		if (!A || !A.icon)
			return
		A.icon_state = pick(icon_states(A.icon))
		A.name = corruptText(A.name,10)
		A.alpha = rand(100,255)
		A.color = rgb(rand(0,255),rand(0,255),rand(0,255))
		playsound(get_turf(src), pick(glitchy_noises), 80, 0, 0, get_age_pitch())

		switch(rand(1,5))
			if (1)
				animate_glitchy_fuckup1(A)
			if (2)
				animate_glitchy_fuckup2(A)
			if (3)
				animate_glitchy_fuckup3(A)
			if (4)
				animate_rainbow_glow(A)
			else
				animate_spin(A, dir = "R", T = 0.2, looping = -1)
				///proc/animate_spin(var/atom/A, var/dir = "L", var/T = 1, var/looping = -1)
