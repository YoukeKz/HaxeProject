package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.system.FlxAssets.FlxTilemapGraphicAsset;
import flixel.text.FlxText;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import util.DebugUtil;
//import Refline;

class GameState extends FlxState
{
	private static var m_ui 	: FlxGroup;
	public 	static var m_map 	: FlxTilemap;
	public	static var m_object	: FlxGroup;
	public 	static var m_cnt	: Int = 0;
	public	static var s_instance	: GameState;
	
	override public function create():Void
	{
		super.create();
		
		s_instance = this;

		// マップのロード
		m_map = new FlxTilemap();
		m_map.loadMapFromCSV( AssetPaths.DATA_MAPDATA, AssetPaths.IMAGE_RES, AssetPaths.GameCommon.ResSize, AssetPaths.GameCommon.ResSize, FlxTilemapAutoTiling.OFF, 0, 0 );
		add( m_map );

		add( Refline.CreateGroup() );
		add( Player.CreateInstance( 100, 100 ) );
		
		FlxG.debugger.toggleKeys = ["ALT"];
	}
	
	/*!
		@brief	
		@date	2016/3/29
	*/
	override public function destroy()
	{
		Refline.DestroyGroup();
		super.destroy();
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		Refline.DbgPrint();
		
		// 次のステートへ移る
		if ( FlxG.keys.justPressed.R ){
			FlxG.switchState( new GameState() );
			m_cnt ++;
		}
	}
	
	public static function GetMapTile( _x : Int, _y : Int ) : Int
	{
		if( _x < 0 || _x >= m_map.widthInTiles ||
			_y < 0 || _y >= m_map.heightInTiles )
		{
			DebugUtil.Trace( "Value_Is_Out_Of_Range: " + _x + ", " + _y );
			return -1;
		}
		return m_map.getTile( _x, _y );
	}
	
	public static function GetMapWidth() : Int
	{
		return m_map.widthInTiles;
	}

	public static function GetMapHeight() : Int
	{
		return m_map.heightInTiles;
	}
}
