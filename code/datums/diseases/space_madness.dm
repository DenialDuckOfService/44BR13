/ailment/disease/space_madness
	name = "Space Madness"
	scantype = "Psychological Condition"
	max_stages = 5
	spread = "Non-Contagious"
	cure = "Anti-Psychotics"
	reagentcure = list("haloperidol")
	associated_reagent = "loose screws"
	affected_species = list("Human")

/ailment/disease/space_madness/stage_act(var/mob/living/affected_mob,var/ailment_data/D)
	if (..())
		return
	if (affected_mob.job == "Clown")
		if (prob(6))
			var/icp = pick("Fuckin' magnets!", "Fuckin' rainbows!", "Magic everywhere in this bitch...", "Pure motherfuckin' miracles!", "Magic all around you and you don't even know it!")
			affected_mob.say("[icp]")
			return
	switch(D.stage)
		if (2)
			if (prob(10))
				boutput(affected_mob, pick("<span style=\"color:red\"><em><strong><font face =Tempus Sans ITC>Kill them all!!!!!</strong></em></FONT></span>", "<span style=\"color:red\"><em><strong><font face = Tempus Sans ITC>They are out to get you!</strong></FONT></em></span>", "<span style=\"color:red\"><em><strong><font face = Tempus Sans ITC>They know what you did!!!!</strong></FONT></em></span>", "<span style=\"color:red\"><em><strong><font face = Tempus Sans ITC>They are watching you!!!</strong></em></FONT></span>"))
		if (3)
			if (prob(8))
				for (var/mob/living/M in view(7,affected_mob))
					if (M!= affected_mob)
						boutput(affected_mob, "<strong>[M.name]</strong> says, \"[pick("I'm going to kill you!","I'm the the traitor.", "TRAITOR!")]\"")
						break
			if (prob(9))
				boutput(affected_mob, pick("<span style=\"color:red\"><em><strong><font face =Tempus Sans ITC>Kill them all!!!!!</strong></em></FONT></span>", "<span style=\"color:red\"><em><strong><font face = Tempus Sans ITC>They are out to get you!</strong></FONT></em></span>", "<span style=\"color:red\"><em><strong><font face = Tempus Sans ITC>They know what you did!!!!</strong></FONT></em></span>", "<span style=\"color:red\"><em><strong><font face = Tempus Sans ITC>They are watching you!!!</strong></em></FONT></span>"))

		if (4)
			if (prob(5))
				switch(rand(1,2))
					if (1)
						if (prob(50))
							fake_attack(affected_mob)
						else
							var/monkeys = rand(1,3)
							for (var/i = 0, i < monkeys, i++)
								fake_attackEx(affected_mob, 'icons/mob/monkey.dmi', "monkey1", "monkey ([rand(1, 1000)])")
					if (2)
						var/halluc_state = null
						var/halluc_name = null
						switch(rand(1,5))
							if (1)
								halluc_state = "pig"
								halluc_name = pick("pig", "DAT FUKKEN PIG")
							if (2)
								halluc_state = "spider"
								halluc_name = pick("giant black widow", "queen bitch spider", "OH FUCK A SPIDER")
							if (3)
								halluc_state = "dragon"
								halluc_name = pick("dragon", "Lord Cinderbottom", "SOME FUKKEN LIZARD THAT BREATHES FIRE")
							if (4)
								halluc_state = "slime"
								halluc_name = pick("red slime", "some gooey thing", "ANGRY CRIMSON POO")
							if (5)
								halluc_state = "shambler"
								halluc_name = pick("shambler", "strange creature", "OH GOD WHAT THE FUCK IS THAT THING?")
						fake_attackEx(affected_mob, 'icons/effects/hallucinations.dmi', halluc_state, halluc_name)
			if (prob(9))
				affected_mob.playsound_local(affected_mob.loc, pick("explosion", "punch", 'sound/vox/poo-vox.ogg', "clownstep", 'sound/weapons/armbomb.ogg', 'sound/weapons/Gunshot.ogg'), 50, 1)

			if (prob(8))
				for (var/mob/living/M in view(7,affected_mob))
					if (M!= affected_mob)
						boutput(affected_mob, "<strong>[M.name]</strong> says, \"[pick("I'm going to kill you!","I'm the the traitor.", "You are a cunt!")]\"")
						break

		if (5)
			if (prob(5))
				switch(rand(1,2))
					if (1)
						if (prob(50))
							fake_attack(affected_mob)
						else
							var/monkeys = rand(1,3)
							for (var/i = 0, i < monkeys, i++)
								fake_attackEx(affected_mob, 'icons/mob/monkey.dmi', "monkey1", "monkey ([rand(1, 1000)])")
					if (2)
						var/halluc_state = null
						var/halluc_name = null
						switch(rand(1,5))
							if (1)
								halluc_state = "pig"
								halluc_name = pick("pig", "DAT FUKKEN PIG")
							if (2)
								halluc_state = "spider"
								halluc_name = pick("giant black widow", "queen bitch spider", "OH FUCK A SPIDER")
							if (3)
								halluc_state = "dragon"
								halluc_name = pick("dragon", "Lord Cinderbottom", "SOME FUKKEN LIZARD THAT BREATHES FIRE")
							if (4)
								halluc_state = "slime"
								halluc_name = pick("red slime", "some gooey thing", "ANGRY CRIMSON POO")
							if (5)
								halluc_state = "shambler"
								halluc_name = pick("shambler", "strange creature", "OH GOD WHAT THE FUCK IS THAT THING?")
						fake_attackEx(affected_mob, 'icons/effects/hallucinations.dmi', halluc_state, halluc_name)
			if (prob(9))
				affected_mob.playsound_local(affected_mob.loc, pick("explosion", "punch", 'sound/vox/poo-vox.ogg', "clownstep", 'sound/weapons/armbomb.ogg', 'sound/weapons/Gunshot.ogg'), 50, 1)
			if (prob(6))
				if (affected_mob.client)
					affected_mob.client.dir = pick(1,1,1,2,3,4)

			if (prob(8))
				for (var/mob/living/M in view(7,affected_mob))
					if (M!= affected_mob)
						boutput(affected_mob, "<strong>[M.name]</strong> says, \"[pick("I'm going to kill you!","I'm the the traitor.", "You are a cunt!")]\"")
						break

/ailment/disease/space_madness/on_remove(var/mob/living/affected_mob, var/ailment_data/D)
	if (affected_mob && affected_mob.client)
		affected_mob.client.dir = 1 // Reset their view of the map. Yes, this was missing for many years (Convair880).
	..()
	return