package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var m_width : Int 	= 320;
	public static var m_height : Int	= 240;
	
	public function new()
	{
		super();
		addChild( new FlxGame( m_width, m_height, PlayState ) );
	}
}