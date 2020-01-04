module tree_generator;

import game_app;
import std.experimental.logger;
import derelict.sdl2.sdl;
import std.math, std.random;
import color;
import gfm.math;

void rotate(ref vec2f vec, float angle)
{
	auto _sin = sin(angle);
	auto _cos = cos(angle);
	vec.x = vec.x * _cos - vec.y * _sin;
	vec.y = vec.x * _sin + vec.y * _cos;
}

class Tree
{
	static struct Branch
	{
		vec2f start, end;
	}

	static class Node 
	{
		Branch[] childrens;
	}

	Node root;
}

class TreeGenerator : IEntity
{
	void start()
	{
		rnd = Random(unpredictableSeed);
	}

	void update(float deltaTime)
	{
		
	}

	void drawBranch(SDL_Renderer* renderer, vec2f start, vec2f dir, float localAngle, float size, uint currentDepth)
	{
		if (currentDepth >= depth)
			return;

		currentDepth++;
		
		dir.rotate(localAngle);
		dir.normalize();

		vec2f to = start + dir * size;
		uint divisions = uniform(minDivisions, maxDivisions, rnd);
		float angleInc = uniform(minAngle, maxAngle, rnd) / divisions;

		SDL_RenderDrawLine(renderer, 	cast(int) start.x, cast(int) start.y,
										cast(int) to.x, cast(int) to.y);

		for (uint i = 0; i < divisions; i++)
		{
			drawBranch(renderer, to, 
				(to - start).normalized, i * angleInc, 
				uniform(minBranchSize, maxBranchSize, rnd) - currentDepth * uniform(minSizeDec, maxSizeDec, rnd), 
				currentDepth);

			drawBranch(renderer, to, 
				(to - start).normalized, -i * angleInc, 
				uniform(minBranchSize, maxBranchSize, rnd) - currentDepth * uniform(minSizeDec, maxSizeDec, rnd), 
				currentDepth);
		}

	}

	void draw(SDL_Renderer* renderer)
	{
		SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a);
		drawBranch(renderer, rootPos, vec2f(0.0f, -1.0f), 0, truncSize, 0);
	}

	auto generate()
	{
		auto tree = new Tree();
		tree.root
	}

	float minBranchSize, maxBranchSize;
	float minAngle, maxAngle;
	float startThikness, endThikness;
	float minSizeDec, maxSizeDec;
	uint minDivisions, maxDivisions;
	float truncSize;
	uint depth;
	Color color;
	vec2f rootPos;
	Random rnd;
}