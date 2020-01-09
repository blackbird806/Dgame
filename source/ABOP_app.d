module ABOP_app;

import std.experimental.logger;
import std.math, std.random;
import derelict.sdl2.sdl;
import gfm.math;

import game_app;
import serialization, utility;
import LSystem;

class ABOPApp : GameApp
{
	override void start()
	{
		lsystem = new LSystem(vec2f(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2),"FFF+FF+F+F-F-FF+F+FFF");
	}

	override void update()
	{

	}

	override void draw()
	{
		lsystem.draw(renderer);
	}

	LSystem lsystem;
}