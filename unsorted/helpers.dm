/proc/random_dir()
	return pick(list(NORTH, EAST, SOUTH, WEST, NORTH|EAST, NORTH|WEST, SOUTH|EAST, SOUTH|WEST))

/proc/generate_iff(var/length) //Generates a random IFF code made up of letters or numbers, to the specified length.
	var/iff
	for(var/i = 1; i <= length; i++)
		var/chance = rand(1,2)
		var/thing_to_add
		switch(chance)
			if(1)
				thing_to_add = pick(GLOB.full_alphabet)
			if(2)
				thing_to_add = rand(1,9)
		iff += "[thing_to_add]"
	return iff