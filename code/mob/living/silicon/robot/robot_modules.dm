/obj/item/robot_module
	name = "Cyborg Module"
	desc = "A blank cyborg module. It has no function in its current state."
	icon = 'icons/obj/robot_parts.dmi'
	icon_state = "mod-sta"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	w_class = 2.0
	item_state = "electronic"
	flags = FPRINT|TABLEPASS | CONDUCT
	var/list/modules = list()
	var/mod_hudicon = "unknown"
	var/mod_appearance = "robot"
	var/cosmetic_mods = null

	New() //Shit all the mods have - make sure to call ..() at the top of any New() in this class of item
		modules += new /obj/item/device/flashlight(src)
		modules += new /obj/item/crowbar(src)
		modules += new /obj/item/device/multitool(src)
		modules += new /obj/item/screwdriver(src)

		var/obj/item/device/pda2/cyborg/C = new /obj/item/device/pda2/cyborg(src)
		var/mob/living/silicon/robot/R = loc
		if (istype(R))
			C.name = "[R.name]'s PDA"
			C.owner = "[R.name]"
			modules += C

/obj/item/robot_module/standard
	name = "Standard Module"
	desc = "A general-purpose module. Intended to cover a wide variety of tasks."
	mod_hudicon = "standard"
	mod_appearance = "StaBot"

	New()
		..()
		cosmetic_mods = new /robot_cosmetic/standard(src)
		modules += new /obj/item/robojumper(src)
		modules += new /obj/item/extinguisher(src)
		modules += new /obj/item/wrench(src)
		modules += new /obj/item/pen(src)
		modules += new /obj/item/zippo/borg(src)
		modules += new /obj/item/device/analyzer(src)
		modules += new /obj/item/device/healthanalyzer/borg(src)
		modules += new /obj/item/device/camera_viewer(src)

/robot_cosmetic/standard
	fx = list(255,0,0)
	painted = 1
	paint = list(0,0,0)

/obj/item/robot_module/medical
	name = "Medical Module"
	desc = "Incorporates medical tools intended for use to save and preserve human life."
	icon_state = "mod-med"
	mod_hudicon = "medical"
	mod_appearance = "MedBot"

	New()
		..()
		cosmetic_mods = new /robot_cosmetic/medical(src)
		modules += new /obj/item/device/healthanalyzer/borg(src)
		modules += new /obj/item/device/reagentscanner(src)
		modules += new /obj/item/robodefibrilator(src)
		modules += new /obj/item/scalpel(src)
		modules += new /obj/item/circular_saw(src)
		modules += new /obj/item/hemostat(src)
		modules += new /obj/item/suture(src)
		modules += new /obj/item/reagent_containers/iv_drip/blood(src)
		modules += new /obj/item/reagent_containers/patch/burn/medbot(src)
		modules += new /obj/item/reagent_containers/patch/bruise/medbot(src)
		//modules += new /obj/item/patch_stack(src)
		modules += new /obj/item/reagent_containers/hypospray(src)
		modules += new /obj/item/reagent_containers/syringe(src)
		modules += new /obj/item/reagent_containers/syringe(src)
		modules += new /obj/item/reagent_containers/glass/beaker/large/epinephrine(src)
		modules += new /obj/item/reagent_containers/glass/beaker/large/brute(src)
		modules += new /obj/item/reagent_containers/glass/beaker/large/burn(src)
		modules += new /obj/item/reagent_containers/glass/beaker/large/antitox(src)
		modules += new /obj/item/reagent_containers/dropper(src)

/robot_cosmetic/medical
	head_mod = "Medical Mirror"
	ches_mod = "Medical Insignia"
	fx = list(0,255,0)
	painted = 1
	paint = list(150,150,150)

/obj/item/robot_module/engineering
	name = "Engineering Module"
	desc = "A module designed to allow for station maintenance and repair work."
	icon_state = "mod-eng"
	mod_hudicon = "engineer"
	mod_appearance = "EngBot"

	New()
		..()
		cosmetic_mods = new /robot_cosmetic/engineering(src)
		modules += new /obj/item/robojumper(src)
		modules += new /obj/item/atmosporter(src)
		modules += new /obj/item/extinguisher(src)
		modules += new /obj/item/weldingtool(src)
		modules += new /obj/item/wrench(src)
		modules += new /obj/item/device/analyzer(src)
		modules += new /obj/item/device/t_scanner(src)
		modules += new /obj/item/wirecutters(src)
		var/obj/item/cable_coil/W = new /obj/item/cable_coil(src)
		W.amount = 1000
		modules += W
		modules += new /obj/item/electronics/scanner(src)
		modules += new /obj/item/electronics/soldering(src)

