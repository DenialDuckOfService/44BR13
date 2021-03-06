
/obj/item/reagent_containers/food/snacks/pie
	name = "pie"
	icon = 'icons/obj/foodNdrink/food_dessert.dmi'
	desc = "A null pie. You shouldn't be able to see this!"
	needspoon = 1
	var/splat = 0 // for thrown pies

	throw_impact(atom/hit_atom)
		if (ismob(hit_atom) && splat)
			var/mob/M = hit_atom
			visible_message("<span style=\"color:red\">[src] splats in [M]'s face!</span>")
			playsound(get_turf(src), "sound/effects/splat.ogg", 100, 1)
			M.change_eye_blurry(rand(5,10))
			M.take_eye_damage(rand(0, 2), 1)
		else
			..()

/obj/item/reagent_containers/food/snacks/pie/custard
	name = "custard pie"
	desc = "It smells delicious. You just want to plant your face in it."
	icon_state = "pie"
	splat = 1
	needspoon = 1
	amount = 3
	throwforce = 0
	force = 0

/obj/item/reagent_containers/food/snacks/pie/apple
	name = "apple pie"
	desc = "It smells delicious."
	icon_state = "pie"
	amount = 3
	heal_amt = 4

/obj/item/reagent_containers/food/snacks/pie/lime
	name = "key lime pie"
	desc = "Shouldn't the topping be white? Space is weird."
	icon_state = "limepie"
	amount = 3
	heal_amt = 4
	var/has_key = 0
	var/static/had_key = 0
	initial_volume = 30

	New()
		..()
		if (prob(6) && !had_key)
			had_key = 1
			has_key = 1

		reagents.add_reagent("juice_lime", 15)
		return

	heal(var/mob/M)
		..()
		if (has_key)
			has_key = 0
			M.visible_message("<span style=\"color:red\">[M] pulls a key out of [src]!</span>","<span style=\"color:red\">You discover an iron key in [src]! Gross!</span>")
			new /obj/item/device/key/haunted(get_turf(src))
		return

/obj/item/reagent_containers/food/snacks/pie/lemon
	name = "lemon meringue pie"
	desc = "A fine use of fruit curd."
	icon_state = "lemonpie"
	amount = 3
	heal_amt = 4
	initial_volume = 30

	New()
		..()
		reagents.add_reagent("juice_lemon", 15)

/obj/item/reagent_containers/food/snacks/pie/strawberry
	name = "strawberry pie"
	desc = "It smells delicious."
	icon_state = "strawberrypie"
	amount = 3
	heal_amt = 4
	initial_volume = 30

	New()
		..()
		reagents.add_reagent("juice_strawberry", 15)

/obj/item/reagent_containers/food/snacks/pie/pumpkin
	name = "pumpkin pie"
	desc = "An autumn favourite."
	icon_state = "pumpie"
	amount = 3
	heal_amt = 4

/obj/item/reagent_containers/food/snacks/pie/cream
	name = "cream pie"
	desc = "More often used in pranks than culinary matters..."
	icon_state = "creampie"
	splat = 1
	needspoon = 1
	throwforce = 0
	force = 0
	amount = 2
	heal_amt = 6

/obj/item/reagent_containers/food/snacks/pie/anything
	name = "anything pie"
	desc = "An empty anything pie. You shouldn't be able to see this!"
	icon_state = "pie"
	amount = 3
	heal_amt = 4

	throw_impact(atom/hit_atom)
		if (contents)
			var/atom/randomContent
			if (contents.len >= 1)
				randomContent = pick(contents)
			else
				randomContent = src
			if (randomContent != src)
				randomContent.throw_impact(hit_atom)
			hit_atom.attackby(randomContent, usr)
			if (ismob(hit_atom))
				playsound(loc, "sound/effects/splat.ogg", 100, 1)
				var/mob/M = hit_atom
				if (M == usr)
					visible_message("<span style=\"color:red\">[usr] fumbles and smacks the [src] into their own face!</span>")
				else
					visible_message("<span style=\"color:red\">[src] smacks into [M]!</span>")

/obj/item/reagent_containers/food/snacks/pie/slurry
	name = "slurry pie"
	desc = "Though dangerous to eat raw, the slurrypod produces a fine, tart pie noted for its curative properties."
	icon_state = "slurrypie"
	amount = 3
	heal_amt = 5
	initial_volume = 30

	New()
		..()
		reagents.add_reagent("mutadone", 15)

/obj/item/reagent_containers/food/snacks/pie/bacon
	name = "bacon pie"
	desc = "Named in honor of Sir Francis Bacon, who tragically died as the result of an early experiment into the field of bacon ice cream."
	icon_state = "baconpie"
	amount = 3
	heal_amt = 6
	initial_volume = 80

	New()
		..()
		reagents.add_reagent("porktonium", 75)

	heal(var/mob/M)
		M.nutrition += 500
		return

/obj/item/reagent_containers/food/snacks/pie/ass
	name = "asspie"
	desc = "Awkward."
	icon_state = "asspie"
	splat = 1
	throwforce = 0
	force = 0
	amount = 3
	heal_amt = 2

/obj/item/reagent_containers/food/snacks/pie/pot
	name = "space-chicken pot pie"
	desc = "Space-chickens are identical to regular chickens, but in space.  This is a pastry filled with their cooked flesh, some vegetables, and a cream gravy."
	icon_state = "pie"
	heal_amt = 6
	amount = 3
	initial_volume = 30

	New()
		..()
		reagents.add_reagent("chickensoup", 20)
