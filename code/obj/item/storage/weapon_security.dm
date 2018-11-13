
/* -------------------- Security -------------------- */

/obj/item/storage/box/handcuff_kit
	name = "spare handcuff box"
	icon_state = "handcuff"
	desc = "A box filled with handcuffs for your arresting needs. Or whatever."
	spawn_contents = list(/obj/item/handcuffs = 7)

/obj/item/storage/box/id_kit
	name = "spare ID box"
	icon_state = "id"
	desc = "A box filled with blank ID cards for new crewmembers or crewmembers who have lost theirs."
	spawn_contents = list(/obj/item/card/id = 7)

/obj/item/storage/box/evidence
	name = "evidence box"
	icon_state = "evidence"
	desc = "A box for collecting forensics evidence."

/* Phased out with the forensic scanner overhaul. Was useless anyway (Convair880).
/obj/item/storage/box/fcard_kit
	name = "fingerprint card box"
	icon_state = "id"
	spawn_contents = list(/obj/item/f_card = 7)
*/

// For sec officers and the HoS. Really love spawning with a full backpack (Convair880).
/obj/item/storage/box/security_starter_kit
	name = "security starter kit"
	icon_state = "handcuff"
	desc = "Essential security supplies. Keep out of reach of the clown."
	spawn_contents = list(/obj/item/handcuffs = 3,\
	/obj/item/device/flash,\
	/obj/item/whistle)

/* -------------------- Guns & Ammo -------------------- */

/obj/item/storage/box/revolver
	name = "revolver box"
	icon_state = "revolver"
	desc = "A box containing a syndicate revolver and ammo."
	// cogwerks - i think the ammo boxes are dumb, giving the starting box more ammo
	spawn_contents = list(/obj/item/gun/kinetic/revolver,\
	/obj/item/ammo/bullets/a357 = 3,\
	/obj/item/ammo/bullets/a357/AP = 2)

/obj/item/storage/box/detectivegun
	name = ".38 revolver box"
	icon_state = "revolver"
	desc = "A box containing a .38 caliber revolver and ammunition."
	// Reduced the amount of ammo. The detective had four lethal and five stun speedloaders total in his closet, perhaps a bit too much (Convair880).
	spawn_contents = list(/obj/item/gun/kinetic/detectiverevolver,\
	/obj/item/ammo/bullets/a38 = 2,\
	/obj/item/ammo/bullets/a38/stun = 2)

/obj/item/storage/box/ak47 // cogwerks, terrorism update
	name = "rifle box"
	icon_state = "revolver"
	desc = "A box containing a syndicate rifle and some ammo."
	// this might be a terrible idea giving them so much ammo, but whatevs
	spawn_contents = list(/obj/item/gun/kinetic/ak47,\
	/obj/item/ammo/bullets/ak47 = 2)

/obj/item/storage/box/pistol
	name = "suppressed pistol box"
	icon_state = "revolver"
	desc = "A box containing a sneaky pistol and some ammo."
	// this might be a terrible idea giving them so much ammo, but whatevs
	spawn_contents = list(/obj/item/gun/kinetic/silenced_22,\
	/obj/item/ammo/bullets/bullet_22 = 3)

/obj/item/storage/box/derringer
	name = "derringer box"
	icon_state = "revolver"
	desc = "A box containing a derringer and some ammo."
	spawn_contents = list(/obj/item/gun/kinetic/derringer,\
	/obj/item/ammo/bullets/derringer = 4)

/obj/item/storage/box/shotgun
	name = "shotgun box"
	icon_state = "revolver"
	desc = "A box containing a high-powered shotgun and some ammo."
	spawn_contents = list(/obj/item/gun/kinetic/spacker,\
	/obj/item/ammo/bullets/a12 = 4)

/obj/item/storage/box/revolver_ammo
	name = "revolver ammo box"
	icon_state = "revolver"
	desc = "A box containing armour-piercing (AP) revolver rounds."
	spawn_contents = list(/obj/item/ammo/bullets/a357/AP = 3)

/obj/item/storage/box/revolver_ammo2
	name = "revolver ammo box"
	icon_state = "revolver"
	desc = "A box containing standard revolver rounds."
	spawn_contents = list(/obj/item/ammo/bullets/a357 = 3)

/obj/item/storage/box/ammo38AP // 2 TC for 1 speedloader was very poor value compared to other guns and traitor items in general (Convair880).
	name = ".38 AP ammo box"
	icon_state = "revolver"
	desc = "A box containing a couple of AP speedloaders for a .38 Special revolver."
	spawn_contents = list(/obj/item/ammo/bullets/a38/AP = 3)

/obj/item/storage/box/flaregun // For surplus crates (Convair880).
	name = "flare gun box"
	icon_state = "revolver"
	desc = "A box containing a flare gun and spare ammo."
	spawn_contents = list(/obj/item/gun/kinetic/flaregun,\
	/obj/item/ammo/bullets/flare)

