//CONTENTS:
//Generic records
//Security records
//Medical records

/computer/file/pda_program/records
	var/mode = 0
	var/data/record/active1 = null //General
	var/data/record/active2 = null //Security/Medical/Whatever

//To-do: editing arrest status/etc from pda.
/computer/file/pda_program/records/security
	name = "Security Records"
	size = 8

	return_text()
		if (..())
			return

		var/dat = return_text_header()

		switch(mode)
			if (0)
				dat += "<h4>Security Record List</h4>"

				for (var/data/record/R in data_core.general)
					dat += "<a href='byond://?src=\ref[src];select_rec=\ref[R]'>[R.fields["id"]]: [R.fields["name"]]<br>"

				dat += "<br>"

			if (1)

				dat += "<h4>Security Record</h4>"

				dat += "<a href='byond://?src=\ref[src];mode=0'>Back</a><br>"

				if (istype(active1, /data/record) && data_core.general.Find(active1))
					dat += "Name: [active1.fields["name"]] ID: [active1.fields["id"]]<br>"
					dat += "Sex: [active1.fields["sex"]]<br>"
					dat += "Age: [active1.fields["age"]]<br>"
					dat += "Fingerprint: [active1.fields["fingerprint"]]<br>"
					dat += "DNA: [active1.fields["dna"]]<br>"
					dat += "Physical Status: [active1.fields["p_stat"]]<br>"
					dat += "Mental Status: [active1.fields["m_stat"]]<br>"
				else
					dat += "<strong>Record Lost!</strong><br>"

				dat += "<br>"

				dat += "<h4>Security Data</h4>"
				if (istype(active2, /data/record) && data_core.security.Find(active2))
					dat += "Criminal Status: [active2.fields["criminal"]]<br>"

					dat += "Minor Crimes: [active2.fields["mi_crim"]]<br>"
					dat += "Details: [active2.fields["mi_crim"]]<br><br>"

					dat += "Major Crimes: [active2.fields["ma_crim"]]<br>"
					dat += "Details: [active2.fields["ma_crim_d"]]<br><br>"

					dat += "Important Notes:<br>"
					dat += "[active2.fields["notes"]]"
				else
					dat += "<strong>Record Lost!</strong><br>"

				dat += "<br>"

		return dat

	Topic(href, href_list)
		if (..())
			return

		if (href_list["mode"])
			var/newmode = text2num(href_list["mode"])
			mode = max(newmode, 0)

		else if (href_list["select_rec"])
			var/data/record/R = locate(href_list["select_rec"])
			var/data/record/S = locate(href_list["select_rec"])

			if (data_core.general.Find(R))
				for (var/data/record/E in data_core.security)
					if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
						S = E
						break

				active1 = R
				active2 = S

				mode = 1

		master.add_fingerprint(usr)
		master.updateSelfDialog()
		return

/computer/file/pda_program/records/medical
	name = "Medical Records"
	size = 8

	return_text()
		if (..())
			return

		var/dat = return_text_header()

		switch(mode)
			if (0)

				dat += "<h4>Medical Record List</h4>"
				for (var/data/record/R in data_core.general)
					dat += "<a href='byond://?src=\ref[src];select_rec=\ref[R]'>[R.fields["id"]]: [R.fields["name"]]<br>"
				dat += "<br>"

			if (1)

				dat += "<h4>Medical Record</h4>"

				dat += "<a href='byond://?src=\ref[src];mode=0'>Back</a><br>"

				if (istype(active1, /data/record) && data_core.general.Find(active1))
					dat += "Name: [active1.fields["name"]] ID: [active1.fields["id"]]<br>"
					dat += "Sex: [active1.fields["sex"]]<br>"
					dat += "Age: [active1.fields["age"]]<br>"
					dat += "Fingerprint: [active1.fields["fingerprint"]]<br>"
					dat += "DNA: [active1.fields["dna"]]<br>"
					dat += "Physical Status: [active1.fields["p_stat"]]<br>"
					dat += "Mental Status: [active1.fields["m_stat"]]<br>"
				else
					dat += "<strong>Record Lost!</strong><br>"

				dat += "<br>"

				dat += "<h4>Medical Data</h4>"
				if (istype(active2, /data/record) && data_core.medical.Find(active2))
					dat += "Current Health: [active2.fields["h_imp"]]<br><br>"

					dat += "Blood Type: [active2.fields["bioHolder.bloodType"]]<br><br>"

					dat += "Minor Disabilities: [active2.fields["mi_dis"]]<br>"
					dat += "Details: [active2.fields["mi_dis_d"]]<br><br>"

					dat += "Major Disabilities: [active2.fields["ma_dis"]]<br>"
					dat += "Details: [active2.fields["ma_dis_d"]]<br><br>"

					dat += "Allergies: [active2.fields["alg"]]<br>"
					dat += "Details: [active2.fields["alg_d"]]<br><br>"

					dat += "Current Diseases: [active2.fields["cdi"]]<br>"
					dat += "Details: [active2.fields["cdi_d"]]<br><br>"

					dat += "Traits: [active2.fields["traits"]]<br><br>"

					dat += "Important Notes: [active2.fields["notes"]]<br>"
				else
					dat += "<strong>Record Lost!</strong><br>"

				dat += "<br>"

		return dat

	Topic(href, href_list)
		if (..())
			return

		if (href_list["mode"])
			var/newmode = text2num(href_list["mode"])
			mode = max(newmode, 0)

		else if (href_list["select_rec"])
			var/data/record/R = locate(href_list["select_rec"])
			var/data/record/M = locate(href_list["select_rec"])

			if (data_core.general.Find(R))
				for (var/data/record/E in data_core.medical)
					if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
						M = E
						break

				active1 = R
				active2 = M

				mode = 1

		master.add_fingerprint(usr)
		master.updateSelfDialog()
		return