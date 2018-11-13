/mob/dead
	stat = 2

// dead

// No log entries for unaffected mobs (Convair880).
/mob/dead/ex_act(severity)
	return

/mob/dead/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return TRUE

/mob/dead/say_understands()
	return TRUE

/mob/dead/click(atom/target, params)
	if (targeting_spell)
		..()
	else
		if (get_dist(src, target) > 0)
			dir = get_dir(src, target)
		target.examine()

/mob/dead/projCanHit(projectile/P)
	return P.hits_ghosts

/mob/dead/say(var/message)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	if (dd_hasprefix(message, "*"))
		return emote(copytext(message, 2),1)

	logTheThing("diary", src, null, "(GHOST): [message]", "say")

	if (client && client.ismuted())
		boutput(src, "You are currently muted and may not speak.")
		return

	. = say_dead(message)

	for (var/mob/M in hearers(null, null))
		if (!M.stat)
			if (M.job == "Chaplain")
				if (prob (80))
					M.show_message("<span class='game'><em>You hear muffled speech... but nothing is there...</em></span>", 2)
				else
					M.show_message("<span class='game'><em>[stutter(message)]</em></span>", 2)
			else
				if (prob(90))
					return
				else if (prob (95))
					M.show_message("<span class='game'><em>You hear muffled speech... but nothing is there...</em></span>", 2)
				else
					M.show_message("<span class='game'><em>[stutter(message)]</em></span>", 2)

/mob/dead/emote(var/act, var/voluntary = 0) // fart
	if (!deadchat_allowed)
		show_text("<strong>Deadchat is currently disabled.</strong>")
		return

	var/message = null
	switch (lowertext(act))

		if ("fart")
			if (farting_allowed && emote_check(voluntary, 25, 1, 0))
				var/fluff = pick("spooky", "eerie", "ectoplasmic", "frightening", "terrifying", "ghoulish", "ghostly", "haunting", "morbid")
				var/fart_on_other = 0
				for (var/mob/living/M in loc)
					message = "<strong>[src]</strong> lets out \an [fluff] fart in [M]'s face!"
					fart_on_other = 1
					if (prob(95))
						break
					else
						M.show_text("<em>You feel \an [fluff] [pick("draft", "wind", "breeze", "chill", "pall")]...</em>")
						break
				if (!fart_on_other)
					message = "<strong>[src]</strong> lets out \an [fluff] fart!"

		if ("scream")
			if (emote_check(voluntary, 25, 1, 0))
				message = "<strong>[src]</strong> lets out \an [pick("spooky", "eerie", "frightening", "terrifying", "ghoulish", "ghostly", "haunting", "morbid")] [pick("wail", "screech", "shriek")]!"

		if ("dance")
			if (emote_check(voluntary, 100, 1, 0))
				switch (rand(1, 4))
					if (1) message = "<strong>[src]</strong> does the Monster Mash!"
					if (2) message = "<strong>[src]</strong> gets spooky with it!"
					if (3) message = "<strong>[src]</strong> boogies!"
					if (4) message = "<strong>[src]</strong> busts out some [pick("spooky", "eerie", "frightening", "terrifying", "ghoulish", "ghostly", "haunting", "morbid")] moves."
				if (prob(2)) // roll the probability first so we're not checking for critters each time this happens
					for (var/obj/critter/domestic_bee/responseBee in range(7, src))
						if (!responseBee.alive)
							continue
						responseBee.dance_response()
						break
					for (var/obj/critter/parrot/responseParrot in range(7, src))
						if (!responseParrot.alive)
							continue
						responseParrot.dance_response()
						break

		if ("flip")
			if (emote_check(voluntary, 100, 1, 0))
				message = "<strong>[src]</strong> does \an [pick("spooky", "eerie", "frightening", "terrifying", "ghoulish", "ghostly", "haunting", "morbid")] flip!"
				if (prob(50))
					animate_spin(src, "R", 1, 0)
				else
					animate_spin(src, "L", 1, 0)

		if ("wave","salute","nod")
			if (emote_check(voluntary, 10, 1, 0))
				message = "<strong>[src]</strong> [act]s."

	if (message)
		logTheThing("say", src, null, "EMOTE: [message]")
		/*for (var/mob/dead/O in viewers(src, null))
			O.show_*/visible_message("<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='message'>[message]</span></span>")
		return TRUE
	return FALSE
