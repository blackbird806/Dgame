module utility;

import gfm.math;

alias Color = Vector!(ubyte, 4);

void rotate(ref vec2f vec, float angle)
{
	import std.math; 
	const auto _sin = sin(angle);
	const auto _cos = cos(angle);
	vec.x = vec.x * _cos - vec.y * _sin;
	vec.y = vec.x * _sin + vec.y * _cos;
}