module LSystem;

import std.experimental.logger;
import derelict.sdl2.sdl;
import std.math, std.algorithm;
import gfm.math;
import utility;

class LSystem
{
	this(vec2f start, string path)
	{
		color.r = 255;
		points ~= start;
		auto currentPos = start;
		auto currentAngle = 0.0f;
		auto dir = vec2f(0, -1);

		for (auto index = 0; index < path.length; index++)
		{
			auto current = path[index];
			switch(current)
			{
				case 'F':
					currentPos = currentPos + dir.rotated(currentAngle).normalized * stepLength;
					points ~= currentPos;
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
			SDL_RenderDrawLine(renderer, cast(int) prev.x, cast(int) prev.y, cast(int) pt.x, cast(int) pt.y);
			
			renderer.SDL_SetRenderDrawColor(0, 255, 0, 255);
			SDL_Rect r = {x: cast(int) pt.x, y: cast(int) pt.y, w: 3, h: 3};
			SDL_RenderFillRect(renderer, &r);
		}
	}

	vec2f[] points;
	float stepLength = 30.0f;
	float stepAngle = PI_2;
	Color color;
}