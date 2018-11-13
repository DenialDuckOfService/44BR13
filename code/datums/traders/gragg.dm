/trader/gragg
	// Rockworm guy.
	// Always buys mineral items from the station. Very honest and straightforward.
	name = "Gragg"
	picture = "gragg.png"
	crate_tag = "GRAGG"
	hiketolerance = 15
	base_patience = list(4,8)
	chance_leave = 10
	chance_arrive = 33

	max_goods_buy = 3
	max_goods_sell = 3

	base_goods_buy = list(/commodity/trader/gragg/rock,
	/commodity/trader/gragg/mauxite,
	/commodity/trader/gragg/bohrum,
	/commodity/trader/gragg/cobryl,
	/commodity/trader/gragg/syreline)

	base_goods_sell = list(/commodity/trader/gragg/char,
	/commodity/trader/gragg/erebite,
	/commodity/trader/gragg/cerenkite,
	/commodity/trader/gragg/plasmastone,
	/commodity/trader/gragg/uqill,
	/commodity/trader/gragg/artifact)

	dialogue_greet = list("HELLO. WANT BUY TASTY ROCKS. TRADE?",
	"HUNGRY. WANT ORE FOR EAT. TRADE?",
	"WANT DELICIOUS ORE. SELL YOU NOT SO DELICIOUS ORE. TRADE?")
	dialogue_leave = list("UGH. FUCK THIS.",
	"YOU TOO STUPID. GOING ELSEWHERE NOW.",
	"SQUISHY BRAIN TOO DUMB. STONE BRAIN BETTER. LEAVING NOW.")
	dialogue_purchase = list("ENJOY. GOT TASTY ROCKS TO TRADE?",
	"NOT KNOW WHY WANT THAT. BUT YOURS NOW ANYWAY.",
	"DEAL. NOW, GOT ORE FOR ME?")
	dialogue_haggle_accept = list("UGH. FINE.",
	"OKAY. BUT LESS TALK. MORE SELL ORE.",
	"FUCK SAKE. FINE.",
	"FINE. WHATEVER. CAN HAVE ORE YET?",
	"FINE. BUT ENOUGH TALK. TRADE NOW OR FORGET IT.")
	dialogue_haggle_reject = list("NO.",
	"NOT *THAT* HUNGRY. CHRIST.",
	"NOT GOOD DEAL. YOU STUPID?",
	"NO. NO. NO.",
	"NO. NO MORE TALK. TRADE NOW OR FORGET IT.")
	dialogue_wrong_haggle_accept = list("OK. NOT GOING COMPLAIN.")
	dialogue_wrong_haggle_reject = list("WHAT? NOT MAKE SENSE. YOU STUPID?")
	dialogue_cant_afford_that = list("NOT ENOUGH CREDITS. MAYBE SELL ORE TO ME FIRST.",
	"NO. TOO EXPENSIVE FOR YOU.",
	"HUMAN BANK ACCOUNT NOT HAVE ENOUGH DELICIOUS GOLD.")
	dialogue_out_of_stock = list("SORRY. NO MORE OF THAT.",
	"RAN OUT OF THAT.")

	set_up_goods()
		..()
		var/commodity/COM = new /commodity/trader/gragg/starstone(src)
		goods_buy += COM

// Gragg is selling these things

/commodity/trader/gragg/char
	comname = "Char"
	comtype = /obj/item/raw_material/char
	price_boundary = list(20,40)
	possible_names = list("SELLING CHAR. NOT EVEN FOOD.",
	"SELLING CHAR ORE. TRIED TO COOK. BURNT IT.",
	"SELLING CHAR. FLAKY. GROSS.")

/commodity/trader/gragg/erebite
	comname = "Strange Red Rock"
	comtype = /obj/item/raw_material/erebite
	amount = 5
	price_boundary = list(300,500)
	possible_names = list("SELLING GROSS SPICY ROCK. NOT GOOD EAT.",
	"SELLING WEIRD RED ROCK. GIVES GAS.",
	"SELLING TERRIBLE TO EAT RED ROCK.")

