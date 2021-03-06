var/list/wire_colors = list( // http://www.crockford.com/wrrrld/color.html
	"aliceblue",
	"antiquewhite",
	"aqua",
	"aquamarine",
	"beige",
	"blanchedalmond",
	"blue",
	"blueviolet",
	"brown",
	"burlywood",
	"cadetblue",
	"chartreuse",
	"chocolate",
	"coral",
	"cornflowerblue",
	"cornsilk",
	"crimson",
	"cyan",
	"deeppink",
	"deepskyblue",
	"dimgray",
	"dodgerblue",
	"firebrick",
	"floralwhite",
	"forestgreen",
	"fuchsia",
	"gainsboro",
	"ghostwhite",
	"gold",
	"goldenrod",
	"gray",
	"green",
	"greenyellow",
	"honeydew",
	"hotpink",
	"indianred",
	"ivory",
	"khaki",
	"lavender",
	"lavenderblush",
	"lawngreen",
	"lemonchiffon",
	"lightblue",
	"lightcoral",
	"lightcyan",
	"lightgoldenrodyellow",
	"lightgray",
	"lightgreen",
	"lightpink",
	"lightsalmon",
	"lightseagreen",
	"lightskyblue",
	"lightslategray",
	"lightsteelblue",
	"lightyellow",
	"lime",
	"limegreen",
	"linen",
	"magenta",
	"maroon",
	"mediumaquamarine",
	"mediumblue",
	"mediumorchid",
	"mediumpurple",
	"mediumseagreen",
	"mediumslateblue",
	"mediumspringgreen",
	"mediumturquoise",
	"mediumvioletred",
	"mintcream",
	"mistyrose",
	"moccasin",
	"navajowhite",
	"oldlace",
	"olive",
	"olivedrab",
	"orange",
	"orangered",
	"orchid",
	"palegoldenrod",
	"palegreen",
	"paleturquoise",
	"palevioletred",
	"papayawhip",
	"peachpuff",
	"peru",
	"pink",
	"plum",
	"powderblue",
	"purple",
	"red",
	"rosybrown",
	"royalblue",
	"saddlebrown",
	"salmon",
	"sandybrown",
	"seagreen",
	"seashell",
	"sienna",
	"silver",
	"skyblue",
	"slateblue",
	"slategray",
	"snow",
	"springgreen",
	"steelblue",
	"tan",
	"teal",
	"thistle",
	"tomato",
	"turquoise",
	"violet",
	"wheat",
	"white",
	"whitesmoke",
	"yellow",
	"yellowgreen",
)
var/list/wire_color_directory = list()

/proc/is_wire_tool(obj/item/I)
	if(istype(I, /obj/item/device/multitool))
		return TRUE
	if(istype(I, /obj/item/weapon/wirecutters))
		return TRUE
	if(istype(I, /obj/item/device/assembly))
		var/obj/item/device/assembly/A = I
		if(A.attachable)
			return TRUE
	return

/atom
	var/datum/wires/wires = null

/datum/wires
	var/atom/holder = null // The holder (atom that contains these wires).
	var/holder_type = null // The holder's typepath (used to make wire colors common to all holders).

	var/list/wires = list() // List of wires.
	var/list/cut_wires = list() // List of wires that have been cut.
	var/list/colors = list() // Dictionary of colors to wire.
	var/list/assemblies = list() // List of attached assemblies.
	var/randomize = 0 // If every instance of these wires should be random.

/datum/wires/New(atom/holder)
	..()
	if(!istype(holder, holder_type))
		CRASH("Wire holder is not of the expected type!")
		return

	src.holder = holder
	if(randomize)
		randomize()
	else
		if(!wire_color_directory[holder_type])
			randomize()
			wire_color_directory[holder_type] = colors
		else
			colors = wire_color_directory[holder_type]

/datum/wires/Destroy()
	holder = null
	assemblies = list()
	return ..()

/datum/wires/proc/add_duds(duds)
	while(duds)
		var/dud = "dud[--duds]"
		if(dud in wires)
			continue
		wires += dud

/datum/wires/proc/randomize()
	var/list/possible_colors = shuffle(wire_colors.Copy())

	for(var/wire in shuffle(wires))
		colors[pick_n_take(possible_colors)] = wire

/datum/wires/proc/shuffle_wires()
	colors.Cut()
	randomize()

/datum/wires/proc/repair()
	cut_wires.Cut()

/datum/wires/proc/get_wire(color)
	return colors[color]

