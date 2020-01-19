module utility;

import gfm.math.vector;
import std.traits, std.math, std.stdio;

alias Color = Vector!(ubyte, 4);

struct Line
{
	vec2f p1, p2;
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

auto deserialize(T)(string filePath, T t)
{
	import serialization, dyaml;
	Loader.fromFile(filePath).load()[t.name].deserializeInto(t);
	return t;
}

void serialize(T)(string filePath, T t)
{
	import serialization, dyaml;

	Node r;
	r.add(t.name, t.toYAMLNode());
	auto d = File(filePath, "w").lockingTextWriter;
	auto dm = dumper();
	dm.dump(d, r);
}