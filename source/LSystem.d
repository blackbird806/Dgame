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
		points ~= start;
		auto currentPos = start;
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
					points ~= currentPos;
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
		}
	}

	void draw(SDL_Renderer* renderer)
	{
		for(auto i = 1; i < points.length; i++)
		{
			renderer.SDL_SetRenderDrawColor(color.r, color.g, color.b, color.a);
			auto prev = points[i-1];
			auto pt = points[i];
			// SDL_RenderDrawLine(renderer, roundTo!int(prev.x), roundTo!int(prev.y), roundTo!int(pt.x), roundTo!int(pt.y));
			
			renderer.SDL_SetRenderDrawColor(0, 255, 0, 255);
			SDL_Rect r = {x: roundTo!int(pt.x), y: roundTo!int(pt.y), w: 3, h: 3};
			SDL_RenderFillRect(renderer, &r);
		}
	}

	State[] stack;
	vec2d[] points;
	vec2d start;
	uint nbIts;
	real stepLength = 5.0;
	real stepAngle = PI_2;
	Color color;
}