/robot_cosmetic/engineering
	fx = list(255,255,0)
	painted = 1
	paint = list(130,150,0)

/obj/item/robot_module/janitor
	name = "Janitorial Module"
	desc = "Cleaning and sanitation tools to keep the station clean and the crew healthy."
	icon_state = "mod-jan"
	mod_hudicon = "janitor"
	mod_appearance = "JanBot"

	New()
		..()
		cosmetic_mods = new /robot_cosmetic/janitor(src)
		modules += new /obj/item/spraybottle/cleaner(src)
		modules += new /obj/item/mop(src)
		modules += new /obj/item/reagent_containers/glass/bucket(src)
		modules += new /obj/item/extinguisher(src)
		modules += new /obj/item/device/analyzer(src)

/robot_cosmetic/janitor
	head_mod = "Janitor Cap"
	fx = list(0,255,0)
	painted = 1
	paint = list(90,0,90)

/obj/item/robot_module/brobot
	name = "Bro Bot Module"
	desc = "Become the life of the party using tools for fun and entertainment."
	icon_state = "mod-bro"
	mod_hudicon = "brobot"
	mod_appearance = "BroBot"

	New()
		..()
		cosmetic_mods = new /robot_cosmetic/brobot(src)
		modules += new /obj/item/noisemaker(src)
		modules += new /obj/item/robot_foodsynthesizer(src)
		modules += new /obj/item/reagent_containers/food/drinks/bottle/beer/borg(src)
		modules += new /obj/item/reagent_containers/food/drinks/drinkingglass(src)
		modules += new /obj/item/coin_bot(src)
		modules += new /obj/item/dice_bot(src)
		modules += new /obj/item/c_tube(src)
		modules += new /obj/item/zippo/borg(src)

/robot_cosmetic/brobot
	head_mod = "Afro and Shades"
	legs_mod = "Disco Flares"
	fx = list(90,0,90)
	painted = 0

/obj/item/robot_module/hydro
	name = "Hydroponics Module"
	desc = "Assist in the production of healthy and hearty crops with these gardening tools."
	icon_state = "mod-gar"
	mod_hudicon = "hydroponics"
	mod_appearance = "GarBot"

	New()
		..()
		cosmetic_mods = new /robot_cosmetic/hydro(src)
		modules += new /obj/item/reagent_containers/glass/wateringcan(src)
		modules += new /obj/item/reagent_containers/glass/compostbag(src)
		modules += new /obj/item/seedplanter(src)
		modules += new /obj/item/plantanalyzer(src)
		modules += new /obj/item/wrench(src)
		modules += new /obj/item/device/igniter(src)
		modules += new /obj/item/saw/cyborg(src)
		modules += new /obj/item/satchel/hydro(src)
//		modules += new /obj/item/borghose(src)
//		modules += new /obj/item/reagent_containers/food/drinks/juicer(src)

/robot_cosmetic/hydro
	fx = list(0,255,255)
	painted = 1
	paint = list(0,120,0)

/obj/item/robot_module/construction
	name = "Construction Module"
	desc = "Engage in construction projects using tools for rapid building."
	icon_state = "mod-con"
	mod_hudicon = "construction"
	mod_appearance = "ConBot"

	New()
		..()
		cosmetic_mods = new /robot_cosmetic/construction(src)
		modules += new /obj/item/wrench(src)
		modules += new /obj/item/wirecutters(src)

		var/obj/item/rcd/R = new /obj/item/rcd(src)
		R.matter = 30
		modules += R

		var/obj/item/tile/steel/T = new /obj/item/tile/steel(src)
		T.amount = 500
		modules += T

		var/obj/item/rods/steel/Ro = new /obj/item/rods/steel(src)
		Ro.amount = 500
		modules += Ro

		var/obj/item/sheet/steel/M = new /obj/item/sheet/steel(src)
		M.amount = 500
		modules += M

		var/obj/item/sheet/glass/G = new /obj/item/sheet/glass(src)
		G.amount = 500
		modules += G

		var/obj/item/cable_coil/W = new /obj/item/cable_coil(src)
		W.amount = 500
		modules += W

