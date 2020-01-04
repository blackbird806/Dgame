module mygame;

import std.experimental.logger;
import std.math, std.random;
import derelict.sdl2.sdl;
import gfm.math;
import dyaml;

import game_app;
import tree_generator;
import color, serialization;

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

		treeGen = new TreeGenerator();
		with (treeGen)
		{
			minBranchSize = 22.0f;
			maxBranchSize = 50.0f;

			minAngle = 0.3f;
			maxAngle = 0.7f;

			minSizeDec = 0.03f;
			maxSizeDec = 0.05f;

			minDivisions = 1;
			maxDivisions = 4;

			truncSize = 10.0f;
			depth = 8;

			rootPos.x = SCREEN_WIDTH / 2;
			rootPos.y = SCREEN_HEIGHT - 10;
		}

		tree = treeGen.generate();

		Loader.fromFile("output.yaml").load()["my tree"].deserializeInto(treeGen);

		Node r;
		r.add("my tree", treeGen.toYAMLNode());

		import std.stdio;
		// auto d = File("output.yaml", "w").lockingTextWriter;
		// auto dm = dumper();
		// dm.dump(d, r);
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
			tree = treeGen.generate();
			// loadYamlFile();
		}
	}

	override void update()
	{
		super.update();
		updatePlayerInputs();
	}

	override void draw()
	{
		super.draw();
		tree.draw(renderer);
	}

	Ship player;
	AIShip[] agents;
	Tree tree;
	TreeGenerator treeGen;
}