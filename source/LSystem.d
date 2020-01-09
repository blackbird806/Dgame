module LSystem;

import std.experimental.logger;
import derelict.sdl2.sdl;
import std.math, std.algorithm, std.array;
import gfm.math;
import utility;

struct System
{
	string initial;
	string expanded;
}

struct State
{
	vec2d pos;
	float angle;
}

class LSystem
{
	void generate(string initial, System[] systems)
	{
		lines = [];
		
		auto currentPos = start;
		auto lastPos = start;
		auto currentAngle = 0.0f;
		auto dir = vec2f(0, -1);

		string path = initial;
		foreach (it; 0 .. nbIts)
		{
			foreach(system; systems)
			{
				path = path.replace(system.initial, system.expanded);
			}
		}

		for (auto index = 0; index < path.length; index++)
		{
			auto current = path[index];
			switch(current)
			{
				case 'F':
					currentPos = currentPos + dir.rotate(currentAngle).normalized * stepLength;
					Line l = {p1: lastPos, p2: currentPos};
					lines ~= l;
				break;
				case '[':
					State s = {currentPos, currentAngle};
					stack ~= s;
				break;
				case ']':
					currentPos = stack.back.pos;
					currentAngle = stack.back.angle;
					stack.popBack();
				break;
				case 'f':
					currentPos = currentPos + dir.rotate(currentAngle).normalized * stepLength;
				break;
				case '+':
					currentAngle += stepAngle;
				break;
				case '-':
					currentAngle -= stepAngle;
				break;
				default:
			}
			lastPos = currentPos;
		}
	}

	void draw(SDL_Renderer* renderer)
	{
		renderer.SDL_SetRenderDrawColor(color.r, color.g, color.b, color.a);
		foreach(line; lines)
		{
			SDL_RenderDrawLine(renderer,  roundTo!int(line.p1.x), roundTo!int(line.p1.y), 
								roundTo!int(line.p2.x), roundTo!int(line.p2.y));
		}
	}

	State[] stack;
	Line[] lines;
	vec2d start;
	uint nbIts;
	real stepLength = 5.0;
	real stepAngle = PI_2;
	Color color;
}