/* -------------------- Grenades -------------------- */

/obj/item/storage/box/flashbang_kit
	name = "flashbang box"
	desc = "<FONT color=red><strong>WARNING: Do not use without reading these preautions!</strong></FONT><br><strong>These devices are extremely dangerous and can cause blindness or deafness if used incorrectly.</strong><br>The chemicals contained in these devices have been tuned for maximal effectiveness and due to<br>extreme safety precuaiotn shave been incased in a tamper-proof pack. DO NOT ATTEMPT TO OPEN<br>FLASH WARNING: Do not use continually. Excercise extreme care when detonating in closed spaces.<br>&emsp;Make attemtps not to detonate withing range of 2 meters of the intended target. It is imperative<br>&emsp;that the targets visit a medical professional after usage. Damage to eyes increases extremely per<br>&emsp;use and according to range. Glasses with flash resistant filters DO NOT always work on high powered<br>&emsp;flash devices such as this. <strong>EXERCISE CAUTION REGARDLESS OF CIRCUMSTANCES</strong><br>SOUND WARNING: Do not use continually. Visit a medical professional if hearing is lost.<br>&emsp;There is a slight chance per use of complete deafness. Exercise caution and restraint.<br>STUN WARNING: If the intended or unintended target is too close to detonation the resulting sound<br>&emsp;and flash have been known to cause extreme sensory overload resulting in temporary<br>&emsp;incapacitation.<br><strong>DO NOT USE CONTINUALLY</strong><br>Operating Directions:<br>&emsp;1. Pull detonnation pin. <strong>ONCE THE PIN IS PULLED THE GRENADE CAN NOT BE DISARMED!</strong><br>&emsp;2. Throw grenade. <strong>NEVER HOLD A LIVE FLASHBANG</strong><br>&emsp;3. The grenade will detonste 10 seconds hafter being primed. <strong>EXCERCISE CAUTION</strong><br>&emsp;-<strong>Never prime another grenade until after the first is detonated</strong><br>Note: Usage of this pyrotechnic device without authorization is an extreme offense and can<br>result in severe punishment upwards of <strong>10 years in prison per use</strong>.<br><br>Default 3 second wait till from prime to detonation. This can be switched with a screwdriver<br>to 10 seconds.<br><br>Copyright of Nanotrasen Industries- Military Armnaments Division<br>This device was created by Nanotrasen Labs a member of the Expert Advisor Corporation"
	icon_state = "flashbang"
	spawn_contents = list(/obj/item/chem_grenade/flashbang = 7)

/obj/item/storage/box/emp_kit
	name = "\improper EMP grenade box"
	desc = "A box with 5 EMP grenades."
	icon_state = "flashbang"
	spawn_contents = list(/obj/item/old_grenade/emp = 5)

/obj/item/storage/box/tactical_kit // cogwerks - tactical as heck
	name = "tactical grenade box"
	desc = "A box of assorted special-ops grenades."
	icon_state = "flashbang"
	spawn_contents = list(/obj/item/chem_grenade/incendiary = 2,\
	/obj/item/chem_grenade/shock,\
	/obj/item/old_grenade/smoke = 2,\
	/obj/item/chem_grenade/flashbang,\
	/obj/item/old_grenade/gravaton)

/obj/item/storage/box/f_grenade_kit
	name = "cleaner grenade box"
	icon_state = "flashbang"
	spawn_contents = list(/obj/item/chem_grenade/fcleaner = 5)

/obj/item/storage/box/grenade_fuses
	name = "grenade fuse box"
	desc = "Contains fuses for constructing grenades."
	icon_state = "grenade_fuses"
	spawn_contents = list(/obj/item/grenade_fuse = 7)

/obj/item/storage/box/grenade_starter_kit
	name = "grenade starter kit"
	icon_state = "flashbang"
	desc = "Contains grenade cases and fuses for creating grenades."
	spawn_contents = list(/obj/item/grenade_fuse = 3,\
	/obj/item/chem_grenade = 3)

/obj/item/storage/box/sonic_grenade_kit
	name = "sonic grenade kit"
	icon_state = "flashbang"
	desc = "Contains five (5) sonic grenades, and a set of earplugs. Wear the earplugs before arming the grenades."
	spawn_contents = list(/obj/item/old_grenade/sonic = 5,\
	/obj/item/clothing/ears/earmuffs/earplugs)

/obj/item/storage/box/banana_grenade_kit
	name = "banana grenade box"
	icon_state = "flashbang"
	spawn_contents = list(/obj/item/old_grenade/banana = 5)

// For QM crate "Security Equipment" (Convair880).
/obj/item/storage/box/QM_grenadekit_security
	name = "security-issue grenade box"
	desc = "A box of standard-issue grenades for NT security personnel."
	icon_state = "flashbang"
	spawn_contents = list(/obj/item/chem_grenade/pepper = 2,\
	/obj/item/old_grenade/smoke = 2,\
	/obj/item/chem_grenade/flashbang = 2,\
	/obj/item/chem_grenade/shock)

