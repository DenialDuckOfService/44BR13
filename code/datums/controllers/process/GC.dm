/controller/process/garbage_collector
	var/tmp/delcount = 0
	var/tmp/gccount = 0
	var/tmp/deleteChunkSize = MIN_DELETE_CHUNK_SIZE	
	//var/tmp/delpause = 1
	#ifdef DELETE_QUEUE_DEBUG
	var/tmp/dynamicQueue/delete_queue = 0
	#endif

	// Timing vars
	var/tmp/start = 0
	var/tmp/list/timeTaken = new

	setup()
		name = "Garbage Collector"
		schedule_interval = 5
		tick_allowance = 25

	doWork()
		if (!global.delete_queue)
			boutput(world, "Error: there is no delete queue!")
			return FALSE

		#ifdef DELETE_QUEUE_DEBUG
		if (!delete_queue)
			delete_queue = global.delete_queue
		#endif

		//var/dynamicQueue/queue =
		if (global.delete_queue.isEmpty())
			return

		start = world.timeofday

		var/list/toDeleteRef = delete_queue.dequeueMany(deleteChunkSize)
		var/numItems = toDeleteRef.len
		#ifdef DELETE_QUEUE_DEBUG
		var/t
		#endif
		for (var/ref in toDeleteRef)
			var/datum/D = locate(ref)

			if (!istype(D) || !D.qdeled)
				// If we can't locate it, it got garbage collected.
				// If it isn't disposed, it got garbage collected and then a new thing used its ref.
				gccount++
				continue

			#ifdef DELETE_QUEUE_DEBUG
			t = D.type
			// If we have been forced to delete the object, we do the following:
			detailed_delete_count[t]++
			detailed_delete_gc_count[t]--
			// Because we have already logged it into the gc count in qdel.
			#endif

			// Delete that bitch
			delcount++
			D.qdeled = 0
			del(D)

			scheck()

			//if (delpause)
				//sleep(delpause)

		// The amount of time taken for this run is recorded only if
		// the number of items considered is equal to the chunk size
		if (numItems == deleteChunkSize)
			timeTaken.len++
			timeTaken[timeTaken.len] = world.timeofday - start

		// If the number of items processed is equal to the chunk size
		// and the average time taken by the delete queue is greater than the scheduled interval
		if (numItems == deleteChunkSize && averageTimeTaken() > schedule_interval && deleteChunkSize > MIN_DELETE_CHUNK_SIZE)
			deleteChunkSize-=10
		else if (numItems == deleteChunkSize && averageTimeTaken() < schedule_interval)
			deleteChunkSize+=10

	proc
		averageTimeTaken()
			var/t = 0
			var/c = 0
			for (var/time in timeTaken)
				t += time
				c++

			if (timeTaken.len > 10)
				timeTaken.Cut(1, 2)

			if (c > 0)
				return t / c
			return c

	tickDetail()
		#ifdef DELETE_QUEUE_DEBUG
		if (detailed_delete_count && detailed_delete_count.len)
			var/stats = "<strong>Delete Stats:</strong><br>"
			var/count
			for (var/thing in detailed_delete_count)
				count = detailed_delete_count[thing]
				stats += "[thing] deleted [count] times.<br>"
			for (var/thing in detailed_delete_gc_count)
				count = detailed_delete_gc_count[thing]
				stats += "[thing] gracefully deleted [count] times.<br>"
			boutput(usr, "<br>[stats]")
		#endif
		boutput(usr, "<strong>Current Queue Length:</strong> [delete_queue.count()]")
		boutput(usr, "<strong>Total Items Deleted:</strong> [delcount] (Explictly) [gccount] (Gracefully GC'd)")