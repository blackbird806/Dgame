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
	System sys = {name: "sys"};
	System sys2 = {name: "sys2"};
	
	enum configFile = "output.yaml";

	void loadYaml()
	{
		lsystem = deserialize(configFile, lsystem);
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
		lsystem.stepAngle = 0.3926991;
		lsystem.color.b = 255;

		loadYaml();
		lsystem.randomize();
		lsystem.generate("X", [sys, sys2]);
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
			lsystem.randomize();
		}
		if (inputs.keyPressed[SDL_SCANCODE_KP_MINUS])
		{
			if (lsystem.nbIts > 0)
				lsystem.nbIts--;
		}
		lsystem.generate("X", [sys, sys2]); 


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

		if (inputs.keyPressed[SDL_SCANCODE_SPACE])
		{
			alias print = std.experimental.logger.log;
			lsystem.randomize();
			print(lsystem.rnd);
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