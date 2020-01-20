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
	System sys = {name: "sys" , initial: 'F', expanded: "F[+F]F[-F]F"};
	System sys2 = {name: "sys2", 'X', "F[+X]F[-X]+X"};
	
	enum configFile = "output.yaml";

	void loadYaml()
	{
		deserialize(configFile, lsystem);
		sys = deserialize(configFile, sys);
		sys2 = deserialize(configFile, sys2);
	}

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
		// sys.expanded = "F+f-FF+F+FF+Ff+FF-f+FF-F-FF-Ff-FFF";
		// sys2.initial = "f";

		// sys2.expanded = "ffffff";
		// lsystem.generate("F+F+F+F", [sys, sys2]);
		loadYaml();
		lsystem.generate("F", [sys, sys2]);
	}

	void watch()
	{
		foreach (event; watcher.getEvents())
		{
			writefln("Update");
			if (event.path == configFile && event.type == FileChangeEventType.modify)
			{
				loadYaml();
			}
		}
	}

	override void update()
	{
		super.update();
		watch();

		if (inputs.keyPressed[SDL_SCANCODE_KP_PLUS])
		{
			lsystem.nbIts++;
		}
		if (inputs.keyPressed[SDL_SCANCODE_KP_MINUS])
		{
			if (lsystem.nbIts > 0)
				lsystem.nbIts--;
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