/ailment/disability/badvision
	name = "Impaired Vision"
	max_stages = 1
	cure = "Unknown"
	affected_species = list("Human","Monkey")

/ailment/disability/badvision/stage_act(var/mob/living/affected_mob,var/ailment_data/D)
	if (..())
		return
	affected_mob.change_eye_blurry(5)