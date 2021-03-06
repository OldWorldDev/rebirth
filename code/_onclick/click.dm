// 1 decisecond click delay (above and beyond mob/next_move)
/client/var/next_click = 0
/mob/var/next_move = null

/*
	Before anything else, defer these calls to a per-mobtype handler.  This allows us to
	remove istype() spaghetti code, but requires the addition of other handler procs to simplify it.

	Alternately, you could hardcode every mob's variation in a flat ClickOn() proc; however,
	that's a lot of code duplication and is hard to maintain.

	Note that this proc can be overridden, and is in the case of screen objects.
*/

/client/proc/updateClickDelay()
	if(next_click >= world.time)
		return FALSE
	next_click = world.time + 1
	return TRUE


/client/Click(atom/target, location, control, params)
	//check'n'update delay
	if(!updateClickDelay())
		return

	//handle client level actoins (buildmode)
	//Nothing right now

	//default behavior
	if(target.Click(location, control, params))
		mob.ClickOn(target, params)

/atom/Click(location, control, params)
	return TRUE


/client/DblClick(atom/target, location, control, params)
	//check'n'update delay
	if(!updateClickDelay())
		return

	//handle client level actoins (buildmode)
	//Nothing right now

	//default behavior
	if(!target.DblClick(location, control, params))
		mob.DblClickOn(target, params)

/atom/DblClick(location, control, params)
	return FALSE


//Default behavior:
// ignore double clicks, the second click that makes the doubleclick call already calls for a normal click
/mob/proc/DblClickOn(var/atom/target, var/params)
	return

/*
	Standard mob ClickOn()
	Handles exceptions: middle click, modified clicks, mech actions

	After that, mostly just check your state, check whether you're holding an item,
	check whether you're adjacent to the target, then pass off the click to whoever
	is recieving it.
	The most common are:
	* mob/UnarmedAttack(atom,adjacent) - used here only when adjacent, with no item in hand; in the case of humans, checks gloves
	* atom/attackby(item,user) - used only when adjacent
	* item/afterattack(atom,user,adjacent,params) - used both ranged and adjacent
	* mob/RangedAttack(atom,params) - used only ranged, only used for tk and laser eyes but could be changed
*/
/mob/proc/ClickOn(var/atom/target, var/params)
	if(!canClick()) // in the year 2000...
		return TRUE

	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(target)
		return TRUE
	if(modifiers["middle"])
		MiddleClickOn(target)
		return TRUE
	if(modifiers["shift"])
		ShiftClickOn(target)
		return TRUE
	if(modifiers["alt"]) // alt and alt-gr (rightalt)
		AltClickOn(target)
		return TRUE
	if(modifiers["ctrl"])
		CtrlClickOn(target)
		return TRUE

	mobClickOn(target, modifiers)

/mob/proc/setClickCooldown(var/timeout)
	next_move = max(world.time + timeout, next_move)

/mob/proc/canClick()
	return (next_move <= world.time)


/*
	Default mob type depended behavior
*/
/mob/proc/mobClickOn(atom/target)

/*
	Middle click
	Only used for swapping hands
*/
/mob/proc/MiddleClickOn(atom/target)

/*
	Shift click
	For most mobs, examine.
	This is overridden in ai.dm
*/
/mob/proc/ShiftClickOn(var/atom/target)
	target.ShiftClick(src)

/atom/proc/ShiftClick(mob/user)
/*
	if(src in view(user))
		user.examinate(src)
*/

/*
	Alt click
	Unused except for AI
*/
/mob/proc/AltClickOn(atom/target)
	target.AltClick(src)

/atom/proc/AltClick(mob/user)

/*
	Ctrl click
	For most objects, pull
*/
/mob/proc/CtrlClickOn(atom/target)
	target.CtrlClick(src)

/atom/proc/CtrlClick(mob/user)

/*
	Control+Shift click
	Unused except for AI
*/
/mob/proc/CtrlShiftClickOn(atom/target)
	target.CtrlShiftClick(src)

/atom/proc/CtrlShiftClick(mob/user)
