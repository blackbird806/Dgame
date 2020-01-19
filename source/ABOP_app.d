module ABOP_app;

import std.experimental.logger;
import std.math, std.random, std.stdio;
import derelict.sdl2.sdl;
import gfm.math.vector;

import fswatch;
import game_app;
import serialization, utility;
import LSystem;

class ABOPApp : GameApp
{
	System sys = {initial: 'F', expanded: "F[+F]F[-F]F"};
	System sys2 = {'X', "F[+X]F[-X]+X"};

	override void start()
	{
		watcher = FileWatch(".", false);

		speed = baseSpeed;
		lsystem = new LSystem();
		lsystem.start = vec2f(SCREEN_WIDTH/1.5, SCREEN_HEIGHT / 2);
		lsystem.nbIts = 1;
		lsystem.stepLength = 30.0f;
		lsystem.stepAngle = 0.31;
		lsystem.color.b = 255;
		// sys.expanded = "F-F+F+FF-F-F+F";
		// lsystem.generate("F-F-F-F",  [sys]);
		// sys.expanded = "F+F-F-F+F";
		// lsystem.generate("F-F-F-F", [sys]);
		sys.expanded = "FF-[-F+F+F]+[+F-F-F]";
		// sys.expanded = "FF";
		// sys.initial = "F";
		// sys.expanded = "F[+F][-F]FX";
		// sys2.expanded = "-[-F[-FF]]+F[+X]";
		// System sys3 = {"Z", "XF-ZXFZ"};
		// sys.expanded = "F+A+";
		// sys2.expanded = "-F-A";
		lsystem.generate("F", [sys, sys2]);
		// sys.expanded = "F+f-FF+F+FF+Ff+FF-f+FF-F-FF-Ff-FFF";
		// sys2.initial = "f";

		// sys2.expanded = "ffffff";
		// lsystem.generate("F+F+F+F", [sys, sys2]);
		deserialize("output.yaml", lsystem);
	}

	void watch()
	{
		foreach (event; watcher.getEvents())
		{
			writefln("Update");
			if (event.path == "output.yaml" && event.type == FileChangeEventType.modify)
			{
				deserialize("output.yaml", lsystem);
			}
		}
	}

	override void update()
	{
		super.update();
		watch();
		if (inputs.keyPressed[SDL_SCANCODE_SPACE])
		{
			lsystem.nbIts++;
		}
		
		lsystem.generate("F", [sys, sys2]); 

		if (inputs.key[SDL_SCANCODE_LEFT])
		{
			lsystem.start.x -= speed * deltaTime;
		}
		if (inputs.key[SDL_SCANCODE_RIGHT])
		{
			lsystem.start.x += speed * deltaTime;
		}
		if (inputs.key[SDL_SCANCODE_UP])
		{
			lsystem.start.y -= speed * deltaTime;
		}
		if (inputs.key[SDL_SCANCODE_DOWN])
		{
			lsystem.start.y += speed * deltaTime;
		}
	}

	override void rollV(int y)
	{
		import std.algorithm;
		lsystem.scale += scaleSpeed * y;
		lsystem.scale = max(0.001, lsystem.scale);
		speed = baseSpeed / lsystem.scale;
		log("scale ", lsystem.scale);
	}

	override void draw()
	{
		super.draw();
		lsystem.draw(renderer);
	}

	LSystem lsystem;
	float baseSpeed = 200.5f, speed;
	float scaleSpeed = 0.05f;
	FileWatch watcher;
}