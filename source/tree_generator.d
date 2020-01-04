module tree_generator;

import game_app;
import std.experimental.logger;
import derelict.sdl2.sdl;
import std.math, std.random, std.algorithm;
import color, serialization;
import gfm.math;

void rotate(ref vec2f vec, float angle)
{
	const auto _sin = sin(angle);
	const auto _cos = cos(angle);
	vec.x = vec.x * _cos - vec.y * _sin;
	vec.y = vec.x * _sin + vec.y * _cos;
}

class Tree
{
	this()
	{
		color.g = 255;
		root = new Node();
	}

	static class Node 
	{
		Node[] childrens;
		vec2f pos;
	}

	void drawBranch(SDL_Renderer* renderer, Node node)
	{
		foreach(n; node.childrens)
		{
			SDL_RenderDrawLine(renderer, 	cast(int) node.pos.x, cast(int) node.pos.y,
											cast(int) n.pos.x, cast(int) n.pos.y);
			drawBranch(renderer, n);
		}
	}

	void draw(SDL_Renderer* renderer)
	{
		SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a);
		drawBranch(renderer, root);
	}
	
	Node root;
	Color color;
}

class TreeGenerator
{
	void generateBranch(Tree.Node node, vec2f dir, float localAngle, float size, uint currentDepth)
	{
		if (currentDepth >= depth)
			return;

		auto rnd = Random(unpredictableSeed);
		currentDepth++;
		
		dir.rotate(localAngle);

		auto start = node.pos;
		vec2f to = start + dir * size;
		uint divisions = uniform(minDivisions, maxDivisions, rnd);
		float angleInc = uniform(minAngle, maxAngle, rnd) / divisions;

		auto child = new Tree.Node();
		child.pos = to;
		node.childrens ~= child;

		for (uint i = 0; i < divisions; i++)
		{
			generateBranch(child, (to - start).normalized, i * angleInc, 
				uniform(minBranchSize, maxBranchSize, rnd) - currentDepth * uniform(minSizeDec, maxSizeDec, rnd), 
				currentDepth);
		}

	}

	auto generate()
	{
		auto tree = new Tree();
		tree.root.pos = rootPos;
		generateBranch(tree.root, vec2f(-0.3, -0.3).normalized, 0, truncSize, 0);
		return tree;
	}

	@Serialize() 
	{
		float minBranchSize, maxBranchSize;
		float minAngle, maxAngle;
		float startThikness, endThikness;
		float minSizeDec, maxSizeDec;
		uint minDivisions, maxDivisions;
		float truncSize;
		uint depth;
	}
	vec2f rootPos;
}