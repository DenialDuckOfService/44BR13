/recipe
	var/egg_amount = 0
	var/flour_amount = 0
	var/water_amount = 0
	var/monkeymeat_amount = 0
	var/humanmeat_amount = 0
	var/synthmeat_amount = 0 //temporary, but whatever!
	var/donkpocket_amount = 0
	var/obj/extra_item = null // This is if an extra item is needed, eg a butte for an assburger
	var/creates = "" // The item that is spawned when the recipe is made

/recipe/donut
	egg_amount = 1
	flour_amount = 1
	creates = "/obj/item/reagent_containers/food/snacks/donut"

/recipe/monkeyburger
	egg_amount = 0
	flour_amount = 1
	monkeymeat_amount = 1
	creates = "/obj/item/reagent_containers/food/snacks/burger/monkeyburger"

/recipe/synthburger
	egg_amount = 0
	flour_amount = 1
	synthmeat_amount = 1
	creates = "/obj/item/reagent_containers/food/snacks/burger/synthburger"

/recipe/humanburger
	flour_amount = 1
	humanmeat_amount = 1
	creates = "/obj/item/reagent_containers/food/snacks/burger/humanburger"

/recipe/brainburger
	flour_amount = 1
	extra_item = /obj/item/organ/brain
	creates = "/obj/item/reagent_containers/food/snacks/burger/brainburger"

/recipe/assburger
	flour_amount = 1
	extra_item = /obj/item/clothing/head/butt
	creates = "/obj/item/reagent_containers/food/snacks/burger/assburger"

/recipe/roburger/
	flour_amount = 1
	extra_item = /obj/item/parts/robot_parts/head
	creates = "/obj/item/reagent_containers/food/snacks/burger/roburger"

/recipe/heartburger
	flour_amount = 1
	extra_item = /obj/item/organ/heart
	creates = "/obj/item/reagent_containers/food/snacks/burger/heartburger"

/recipe/waffles
	egg_amount = 2
	flour_amount = 2
	creates = "/obj/item/reagent_containers/food/snacks/waffles"

/recipe/meatball
	monkeymeat_amount = 1
	humanmeat_amount = 1
	creates = "/obj/item/reagent_containers/food/snacks/meatball"

/recipe/pie
	flour_amount = 2
	extra_item = /obj/item/reagent_containers/food/snacks/plant/banana
	creates = "/obj/item/reagent_containers/food/snacks/pie/custard"

/recipe/donkpocket
	flour_amount = 1
	extra_item = /obj/item/reagent_containers/food/snacks/meatball
	creates = "/obj/item/reagent_containers/food/snacks/donkpocket"

/recipe/donkpocket_warm
	donkpocket_amount = 1
	creates = "/obj/item/reagent_containers/food/snacks/donkpocket"

/recipe/popcorn
	extra_item = /obj/item/reagent_containers/food/snacks/plant/corn
	creates = "/obj/item/reagent_containers/food/snacks/popcorn"
