/ailment/disease/flatline
	name = "Cardiac Arrest"
	scantype = "Medical Emergency"
	max_stages = 1
	spread = "The patient's heart has stopped."
	cure = "Electric Shock"
	affected_species = list("Human","Monkey")
	var/robo_restart = 0

/ailment/disease/flatline/stage_act(var/mob/living/affected_mob,var/ailment/D)
	if (..())
		return
	if (ishuman(affected_mob))
		var/mob/living/carbon/human/H = affected_mob
		if (!H.organHolder)
			H.cure_disease(D)
			return
		if (!H.organHolder.heart)
			H.cure_disease(D)
			return
		else if (H.organHolder.heart && H.organHolder.heart.robotic && !H.organHolder.heart.broken && !robo_restart)
			boutput(H, "<span style=\"color:red\">Your cyberheart detects a cardiac event and attempts to return to its normal rhythm!</span>")

			if (prob(20) && H.organHolder.heart.emagged)
				H.cure_disease(D)
				robo_restart = 1
				if (H.organHolder.heart.emagged)
					spawn (200)
						robo_restart = 0
				else
					spawn (300)
						robo_restart = 0
				spawn (30)
					boutput(H, "<span style=\"color:red\">Your cyberheart returns to its normal rhythm!</span>")
					return

			else if (prob(10))
				H.cure_disease(D)
				robo_restart = 1
				if (H.organHolder.heart.emagged)
					spawn (200)
						robo_restart = 0
				else
					spawn (300)
						robo_restart = 0
				spawn (30)
					boutput(H, "<span style=\"color:red\">Your cyberheart returns to its normal rhythm!</span>")
					return

			else
				robo_restart = 1
				if (H.organHolder.heart.emagged)
					spawn (200)
						robo_restart = 0
				else
					spawn (300)
						robo_restart = 0
				spawn (30)
					boutput(H, "<span style=\"color:red\">Your cyberheart fails to return to its normal rhythm!</span>")
		else
			if (H.get_oxygen_deprivation())
				H.take_brain_damage(3)
			else if (prob(10))
				H.take_brain_damage(1)

		H.weakened = max(H.weakened, 5)
		H.losebreath+=20
		H.take_oxygen_deprivation(20)
		H.updatehealth()