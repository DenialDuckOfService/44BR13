/ailment/disability/deaf
	name = "Deafness"
	max_stages = 1
	cure = "Unknown"
	affected_species = list("Human","Monkey")

/ailment/disability/deaf/stage_act(var/mob/living/affected_mob,var/ailment_data/D)
	if (..())
		return
	var/mob/living/M = D.affected_mob
	M.take_ear_damage(5, 1)