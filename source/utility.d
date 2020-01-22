module utility;

import gfm.math.vector;
import std.traits, std.math, std.stdio;

alias Color = Vector!(ubyte, 4);

struct Line
{
	vec2f p1, p2;
	float thickness;
}

vec2f rotate(vec2f vec, float angle)
{
	import std.math; 
	const auto _sin = sin(angle);
	const auto _cos = cos(angle);
	vec2f r;
	r.x = vec.x * _cos - vec.y * _sin;
	r.y = vec.x * _sin + vec.y * _cos;
	return r;
}

auto roundTo(TO, T)(T val)
	if (isNumeric!T && isNumeric!TO)
{
	return cast(TO)(round(val));
}

