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
	System sys = {initial: "F", expanded: "F[+F]F[-F]F"};
	System sys2 = {"X", "F[+X]F[-X]+X"};

	override void start()
	{
		lsystem = new LSystem();
		lsystem.start = vec2f(SCREEN_WIDTH/1.5, SCREEN_HEIGHT / 2);
		lsystem.nbIts = 2;
		lsystem.stepLength = 5f;
		// lsystem.stepAngle = 0.349066;
		lsystem.color.b = 255;
		// sys.expanded = "F-F+F+FF-F-F+F";
		// lsystem.generate("F-F-F-F",  [sys]);
		// sys.expanded = "F+F-F-F+F";
		// lsystem.generate("F-F-F-F", [sys]);
		// sys.expanded = "FF-[-F+F+F]+[+F-F-F]";
		// sys.expanded = "FF";
		// lsystem.generate("X", [sys, sys2]);
		sys.expanded = "F+f-FF+F+FF+Ff+FF-f+FF-F-FF-Ff-FFF";
		sys2.initial = "f";
		sys2.expanded = "ffffff";
		lsystem.generate("F+F+F+F", [sys, sys2]);
	}

	override void update()
	{
		if (inputs.keyPressed[SDL_SCANCODE_SPACE])
		{
			lsystem.nbIts++;
			lsystem.generate("F+F+F+F", [sys, sys2]);
		}
	}

	override void draw()
	{
		lsystem.draw(renderer);
	}

	LSystem lsystem;
}