/robot_cosmetic/construction
	fx = list(0,240,160)
	painted = 1
	paint = list(0,120,80)

/obj/item/robot_module/mining
	name = "Mining Module"
	desc = "Tools for use in the excavation and transportation of valuable minerals."
	icon_state = "mod-min"
	mod_hudicon = "mining"
	mod_appearance = "MinBot"

	New()
		..()
		cosmetic_mods = new /robot_cosmetic/mining(src)
		modules += new /obj/item/mining_tool/drill(src)
		modules += new /obj/item/ore_scoop/borg(src)
		modules += new /obj/item/cargotele(src)
		modules += new /obj/item/oreprospector(src)
		modules += new /obj/item/satchel/mining/large(src)
		modules += new /obj/item/satchel/mining/large(src)
		modules += new /obj/item/device/gps(src)
		modules += new /obj/item/extinguisher(src)

/robot_cosmetic/mining
	head_mod = "Hard Hat"
	fx = list(0,255,255)
	painted = 1
	paint = list(130,90,0)

/obj/item/robot_module/chemistry
	name = "Chemistry Module"
	desc = "Beakers, syringes and other tools to enable a cyborg to assist in the research of chemicals."
	icon_state = "mod-chem"
	mod_hudicon = "chemistry"
	mod_appearance = "ChemBot"

	New()
		..()
		cosmetic_mods = new /robot_cosmetic/chemistry(src)
		modules += new /obj/item/device/healthanalyzer/borg(src)
		modules += new /obj/item/device/reagentscanner(src)
		modules += new /obj/item/robot_chemaster(src)
		modules += new /obj/item/reagent_containers/syringe(src)
		modules += new /obj/item/reagent_containers/syringe(src)
		modules += new /obj/item/reagent_containers/dropper(src)
		modules += new /obj/item/reagent_containers/dropper/mechanical(src)
		modules += new /obj/item/reagent_containers/food/drinks/drinkingglass(src)
		modules += new /obj/item/reagent_containers/glass/beaker/large(src)
		modules += new /obj/item/reagent_containers/glass/beaker/large(src)
		modules += new /obj/item/reagent_containers/glass/beaker/large(src)
		modules += new /obj/item/extinguisher(src)

/robot_cosmetic/chemistry
	ches_mod = "Lab Coat"
	fx = list(0,0,255)
	painted = 1
	paint = list(0,0,100)

/obj/item/robot_module/construction_worker
	name = "Construction Worker Module"
	desc = "Everything a construction worker requires."
	icon_state = "mod-con"
	mod_hudicon = "construction"
	mod_appearance = "ConBot"

	New()
		..()
		cosmetic_mods = new /robot_cosmetic/construction(src)
		modules += new /obj/item/wrench(src)
		modules += new /obj/item/wirecutters(src)
		modules += new /obj/item/weldingtool(src)

		var/obj/item/rcd/R = new /obj/item/rcd(src)
		R.matter = 30
		modules += R

		var/obj/item/tile/steel/T = new /obj/item/tile/steel(src)
		T.amount = 500
		modules += T

		var/obj/item/rods/steel/Ro = new /obj/item/rods/steel(src)
		Ro.amount = 500
		modules += Ro

		var/obj/item/sheet/steel/M = new /obj/item/sheet/steel(src)
		M.amount = 500
		modules += M

		var/obj/item/sheet/glass/G = new /obj/item/sheet/glass(src)
		G.amount = 500
		modules += G

		var/obj/item/cable_coil/W = new /obj/item/cable_coil(src)
		W.amount = 500
		modules += W

		modules += new /obj/item/electronics/scanner(src)
		modules += new /obj/item/electronics/soldering(src)
		modules += new /obj/item/room_planner(src)
		modules += new /obj/item/room_marker(src)
		modules += new /obj/item/extinguisher(src)

/obj/item/robot_module/construction_ai
	New()
		..()
		var/obj/item/rcd/R = new /obj/item/rcd(src)
		R.matter = 30
		modules += R

		var/obj/item/cable_coil/W = new /obj/item/cable_coil(src)
		W.amount = 500
		modules += W

		modules += new /obj/item/electronics/scanner(src)
		modules += new /obj/item/electronics/soldering(src)
		modules += new /obj/item/room_planner(src)
		modules += new /obj/item/room_marker(src)