/commodity/trader/gragg/cerenkite
	comname = "Toxic Blue Rock"
	comtype = /obj/item/raw_material/cerenkite
	amount = 5
	price_boundary = list(200,400)
	possible_names = list("SELLING BAD TASTING ROCK. NOT GOOD EAT.",
	"SELLING GLOWY BLUE ROCK. MAKES SICK.",
	"SELLING TERRIBLE TO EAT BLUE ROCK.")

/commodity/trader/gragg/plasmastone
	comname = "Volatile Purple Rock"
	comtype = /obj/item/raw_material/plasmastone
	amount = 5
	price_boundary = list(400,700)
	possible_names = list("SELLING AWFUL PURPLE ROCK. TASTE TERRIBLE.",
	"SELLING NASTY PURPLE ROCK. EXPLODE KIND OF EASY.",
	"SELLING TERRIBLE TO EAT PURPLE ROCK.")

/commodity/trader/gragg/uqill
	comname = "Rock Worm Poop"
	comtype = /obj/item/raw_material/uqill
	amount = 5
	price_boundary = list(500,600)
	possible_alt_types = list(/obj/item/raw_material/gemstone)
	alt_type_chance = 10
	possible_names = list("SELLING ROCK WORM POOP. NOT KNOW WHY YOU WANT THAT. BUT THERE IT IS.",
	"SELLING ROCK WORM POOP. NOT EATING THAT.",
	"SELLING SHIT. LITERAL SHIT. NEED MONEY OKAY. NO JUDGING.")

/commodity/trader/gragg/artifact
	comname = "Unknown Item"
	comtype = /obj/item/artifact
	amount = 1
	price_boundary = list(1000,50000)
	possible_alt_types = list(/obj/item/artifact/activator_key,/obj/item/artifact/forcewall_wand,
	/obj/item/artifact/melee_weapon,/obj/item/artifact/teleport_wand,
	/obj/item/cell/artifact,/obj/item/gun/energy/artifact,/obj/item/raw_material/miracle,/obj/item/mining_tool)
	alt_type_chance = 90
	possible_names = list("SELLING WEIRD THING I DUG UP. DONT KNOW WHAT IS.",
	"ODD LITTLE THING. DUG IT UP. NO IDEA. CAN BUY IF WANT.")

// Gragg wants these things

/commodity/trader/gragg/rock
	comname = "Rock"
	comtype = /obj/item/raw_material/rock
	price_boundary = list(30,60)
	possible_names = list("BUYING PLAIN ROCK. NOT ORE, JUST ROCK. STOCKING UP ON FOOD.",
	"BUYING PLAIN ROCK. NOT METAL OR CRYSTAL, JUST STONE.")

/commodity/trader/gragg/mauxite
	comname = "Mauxite"
	comtype = /obj/item/raw_material/mauxite
	price_boundary = list(60,120)
	possible_names = list("BUYING MAUXITE. CRUNCHY AND DELICIOUS.",
	"BUYING MAUXITE. GOOD MEAL FOR LITHOVORE. HELPS GROW STRONG CARAPACE.")

/commodity/trader/gragg/bohrum
	comname = "Bohrum"
	comtype = /obj/item/raw_material/bohrum
	price_boundary = list(250,400)
	possible_names = list("BUYING BOHRUM. GOES GOOD IN STONE SOUP.",
	"BUYING BOHRUM. VERY DENSE. GOOD AND FILLING.")

/commodity/trader/gragg/cobryl
	comname = "Cobryl"
	comtype = /obj/item/raw_material/cobryl
	price_boundary = list(200,600)
	possible_names = list("BUYING COBRYL. MAKE GOOD SNACK.",
	"BUYING COBRYL. TASTY.")

/commodity/trader/gragg/syreline
	comname = "Syreline"
	comtype = /obj/item/raw_material/syreline
	price_boundary = list(800,5000)
	possible_names = list("BUYING SYRELINE. NICE SWEET TREAT NOW AND THEN.",
	"BUYING SYRELINE. NOT TOO MANY THOUGH. DON'T WANT FAT.")

/commodity/trader/gragg/starstone
	comname = "Rare star-shaped jewel"
	comtype = /obj/item/raw_material/starstone
	price_boundary = list(3000000,3000000)
	possible_names = list("WANT BUY PALE BLUE STAR-SHAPED GEMSTONE. EXTREMELY RARE. SELL TO ME IF FIND.")