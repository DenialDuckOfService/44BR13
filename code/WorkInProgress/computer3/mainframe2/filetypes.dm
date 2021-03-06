

//Filetype used to store information on current user
/computer/file/user_data
	name = "user account"
	extension = "USR"
	size = 1

	//Store the data an ID card would.
	var/registered = null
	var/assignment = null
	var/list/access = list()
	//And some more
	var/net_id = null
	var/tmp/authlevel = 0
	var/tmp/computer/file/mainframe_program/active_program = null
	var/tmp/computer/folder/current_folder = null

	disposing()
		active_program = null
		current_folder = null
		access = null

		..()

/*
 *	User Account Datum
 */

/mainframe2_user_data
	var/computer/file/record/user_file = null
	var/computer/folder/user_file_folder = null
	var/user_filename = null
	var/user_name = "GENERIC"
	var/user_id = null
	var/full_user = 0
	var/computer/file/mainframe_program/current_prog = null

	disposing()
		current_prog = null
		user_file = null
		user_file_folder = null

		..()

	proc/reload_user_file()
		if (!user_file_folder || !user_filename)
			return FALSE

		for (var/computer/file/record/potential in user_file_folder.contents)
			if (potential.name == user_filename)
				user_file = potential
				return TRUE

		return FALSE

/computer/file/document
	name = "Document"
	extension = "DOC"
	var/list/textlist = list() //Actual document text
	var/list/metalist = list() //Instructions on how to process each line.

	disposing()
		textlist = null
		metalist = null

		..()
