module mygame;

import game_app;
import std.experimental.logger;
import derelict.sdl2.sdl;
import std.math, std.random;
import color;
import gfm.math;
import tree_generator;

class Ship : IEntity
{
	public:

	void start()
	{
		
	}

	void update(float deltaTime)
	{
		
	}

	void draw(SDL_Renderer* renderer)
	{
		SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a);
		rect.x = cast(int) pos.x.round;
		rect.y = cast(int) pos.y.round;
		SDL_RenderFillRect(renderer, &rect);
	}

	float speed;
	vec2f pos;
	Color color;
	SDL_Rect rect;
}

class AIShip : Ship
{
	override void start()
	{
		targetPos = target.pos;
	}

	override void update(float deltaTime)
	{
		if (targetPos.distanceTo(pos) >= targetPrecision)
		{
			vec2f dir = (targetPos - pos).normalized;
			pos += dir * speed * deltaTime;
		}
		else
		{
			// target reached
			auto rnd = Random(unpredictableSeed);
			targetPos = target.pos + vec2f(uniform(-100.0f, 100.0f, rnd), uniform(-100.0f, 100.0f, rnd));
		}
	}

	public void setTarget(Ship target)
	{
		this.target = target;
	}

	Ship target;
	vec2f targetPos;
	float targetPrecision = 10.0f;
}

class MyGame : GameApp
{
	immutable configFile = "datas.yaml";

	void loadYamlFile()
	{
		import dyaml;
		import std.stdio;

		//Read the input.
		Node root = Loader.fromFile(configFile).load();
		player.speed = root["player"]["speed"].as!float;
		player.rect.w = root["player"]["w"].as!int;
		player.rect.h = root["player"]["h"].as!int;
		player.color.r = root["player"]["color"]["r"].as!ubyte;
		player.color.g = root["player"]["color"]["g"].as!ubyte;
		player.color.b = root["player"]["color"]["b"].as!ubyte;

		log("config file loaded");
	}

	override void start()
	{
		super.start();
		player = new Ship();
		with (player) {
			with (rect) {
				w = 30;
				h = 30;
			}
			speed = 300.0f;
			color.g = 255;
			pos.xy = [0, 0];
		}
		log(player.rect);
		// entities ~= player;

		agents = new AIShip[50];
		// workaround with array of interfaces, still unsure why things are like that
		foreach (ref agent; agents)
		{
			agent = new AIShip();
			with (agent) {
				with (rect) {
					w = 15;
					h = 15;
				}
				speed = 250.0f;
				color.b = 255;
				pos.xy = [0, 0];
				target = player;
			}
		}

		// @TODO open a issue for this (both dmd and ldc)
		// entities ~= agents; bug for some reasons
		// foreach (agent; agents)
		// 	entities ~= agent;

		auto tree = new TreeGenerator();
		with (tree)
		{
			minBranchSize = 50.0f;
			maxBranchSize = 100.0f;

			minAngle = 10.0f;
			maxAngle = 20.0f;

			minSizeDec = 0.01f;
			maxSizeDec = 0.02f;

			minDivisions = 2;
			maxDivisions = 3;

			truncSize = 10.0f;
			color.g = 255;
			depth = 4;

			rootPos.x = SCREEN_WIDTH / 2;
			rootPos.y = SCREEN_HEIGHT - 10;
		}

		entities ~= tree;

		loadYamlFile();
	}
	
	void watch()
	{
		import fswatch;
		auto watcher = FileWatch(".", false);
		foreach (event; watcher.getEvents())
		{
			if (event.path == configFile && event.type == FileChangeEventType.modify)
			{
				loadYamlFile();
			}
		}
	}

	void updatePlayerInputs()
	{
		if (inputs.key[SDL_SCANCODE_LEFT])
		{
			player.pos.x -= player.speed * deltaTime;
		}
		if (inputs.key[SDL_SCANCODE_RIGHT])
		{
			player.pos.x += player.speed * deltaTime;
		}
		if (inputs.key[SDL_SCANCODE_UP])
		{
			player.pos.y -= player.speed * deltaTime;
		}
		if (inputs.key[SDL_SCANCODE_DOWN])
		{
			player.pos.y += player.speed * deltaTime;
		}
		if (inputs.key[SDL_SCANCODE_SPACE])
		{
			loadYamlFile();
		}
	}

	override void update()
	{
		super.update();
		updatePlayerInputs();
	}

	Ship player;
	AIShip[] agents;
}