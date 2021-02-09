﻿/var/global/world/world = null

proc/abs(A)
proc/animate(Object, time, loop, easing, flags)
proc/arccos(X)
proc/arctan(A)
proc/ascii2text(N)
proc/ckey(Key)
proc/cmptext(T1)
proc/copytext(T, Start = 1, End = 0)
proc/cos(X)
proc/CRASH(msg)
proc/fcopy(Src, Dst)
proc/fcopy_rsc(File)
proc/fdel(File)
proc/fexists(File)
proc/file(Path)
proc/file2text(File)
proc/findtext(Haystack, Needle, Start = 1, End = 0)
proc/findtextEx(Haystack, Needle, Start = 1, End = 0)
proc/findlasttext(Haystack, Needle, Start = 1, End = 0)
proc/get_dist(Loc1, Loc2)
proc/html_decode(HtmlText)
proc/html_encode(PlainText)
proc/image(icon, loc, icon_state, layer, dir)
proc/isarea(Loc1)
proc/isloc(Loc1)
proc/ismob(Loc1)
proc/isnull(Val)
proc/isnum(Val)
proc/ispath(Val, Type)
proc/istext(Val)
proc/isturf(Loc1)
proc/istype(Val, Type)
proc/json_decode(JSON)
proc/json_encode(Value)
proc/length(E)
proc/locate(X, Y, Z)
proc/log(X, Y)
proc/lowertext(T)
proc/max(A)
proc/min(A)
proc/num2text(N, Digits, Radix)
proc/orange(Dist = 5, Center = usr)
proc/range(Dist, Center = usr)
proc/oview(Dist = 5, Center = usr)
proc/params2list(Params)
proc/pick(Val1)
proc/prob(P)
proc/rand(L, H)
proc/replacetext(Haystack, Needle, Replacement, Start = 1, End = 0)
proc/replacetextEx(Haystack, Needle, Replacement, Start = 1, End = 0)
proc/rgb(R, G, B, A)
proc/round(A, B)
proc/sin(X)
proc/sleep(Delay)
proc/sorttext(T1, T2)
proc/sorttextEx(T1, T2)
proc/sound(file, repeat = 0, wait, channel, volume)
proc/splittext(Text, Delimiter)
proc/sqrt(A)
proc/text(FormatText)
proc/text2ascii(T, pos = 1)
proc/text2file(Text, File)
proc/text2num(T, radix = 10)
proc/text2path(T)
proc/time2text(timestamp, format)
proc/typesof(Item1)
proc/uppertext(T)
proc/url_encode(PlainText, format = 0)
proc/view(Dist = 4, Center = usr)
proc/viewers(Depth, Center = usr)
proc/walk(Ref, Dir, Lag = 0, Speed = 0)
proc/walk_to(Ref, Trg, Min = 0, Lag = 0, Speed = 0)

#include "Defines.dm"
#include "Types\Client.dm"
#include "Types\Datum.dm"
#include "Types\Image.dm"
#include "Types\List.dm"
#include "Types\Matrix.dm"
#include "Types\Mutable_Appearance.dm"
#include "Types\Sound.dm"
#include "Types\World.dm"
#include "Types\Atoms\_Atom.dm"
#include "Types\Atoms\Area.dm"
#include "Types\Atoms\Mob.dm"
#include "Types\Atoms\Movable.dm"
#include "Types\Atoms\Obj.dm"
#include "Types\Atoms\Turf.dm"

proc/block(var/atom/Start, var/atom/End)
	var/list/atoms = list()
	
	var/startX = min(Start.x, End.x)
	var/startY = min(Start.y, End.y)
	var/endX = max(Start.x, End.x)
	var/endY = max(Start.y, End.y)
	for (var/y=startY; y<=endY; y++)
		for (var/x=startX; x<=endX; x++)
			atoms.Add(locate(x, y, Start.z))
	
	return atoms

proc/get_step(atom/Ref, Dir)
	if (Ref == null) return null
	
	var/x = Ref.x
	var/y = Ref.y

	if (Dir & NORTH) y += 1
	else if (Dir & SOUTH) y -= 1

	if (Dir & EAST) x += 1
	else if (Dir & WEST) x -= 1

	return locate(max(x, 1), max(y, 1), Ref.z)

proc/get_dir(atom/Loc1, atom/Loc2)
	if (Loc1 == null || Loc2 == null) return 0

	var/loc1X = Loc1.x
	var/loc2X = Loc2.x
	var/loc1Y = Loc1.y
	var/loc2Y = Loc2.y

	if (loc2X < loc1X)
		if (loc2Y == loc1Y) return WEST
		else if (loc2Y > loc1Y) return NORTHWEST
		else return SOUTHWEST
	else if (loc2X > loc1X)
		if (loc2Y == loc1Y) return EAST
		else if (loc2Y > loc1Y) return NORTHEAST
		else return SOUTHEAST
	else if (loc2Y > loc1Y) return NORTH
	else return SOUTH

/proc/step(atom/movable/Ref, var/Dir, var/Speed=0)
	Ref.Move(get_step(Ref, Dir), Dir)

/proc/turn(Dir, Angle)
	var/dirAngle = 0

	if (Dir == NORTH) dirAngle = 0
	else if (Dir == NORTHEAST) dirAngle = 45
	else if (Dir == EAST) dirAngle = 90
	else if (Dir == SOUTHEAST) dirAngle = 135
	else if (Dir == SOUTH) dirAngle = 180
	else if (Dir == SOUTHWEST) dirAngle = 225
	else if (Dir == WEST) dirAngle = 270
	else if (Dir == NORTHWEST) dirAngle = 315
	else if (Angle != 0) return pick(NORTH, SOUTH, EAST, WEST)

	dirAngle += round(Angle, 45)
	if (dirAngle > 360) dirAngle -= 360
	else if (dirAngle < 0) dirAngle += 360

	if (dirAngle == 0 || dirAngle == 360) return NORTH
	else if (dirAngle == 45) return NORTHEAST
	else if (dirAngle == 90) return EAST
	else if (dirAngle == 135) return SOUTHEAST
	else if (dirAngle == 180) return SOUTH
	else if (dirAngle == 225) return SOUTHWEST
	else if (dirAngle == 270) return WEST
	else if (dirAngle == 315) return NORTHWEST

proc/get_step_towards(atom/movable/Ref, /atom/Trg)
	var/dir = get_dir(Ref, Trg)

	return get_step(Ref, dir)

proc/get_step_away(atom/movable/Ref, /atom/Trg, Max = 5)
	if (get_dist(Ref, Trg) > Max) return 0

	return turn(get_step_towards(Ref, Trg), 180)

proc/step_towards(atom/movable/Ref, /atom/Trg, Speed)
	Ref.Move(get_step_towards(Ref, Trg), dir)