/datum/wires/proc/get_attached(color)
	if(assemblies[color])
		return assemblies[color]
	return null

/datum/wires/proc/is_attached(color)
	if(assemblies[color])
		return TRUE

/datum/wires/proc/is_cut(wire)
	return (wire in cut_wires)

/datum/wires/proc/is_color_cut(color)
	return is_cut(get_wire(color))

/datum/wires/proc/is_all_cut()
	if(cut_wires.len == wires.len)
		return TRUE

/datum/wires/proc/cut(wire)
	if(is_cut(wire))
		cut_wires -= wire
		on_cut(wire, mend = TRUE)
	else
		cut_wires += wire
		on_cut(wire, mend = FALSE)

/datum/wires/proc/cut_color(color)
	cut(get_wire(color))

/datum/wires/proc/cut_random()
	cut(wires[rand(1, wires.len)])

/datum/wires/proc/cut_all()
	for(var/wire in wires)
		cut(wire)

/datum/wires/proc/pulse(wire)
	if(is_cut(wire))
		return
	on_pulse(wire)

/datum/wires/proc/pulse_color(color)
	pulse(get_wire(color))

/datum/wires/proc/pulse_assembly(obj/item/device/assembly/S)
	for(var/color in assemblies)
		if(S == assemblies[color])
			pulse_color(color)
			return TRUE

/datum/wires/proc/attach_assembly(color, obj/item/device/assembly/S)
	if(S && istype(S) && S.attachable && !is_attached(color))
		assemblies[color] = S
		S.loc = holder
		S.connected = src
		return S

/datum/wires/proc/detach_assembly(color)
	var/obj/item/device/assembly/S = get_attached(color)
	if(S && istype(S))
		assemblies -= color
		S.connected = null
		S.loc = holder.loc
		return S

// Overridable Procs
/datum/wires/proc/interactable(mob/user)
	return TRUE

/datum/wires/proc/get_status()
	return list()

/datum/wires/proc/on_cut(wire, mend = FALSE)
	return

/datum/wires/proc/on_pulse(wire)
	return
// End Overridable Procs

/datum/wires/proc/interact(mob/user)
	if(!interactable(user))
		return
	ui_interact(user)
	for(var/A in assemblies)
		var/obj/item/I = assemblies[A]
		if(istype(I) && I.on_found(user))
			return

/datum/wires/ui_host()
	return holder

/datum/wires/ui_status(mob/user)
	if(interactable(user))
		return ..()
	return UI_CLOSE

/datum/wires/ui_interact(mob/user, ui_key = "wires", datum/tgui/ui = null, force_open = 0, \
							datum/tgui/master_ui = null, datum/ui_state/state = physical_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "wires", "[holder.name] wires", 350, 150 + wires.len * 30, master_ui, state)
		ui.open()

/datum/wires/get_ui_data(mob/user)
	var/list/data = list()
	var/list/payload = list()
	for(var/color in colors)
		payload.Add(list(list(
			"color" = color,
			"wire" = (IsAdminGhost(user) ? get_wire(color) : null),
			"cut" = is_color_cut(color),
			"attached" = is_attached(color)
		)))
	data["wires"] = payload
	data["status"] = get_status()
	return data

/datum/wires/ui_act(action, params)
	if(..() || !interactable(usr))
		return
	var/target_wire = params["wire"]
	var/mob/living/L = usr
	var/obj/item/I = L.get_active_hand()
	switch(action)
		if("cut")
			if(istype(I, /obj/item/weapon/wirecutters) || IsAdminGhost(usr))
				playsound(holder, 'sound/items/Wirecutter.ogg', 20, 1)
				cut_color(target_wire)
				. = TRUE
			else
				L << "<span class='warning'>You need wirecutters!</span>"
		if("pulse")
			if(istype(I, /obj/item/device/multitool) || IsAdminGhost(usr))
				playsound(holder, 'sound/weapons/empty.ogg', 20, 1)
				pulse_color(target_wire)
				. = TRUE
			else
				L << "<span class='warning'>You need a multitool!</span>"
		if("attach")
			if(is_attached(target_wire))
				var/obj/item/O = detach_assembly(target_wire)
				if(O)
					L.put_in_hands(O)
					. = TRUE
			else
				if(istype(I, /obj/item/device/assembly))
					var/obj/item/device/assembly/A = I
					if(A.attachable)
						if(!L.drop_item())
							return
						attach_assembly(target_wire, A)
						. = TRUE
					else
						L << "<span class='warning'>You need an attachable assembly!</span>"
