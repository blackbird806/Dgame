module LSystem;

import std.experimental.logger;
import derelict.sdl2.sdl;
import std.math, std.algorithm, std.array, std.random;
import gfm.math;
import utility, serialization;

struct Production
{
	@Serialize:
		string 	expanded;
		float 	probability;
}

struct System
{
	string name;
	
	// https://stackoverflow.com/questions/4463561/weighted-random-selection-from-array
	string getExpanded(float rnd)
	{
		float[] CDF = [ productions[0].probability ];
		for (int i = 1; i < productions.length; i++)
		{
			CDF ~= CDF.back + productions[i].probability;
		}

		const auto index = max(0, CDF.countUntil!((a, b) => a > b)(rnd));
		return productions[index].expanded;
	}

	@Serialize:
		char axiom;
		Production[] productions;
}

struct State
{
	vec2f pos;
	float angle;
}

class LSystem
{
	void generate(string initial, System[] systems)
	{
		lines = [];
		stack = [];
		
		auto currentPos = start;
		auto lastPos = start;
		auto currentAngle = 0.0f;
		auto dir = vec2f(0, -1);

		string path = initial;
		foreach (i; 0 .. nbIts)
		{
			foreach(system; systems)
			{
				path = path.replace(system.axiom, system.getExpanded(rnd[i]));
			}
		}

		float thickness = 1.0f;
		float progression = 0.0f;

		for (auto index = 0; index < path.length; index++)
		{
			thickness = lerp(startThickness, endThickness, progression);
			progression += 1.0f / cast(float) path.length;

			auto current = path[index];

			switch(current)
			{
				case 'F':
					currentPos = currentPos + dir.rotate(currentAngle).normalized * stepLength;
					lines ~= Line(lastPos * scale, currentPos * scale, thickness);
				break;
				case '[':
					stack ~= State(currentPos, currentAngle);
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

	void randomize()
	{
		rnd.length = nbIts;
		foreach (ref r; rnd)
		{
			r = uniform(0.0f, 1.0f);
		}
	}

	void draw(SDL_Renderer* renderer)
	{
		SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a);

		foreach(line; lines)
		{
			SDL_RenderDrawLine(renderer, 	roundTo!short(line.p1.x),
											roundTo!short(line.p1.y),
											roundTo!short(line.p2.x),
											roundTo!short(line.p2.y));
		}
	}

	State[] stack;
	Line[] lines;
	string name = "lsystem";

	uint nbIts;
	vec2f start;
	float scale = 1.0f;
	float[] rnd;

	@Serialize:
		float startThickness = 1.0f;
		float endThickness = 1.0f;
		real stepLength = 5.0;
		real stepAngle = PI_2;
		Color color;
}