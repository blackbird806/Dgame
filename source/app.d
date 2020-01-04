import std.experimental.logger;
import mygame;

void main()
{
	auto app = new MyGame();
	scope(exit) app.destroy();

	app.run();
}
