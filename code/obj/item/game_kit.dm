/*
CONTAINS:
THAT STUPID GAME KIT

*/
/obj/item/game_kit
	name = "Gaming Kit"
	icon = 'icons/obj/items.dmi'
	icon_state = "game_kit"
	var/selected = null
	var/board_stat = null
	var/data = ""
	//var/base_url = "http://svn.slurm.us/public/spacestation13/misc/game_kit"
	item_state = "sheet-metal"
	w_class = 5.0
	desc = "Play chess or checkers. Or don't. Probably don't."
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 5

/obj/item/game_kit/New()
	board_stat = "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"
	selected = "CR"

/obj/item/game_kit/MouseDrop(mob/user as mob)
	if (user == usr && !usr.restrained() && !usr.stat && (usr.contents.Find(src) || in_range(src, usr)))
		if (usr.hand)
			if (!usr.l_hand)
				spawn (0)
					attack_hand(usr, 1, 1)
		else
			if (!usr.r_hand)
				spawn (0)
					attack_hand(usr, 0, 1)

/obj/item/game_kit/proc/update()
	var/dat = text("<CENTER><strong>Game Board</strong></CENTER><BR><a href='?src=\ref[];mode=hia'>[]</a> <a href='?src=\ref[];mode=remove'>remove</a><HR><table width= 256  border= 0  height= 256  cellspacing= 0  cellpadding= 0 >", src, (selected ? text("Selected: []", selected) : "Nothing Selected"), src)
	for (var/y = 1 to 8)
		dat += "<tr>"

		for (var/x = 1 to 8)
			var/tilecolor = (y + x) % 2 ? "#ffffff" : "#999999"
			var/piece = copytext(board_stat, ((y - 1) * 8 + x) * 2 - 1, ((y - 1) * 8 + x) * 2 + 1)

			dat += "<td>"
			dat += "<td style='background-color:[tilecolor]' width=32 height=32>"
			if (piece != "BB")
				dat += "<a href='?src=\ref[src];s_board=[x] [y]'><img src='[resource("images/chess/board_[piece].png")]' width=32 height=32 border=0>"
			else
				dat += "<a href='?src=\ref[src];s_board=[x] [y]'><img src='[resource("images/chess/board_none.png")]' width=32 height=32 border=0>"
			dat += "</td>"

		dat += "</tr>"

	dat += "</table><HR><strong>Chips:</strong><BR>"
	for (var/piece in list("CB", "CR"))
		dat += "<a href='?src=\ref[src];s_piece=[piece]'><img src='[resource("images/chess/board_[piece].png")]' width=32 height=32 border=0></a>"

	dat += "<HR><strong>Chess pieces:</strong><BR>"
	for (var/piece in list("WP", "WK", "WQ", "WI", "WN", "WR"))
		dat += "<a href='?src=\ref[src];s_piece=[piece]'><img src='[resource("images/chess/board_[piece].png")]' width=32 height=32 border=0></a>"
	dat += "<br>"
	for (var/piece in list("BP", "BK", "BQ", "BI", "BN", "BR"))
		dat += "<a href='?src=\ref[src];s_piece=[piece]'><img src='[resource("images/chess/board_[piece].png")]' width=32 height=32 border=0></a>"
	data = dat

/obj/item/game_kit/attack_hand(mob/user as mob, unused, flag)

	if (flag)
		return ..()
	else
		user.machine = src

		if (!( data ))
			update()
		user << browse(data, "window=game_kit;size=325x550")
		onclose(user, "game_kit")
		return
	return

/obj/item/game_kit/Topic(href, href_list)
	..()
	if ((usr.stat || usr.restrained()))
		return

	if (usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf)))
		if (href_list["s_piece"])
			selected = href_list["s_piece"]
		else if (href_list["mode"])
			if (href_list["mode"] == "remove")
				selected = "remove"
			else
				selected = null
		else if (href_list["s_board"])
			if (!( selected ))
				selected = href_list["s_board"]
			else
				var/tx = text2num(copytext(href_list["s_board"], 1, 2))
				var/ty = text2num(copytext(href_list["s_board"], 3, 4))
				if ((copytext(selected, 2, 3) == " " && length(selected) == 3))
					var/sx = text2num(copytext(selected, 1, 2))
					var/sy = text2num(copytext(selected, 3, 4))
					var/place = ((sy - 1) * 8 + sx) * 2 - 1
					selected = copytext(board_stat, place, place + 2)
					if (place == 1)
						board_stat = text("BB[]", copytext(board_stat, 3, 129))
					else
						if (place == 127)
							board_stat = text("[]BB", copytext(board_stat, 1, 127))
						else
							if (place)
								board_stat = text("[]BB[]", copytext(board_stat, 1, place), copytext(board_stat, place + 2, 129))
					place = ((ty - 1) * 8 + tx) * 2 - 1
					if (place == 1)
						board_stat = text("[][]", selected, copytext(board_stat, 3, 129))
					else
						if (place == 127)
							board_stat = text("[][]", copytext(board_stat, 1, 127), selected)
						else
							if (place)
								board_stat = text("[][][]", copytext(board_stat, 1, place), selected, copytext(board_stat, place + 2, 129))
					selected = null
				else
					if (selected == "remove")
						var/place = ((ty - 1) * 8 + tx) * 2 - 1
						if (place == 1)
							board_stat = text("BB[]", copytext(board_stat, 3, 129))
						else
							if (place == 127)
								board_stat = text("[]BB", copytext(board_stat, 1, 127))
							else
								if (place)
									board_stat = text("[]BB[]", copytext(board_stat, 1, place), copytext(board_stat, place + 2, 129))
					else
						if (length(selected) == 2)
							var/place = ((ty - 1) * 8 + tx) * 2 - 1
							if (place == 1)
								board_stat = text("[][]", selected, copytext(board_stat, 3, 129))
							else
								if (place == 127)
									board_stat = text("[][]", copytext(board_stat, 1, 127), selected)
								else
									if (place)
										board_stat = text("[][][]", copytext(board_stat, 1, place), selected, copytext(board_stat, place + 2, 129))
		add_fingerprint(usr)
		update()
		for (var/mob/M in viewers(1, src))
			if ((M.client && M.machine == src))
				attack_hand(M)
