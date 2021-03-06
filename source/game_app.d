module game_app;

import std.experimental.logger;
import core.thread : dur, Thread;
import std.datetime.stopwatch : StopWatch, AutoStart;
import std.algorithm;
import derelict.sdl2.sdl;

struct Input
{
    bool[SDL_NUM_SCANCODES] key;
    bool[SDL_NUM_SCANCODES] keyPressed;
    int x, y, xrel, yrel;
    int xwheel, ywheel;
}

interface IEntity
{
	void start();
	void update(float deltaTime);
	void draw(SDL_Renderer*);
}

class GameApp
{
	this()
	{
		initSDL();
	}

	private void initSDL()
	{
		DerelictSDL2.load();

		//Initialize SDL
		if( SDL_Init( SDL_INIT_VIDEO ) < 0 )
		{
			error("failed to init sdl");
			assert(false);
		}

		window = SDL_CreateWindow( "SDL Tutorial", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH, 
																SCREEN_HEIGHT, SDL_WINDOW_SHOWN);
		SDL_SetWindowResizable(window, SDL_bool.SDL_TRUE);

		if (window == null)
		{
			error("failed to create window");
			assert(false);
		}

		renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
		if (renderer == null)
		{
			error("failed to create renderer");
			assert(false);
		}

		log("init sdl successfully");
	}

	protected void onWindowResized()
	{
		SDL_GetWindowSize(window, &SCREEN_WIDTH, &SCREEN_HEIGHT);
		log("window resized w: ", SCREEN_WIDTH, " h: ", SCREEN_HEIGHT);
	}

	protected void rollV(int y)
	{

	}

	private void handleInputs()
	{
		foreach (key, ref value; inputs.keyPressed)
		{
			value = false;
		}
		SDL_Event event;
   		while(SDL_PollEvent(&event))
		{
			switch(event.type)
			{
				case SDL_QUIT:
					appRunning = false;
				break;

				case SDL_WINDOWEVENT:
					switch(event.window.event)
					{
						case SDL_WINDOWEVENT_SIZE_CHANGED:
							onWindowResized();
						break;
						default:
					}
				break;

				case SDL_MOUSEWHEEL:
					rollV(event.wheel.y);
				break;

				case SDL_KEYDOWN:
					if (!inputs.key[event.key.keysym.scancode] )
						inputs.keyPressed[event.key.keysym.scancode] = true;
					inputs.key[event.key.keysym.scancode] = true;
				break;

				case SDL_KEYUP:
					inputs.key[event.key.keysym.scancode] = false;
				break;

				default:
				break;
			}
		}
	}

	protected void start()
	{

	}

	public void run()
	{
		start();
		auto sw = StopWatch(AutoStart.yes);
		float minFrameTime =  1 / 60.0f;
		while(appRunning)
		{
			 if (deltaTime < minFrameTime)
			{
				// @TODO 
			//	Thread.sleep(dur!"msecs"(cast(uint) ((minFrameTime - deltaTime) * 1000)));
				Thread.sleep(dur!"msecs"(14));
			}

			auto old = time;
			time = cast(float) sw.peek.total!"msecs" / 1000;
			deltaTime = (time - old);

			handleInputs();
			update();
			draw();
			SDL_RenderPresent(renderer);
		}
	}

	protected void update()
	{
		foreach (entity; entities)
		{
			entity.update(deltaTime);
		}
	}

	protected void draw()
	{
		clear();
		foreach (entity; entities)
		{
			entity.draw(renderer);
		}
	}

	protected void clear()
	{
		SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
		SDL_RenderClear(renderer);
	}

	~this()
	{
		SDL_DestroyRenderer(renderer);
		SDL_DestroyWindow(window);
		SDL_Quit();
	}

	SDL_Window* window;
	SDL_Renderer* renderer;
	bool appRunning = true;
	Input inputs;

	int SCREEN_WIDTH = 1280;
	int SCREEN_HEIGHT = 720;

	IEntity[] entities;

	float time;
	float deltaTime;
}