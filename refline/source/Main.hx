package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;
import util.DebugUtil;

class Main extends Sprite
{
	public function new()
	{
		super();
		
		addChild(new FlxGame( 16 * 20, 16 * 20, GameState));
	}
}
