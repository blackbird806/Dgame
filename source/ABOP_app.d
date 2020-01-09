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
		lsystem = new LSystem();
		lsystem.start = vec2f(SCREEN_WIDTH/1.5, SCREEN_HEIGHT);
		lsystem.nbIts = 5;
		lsystem.stepLength = 8.0f;
		lsystem.stepAngle = PI_4;
		lsystem.color.b = 255;
		System sys = {initial: "F", expanded: "F[+F]F[-F]F"};
		// sys.expanded = "F-F+F+FF-F-F+F";
		// lsystem.generate("F-F-F-F",  [sys]);
		// sys.expanded = "F+F-F-F+F";
		// lsystem.generate("F-F-F-F", [sys]);
		lsystem.generate("F", [sys]);

		std.experimental.logger.log("nb points : ", lsystem.points.length, 
		"\tsize : ", (lsystem.points.length * vec2f.sizeof) / 1024, " kb");
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