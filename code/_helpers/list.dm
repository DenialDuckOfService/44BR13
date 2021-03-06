/proc/range_types(var/dist, var/atom/center, var/type = /atom)
	. = list()
	for (var/atom in range(dist, center))
		if (istype(atom, type))
			. += atom
			
/proc/orange_types(var/dist, var/atom/center, var/type = /atom)
	. = list()
	for (var/atom in orange(dist, center))
		if (istype(atom, type))
			. += atom
			
/proc/find_dense_type(list, type)
	if (!ispath(type, /atom))
		return FALSE
	for (var/atom in list)
		if (atom && istype(atom, type))
			var/atom/A = atom 
			if (A.density)
				return A
	return FALSE

/proc/reverse_list(var/list/the_list)
	var/list/reverse = list()
	for (var/i = the_list.len, i > 0, i--)
		reverse.Add(the_list[i])
	return reverse

/proc/next_in_list(var/thing, var/list)
	if (thing == list[length(list)])
		return list[1]
	for (var/v in 1 to length(list))
		if (v > 1 && list[v-1] == thing)
			return list[v]
	return list[1]
