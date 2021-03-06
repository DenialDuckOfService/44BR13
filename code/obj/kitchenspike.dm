/obj/kitchenspike
	name = "a meat spike"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spike"
	desc = "A spike for collecting meat from animals"
	density = 1
	anchored = 1
	var/meat = 0
	var/occupied = 0

/obj/kitchenspike/attackby(obj/item/grab/G as obj, mob/user as mob)
	if (!istype(G, /obj/item/grab))
		return
	if (!ismonkey(G.affecting))
		boutput(user, "<span style=\"color:red\">They are too big for the spike, try something smaller!</span>")
		return

	if (occupied == 0)
		icon_state = "spikebloody"
		occupied = 1
		meat = 5
		var/mob/dead/observer/newmob
		visible_message("<span style=\"color:red\">[user] has forced [G.affecting] onto the spike, killing them instantly!</span>")
		if (G.affecting.client)
			newmob = new/mob/dead/observer(G.affecting)
			G.affecting:client:mob = newmob
		qdel(G.affecting)
		qdel(G)

	else
		boutput(user, "<span style=\"color:red\">The spike already has a monkey on it, finish collecting his meat first!</span>")

/obj/kitchenspike/attack_hand(mob/user as mob)
	if (..())
		return
	if (occupied)
		if (meat > 1)
			meat--
			new /obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat( loc )
			boutput(usr, "You remove some meat from the monkey.")
		else if (meat == 1)
			meat--
			new /obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat(loc)
			boutput(usr, "You remove the last piece of meat from the monkey!")
			icon_state = "spike"
			occupied = 0