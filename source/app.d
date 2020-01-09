import std.experimental.logger;
import mygame, ABOP_app;

void main()
{
	auto app = new ABOPApp();
	scope(exit) app.destroy();

	app.run();
}
