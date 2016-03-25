package;
import flixel.FlxSprite;

/**
 * ...
 * @author Ando
 */
typedef E_DIRECTION = Player.E_PLYDIR;
 
class Direction extends FlxSprite
{
	public var m_dir : E_DIRECTION = E_DIRECTION.UP;
		
	public function new() 
	{
		super();
		// リソースのロード
		loadGraphic( AssetPaths.IMAGE_RES, true );
		
	    animation.add( "Direction", [AssetPaths.GameCommon.MapChip_Dir], 1 );
	}

	public function init()
	{
		m_dir = UP;
		set_angle( 0 );
		offset.set( AssetPaths.GameCommon.ResSize / 2, AssetPaths.GameCommon.ResSize );
		origin.set( AssetPaths.GameCommon.ResSize / 2, AssetPaths.GameCommon.ResSize );
		animation.play( "Direction" );
	}
	
	override public function update( elapsed : Float )
	{
		super.update( elapsed );
		
		switch( m_dir ){
			case UP:	set_angle( 0 );
			case DOWN:	set_angle( 180 );
			case RIGHT:	set_angle( 90 );
			case LEFT:	set_angle( 270 );
		}
	}
	
	public function SetLocation( _x : Float, _y : Float, _dir : E_DIRECTION )
	{
		setPosition( _x, _y );
		m_dir = _dir;
	}
}