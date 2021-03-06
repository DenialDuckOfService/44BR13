


/computer/file/terminal_program
	name = "blank program"
	extension = "TPROG"
	//var/size = 4.0
	//var/obj/item/disk/data/holder = null
	var/obj/machinery/computer3/master = null
	//var/active_icon = null
	var/list/req_access = list()
	//var/id_tag = null
	var/executable = 1

	os
		name = "blank system program"
		extension = "TSYS"
		executable = 0
		var/tmp/setup_string = null

		os_call(var/list/call_list, var/computer/file/terminal_program/caller, var/computer/file/file)
			return (!master || master.stat & (NOPOWER|BROKEN) || !caller || !call_list)

	termapp //Small applications for the "termos" computer3s.
		name = "blank terminal app"
		extension = "TAPP"
		executable = 0

	New(obj/holding as obj)
		..()
		if (holding)
			holder = holding

			if (istype(holder.loc,/obj/machinery/computer3))
				master = holder.loc

	/* new disposing() pattern should handle this. -singh
	Del()
		if (master)
			master.processing_programs.Remove(src)
		..()
	*/

	disposing()
		if (master)
			if (master.processing_programs)
				master.processing_programs.Remove(src)
			master = null

		req_access = null
		..()

	proc
		os_call(var/list/call_list, var/computer/file/file)
			if (!master || master.stat & (NOPOWER|BROKEN))
				return null

			if (master.host_program)
				return master.host_program.os_call(call_list, src, file)
			return null

		print_text(var/text)
			if ((!holder) || (!master) || !text)
				return TRUE

			if ((!istype(holder)) || (!istype(master)))
				return TRUE

			if (master.stat & (NOPOWER|BROKEN))
				return TRUE

			if (src != master.active_program)
				return TRUE

			if (!(holder in master.contents))
				//boutput(world, "Holder [holder] not in [master] of prg:[src]")
				if (master.active_program == src)
					master.active_program = null
				return TRUE

			if (!holder.root)
				holder.root = new /computer/folder
				src.holder.root.holder = src
				holder.root.name = "root"

			master.temp_add += "[text]<br>"
			master.updateUsrDialog()

			return FALSE

		input_text(var/text)
			if ((!holder) || (!master) || !text)
				return TRUE

			if ((!istype(holder)) || (!istype(master)))
				return TRUE

			if (master.stat & (NOPOWER|BROKEN))
				return TRUE

			if (!(holder in master.contents))
				//boutput(world, "Holder [holder] not in [master] of prg:[src]")
				if (master.active_program == src)
					master.active_program = null
				return TRUE

			if (!holder.root)
				holder.root = new /computer/folder
				src.holder.root.holder = src
				holder.root.name = "root"

			return FALSE

		initialize() //Called when a program starts running.
			return

		restart()
			return

		process()
			if ((!holder) || (!master))
				return TRUE

			if ((!istype(holder)) || (!istype(master)))
				return TRUE

			if (!(holder in master.contents))
				if (master.active_program == src)
					master.active_program = null
				master.processing_programs.Remove(src)
				return TRUE

			if (!holder.root)
				holder.root = new /computer/folder
				src.holder.root.holder = src
				holder.root.name = "root"

			return FALSE

		receive_command(obj/source, command, signal/signal)
			if ((!holder) || (!master) || (!source) || (source != master))
				return TRUE

			if ((!istype(holder)) || (!istype(master)))
				return TRUE

			if (master.stat & (NOPOWER|BROKEN))
				return TRUE

			if (!(holder in master.contents))
				if (master.active_program == src)
					master.active_program = null
				return TRUE

			return FALSE

		peripheral_command(command, signal/signal, target_ref)
			if (master)
				return master.send_command(command, signal, target_ref)
			//else
			//	qdel(signal)

			return null

		//Find a peripheral by func_tag
		find_peripheral(desired_tag)
			if (!master || !desired_tag) return

			var/found = null
			for (var/obj/item/peripheral/P in master.peripherals)
				if (P.func_tag == desired_tag)
					found = P

			return found

		transfer_holder(obj/item/disk/data/newholder,computer/folder/newfolder)

			if ((newholder.file_used + size) > newholder.file_amount)
				return FALSE

			if (!newholder.root)
				newholder.root = new /computer/folder
				newholder.root.holder = newholder
				newholder.root.name = "root"

			if (!newfolder)
				newfolder = newholder.root

			if ((src.holder && src.holder.read_only) || newholder.read_only)
				return FALSE

			if ((holder) && (holder.root))
				holder.root.remove_file(src)

			newfolder.add_file(src)

			if (istype(newholder.loc,/obj/machinery/computer3))
				master = newholder.loc

			//boutput(world, "Setting [holder] to [newholder]")
			holder = newholder
			return TRUE

		parse_string(string)
			var/list/sorted = command2list(string, " ")
			if (!sorted.len) sorted.len++
			return sorted

		//Command2list is a modified version of dd_text2list() designed to eat empty list entries generated by superfluous whitespace.
		//It was born in mainframe2.  Do not forget your history.
		command2list(text, separator)
			var/textlength = length(text)
			var/separatorlength = length(separator)
			var/list/textList = new()
			var/searchPosition = 1
			var/findPosition = 1
			while (1)
				findPosition = findtext(text, separator, searchPosition, 0)
				var/buggyText = copytext(text, searchPosition, findPosition)
				if (buggyText)
					textList += "[buggyText]"
				if (!findPosition)
					return textList
				searchPosition = findPosition + separatorlength
				if (searchPosition > textlength)
					return textList
			return

		parse_directory(string, var/computer/folder/origin)
			if (!string)
				return null

			//boutput(world, "[string]")
			var/computer/folder/current = origin

			if (!origin)
				origin = holding_folder

			if (dd_hasprefix(string , "/")) //if it starts with a /
				current = origin.holder.root //Begin the search at root.of current drive
				string = copytext(string,2)
				//boutput(world, "string is now: [string]")

			var/list/sort1 = splittext(string,"/")
			if (sort1.len && copytext(sort1[1], 4, 5) == ":")
				. = lowertext( copytext(sort1[1], 1, 4) )
				if (length(sort1[1]) > 4)
					sort1[1] = copytext(sort1[1], 5)
				else
					sort1.Cut(1,2)
				switch (.)
					if ("hd0")
						if (master.hd)
							current = master.hd.root
						else
							return null

					if ("fd0")
						if (master.diskette)
							current = master.diskette.root
						else
							return null

					else
						if (cmptext(copytext(., 1, 3), "sd"))
							. = text2num(copytext(., 3))
							if (!isnum(.))
								return null

							.++
							for (var/obj/item/disk/data/drive in master.contents)
								if (drive == master.hd || drive == master.diskette)
									continue

								if (--. < 1)
									current = drive.root
									break

							if (. > 0)
								return null

			while (current)

				if (!sort1.len)
					//boutput(world, "finished with [current.name]")
					return current

				var/new_current = 0
				for (var/computer/folder/F in current.contents)
					//boutput(world, "testing: [F.name] -- [sort1[1]] in folder [current]")
					if (ckey(F.name) == ckey(sort1[1]))
						//boutput(world, "matches: [F.name] -- [sort1[1]]")
						sort1 -= sort1[1]
						current = F
						new_current = 1
						break

				if (!new_current)
					//boutput(world, "no new current")
					return null

			return null

		//Find a file at the end of a given dirstring.
		parse_file_directory(string, var/computer/folder/origin)
			if (!string)
				return null

			//boutput(world, "[string]")
			var/computer/folder/current = origin

			if (!origin)
				origin = holding_folder

			if (dd_hasprefix(string , "/")) //if it starts with a /
				current = origin.holder.root //Begin the search at root.of current drive
				string = copytext(string,2)
				//boutput(world, "string is now: [string]")

			var/list/sort1 = splittext(string,"/")
			if (sort1.len && copytext(sort1[1], 4, 5) == ":")
				. = lowertext( copytext(sort1[1], 1, 4) )
				if (length(sort1[1]) > 4)
					sort1[1] = copytext(sort1[1], 5)
				else
					sort1.Cut(1,2)
				switch (.)
					if ("hd0")
						if (master.hd)
							current = master.hd.root
						else
							return null

					if ("fd0")
						if (master.diskette)
							current = master.diskette.root
						else
							return null

					else
						if (cmptext(copytext(., 1, 3), "sd"))
							. = text2num(copytext(., 3))
							if (!isnum(.))
								return null

							.++
							for (var/obj/item/disk/data/drive in master.contents)
								if (drive == master.hd || drive == master.diskette)
									continue

								if (--. < 1)
									current = drive.root
									break

							if (. > 0)
								return null

			var/file_name = sort1[sort1.len]
			if (!file_name)
				return null

			sort1 -= sort1[sort1.len]

			while (current)

				if (!sort1.len)
					var/computer/file/check = get_file_name(file_name, current)
					if (check && istype(check))
						return check
					else
						return null

				var/new_current = 0
				for (var/computer/folder/F in current.contents)
					//boutput(world, "testing: [F.name] -- [sort1[1]] in folder [current]")
					if (ckey(F.name) == ckey(sort1[1]))
						//boutput(world, "matches: [F.name] -- [sort1[1]]")
						sort1 -= sort1[1]
						current = F
						new_current = 1
						break

				if (!new_current)
					//boutput(world, "no new current")
					return null

			return null

		disk_ejected(var/obj/item/disk/data/thedisk) //So we can switch out of the floppy if it's ejected or whatever.
			if (!thedisk)
				return

			if (holder == thedisk)
				src.print_text("<font color=red>Fatal Error. Returning to system...</font>")
				master.unload_program(src)
				return

			return

		//Find a folder with a given name
		get_folder_name(string, var/computer/folder/check_folder)
			if (!string || (!check_folder || !istype(check_folder)))
				return null

			var/computer/taken = null
			for (var/computer/folder/F in check_folder.contents)
				if (ckey(string) == ckey(F.name))
					taken = F
					break

			return taken

		//Find a file with a given name
		get_file_name(string, var/computer/folder/check_folder)
			if (!string || (!check_folder || !istype(check_folder)))
				return null

			var/computer/taken = null
			for (var/computer/file/F in check_folder.contents)
				if (ckey(string) == ckey(F.name))
					taken = F
					break

			return taken

		//Just find any computer datum with this name, gosh
		get_computer_datum(string, var/computer/folder/check_folder)
			if (!string || (!check_folder || !istype(check_folder)))
				return null

			var/computer/taken = null
			for (var/computer/C in check_folder.contents)
				if (ckey(string) == ckey(C.name))
					taken = C
					break

			return taken

		is_name_invalid(string) //Check if a filename is invalid somehow
			if (!string)
				return TRUE

			if (ckey(string) != replacetext(lowertext(string), " ", null))
				return TRUE

			if (findtext(string, "/"))
				print_text("<strong>Error:</strong> Invalid character in name.")
				return TRUE


			return FALSE


		check_access(var/list/check_list)
			if (!req_access) //no requirements
				return TRUE
			if (!istype(req_access, /list)) //something's very wrong
				return TRUE

			var/list/L = req_access
			if (!L.len) //still no requirements
				return TRUE
			if (!check_list || !istype(check_list, /list)) //invalid or no access
				return FALSE
			for (var/req in req_access)
				if (!(req in check_list)) //doesn't have this access
					return FALSE
			return TRUE