// For QM crate "Experimental Weapons" (Convair880).
/obj/item/storage/box/QM_grenadekit_experimentalweapons
	name = "experimental grenade box"
	desc = "A box of experimental grenades."
	icon_state = "flashbang"
	spawn_contents = list(/obj/item/chem_grenade/very_incendiary,\
	/obj/item/chem_grenade/incendiary = 3,\
	/obj/item/chem_grenade/cryo = 3)

/* -------------------- Traitor Gear -------------------- */

/obj/item/storage/bowling
	name = "bowling bag"
	icon_state = "bowling_bag"
	item_state = "bowling"
	max_wclass = 3 // The bowling ball won't fit into the bowling bag!
	spawn_contents = list(/obj/item/clothing/under/gimmick/bowling,\
	/obj/item/bowling_ball = 4)

/obj/item/storage/box/syndibox
	name = "stealth storage"
	desc = "Can take on the appearance of another item. Creates a small dimensional rift in space-time, allowing it to hold multiple items."
	icon_state = "box"
	sneaky = 1
	var/cloaked = 0
	flags = FPRINT | TABLEPASS | NOSPLASH
	w_class = 2
	max_wclass = 3

	New()
		..()
		cloaked = 0

	UpdateName()
		name = "[name_prefix(null, 1)][real_name][name_suffix(null, 1)]"

	attackby(obj/item/W as obj, mob/user as mob)
		if (cloaked == 1)
			..()
		else
			if (!istype(W, /obj/item) || isnull(initial(W.icon)) || isnull(initial(W.icon_state)) || !W.icon || !W.icon_state)
				user.show_text("The [W.name] is not compatible with this device.", "red")
				return
			name = W.name
			real_name = W.name
			desc = "[W.desc] It looks heavy, somehow."
			real_desc = "[W.desc] It looks heavy, somehow."
			icon = W.icon
			icon_state = W.icon_state
			item_state = W.item_state
			inhand_image = W.inhand_image
			boutput(user, "<span style=\"color:blue\">The secret storage changes form to look like [W.name]!<br>Use the reset command to change it back.</span>")
			cloaked = 1
			return

	verb/reset()
		set src in usr

		if (cloaked)
			name = initial(name)
			real_name = initial(real_name)
			desc = initial(desc)
			real_desc = initial(real_desc)
			icon = initial(icon)
			icon_state = initial(icon_state)
			item_state = initial(item_state)
			inhand_image = initial(inhand_image)
			boutput(usr, "<span style=\"color:red\">You reset the [name].</span>")
			cloaked = 0
			add_fingerprint(usr)

/obj/item/storage/box/donkpocket_w_kit
	name = "\improper Donk-Pockets box"
	desc = "This box feels slightly warm."
	icon_state = "donk_kit"
	spawn_contents = list(/obj/item/reagent_containers/food/snacks/donkpocket_w = 7)

/obj/item/storage/box/donkpocket_w_kit/vr
	icon = 'icons/effects/VR.dmi'

/obj/item/storage/box/fakerevolver
	name = "\improper Russian surplus munitions box"
	icon_state = "fakerevolver"
	desc = "A box containing an old SSSSR-manufactured revolver."
	spawn_contents = list(/obj/item/gun/russianrevolver/fake357,\
	/obj/item/paper/fakerevolver)

/obj/item/paper/fakerevolver
	name = "Menacing note"
	desc = "There's a few lines of important-looking text here."

	New()
		..()
		var/gender = prob(50) ? 0 : 1
		var/name = gender ? pick(first_names_female) : pick(first_names_male)

		info = {"<TT>Hey, you.<BR>
		Look, we got this thing cheap from some Russkie. So let me write this down for you clearly:<BR><strong><font color=red size=4>IT. AIN'T. SAFE.</font></strong><BR>
		<BR>
		[name] tested this fucking gun and it blew [gender ? "her" : "his"] goddamn brains out. I dunno why we're even sending this shit to you.<BR>
		<strong>Don't use it. Fuck.</strong><BR>
		<BR>
		<em>/[prob(50)? pick(first_names_male):pick(first_names_female)]</em>
		"}

/obj/item/storage/box/costume/safari
	name = "safari costume"
	spawn_contents = list(/obj/item/clothing/head/safari,\
	/obj/item/clothing/under/gimmick/safari,\
	/obj/item/boomerang,\
	/obj/item/ammo/bullets/tranq_darts/syndicate = 4)

// Starter kit used in the conspiracy/spy game mode.
/obj/item/storage/box/spykit
	name = "spy starter kit"
	icon_state = "implant"
	spawn_contents = list(/obj/item/dagger/syndicate,\
	/obj/item/gun/kinetic/silenced_22,\
	/obj/item/ammo/bullets/bullet_22,\
	/obj/item/card/id/syndicate,\
	/obj/item/device/spy_implanter)