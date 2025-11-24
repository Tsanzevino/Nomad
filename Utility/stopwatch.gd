class_name Stopwatch extends Object

static var startTimes : Dictionary[String,int]

static var printMode : bool = true
## Starts a stopwatch with the name [param sw]
static func start(sw : String):
	startTimes[sw] = Time.get_ticks_msec()
	if printMode: print("%s started..." % sw)

## Stops the stopwatch with the name [param sw]
## Returns the time on the stopwatch and deletes the stopwatch
static func stop(sw : String) -> float:
	var time = (Time.get_ticks_msec() - startTimes[sw]) / 1000.0
	startTimes.erase(sw)
	if printMode: print_time(sw,time)
	return time

## Restarts the stopwatch with the name [param sw]
## Returns the time on the stopwatch and restarts the time
static func restart(sw : String) -> float:
	var time = (Time.get_ticks_msec() - startTimes[sw]) / 1000.0
	startTimes[sw] = Time.get_ticks_msec()
	if printMode: 
		print_time(sw,time)
		print("%s restarted..." % sw)
	return time

## Reads out the stopwatch with the name [param sw]
## Returns the time on the stopwatch without ending the stopwatch
static func lap(sw : String) -> float:
	var time = (Time.get_ticks_msec() - startTimes[sw]) / 1000.0
	if printMode: print_time(sw + " lap time",time)
	return time

static func print_time(sw : String, time : float):
	print("%s: %.3fs" % [sw, time])
