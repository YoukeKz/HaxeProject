package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import util.DebugUtil;

/**
 * ...
 * @author Ando
 */
typedef E_PLYDIR = Refline.E_DIR;

class Player extends FlxSprite
{
	//*************************/
	/* static values
	//*************************/
	private	static var s_player 	: Player	= null;
	private	static var s_velocity 	: Float		= 2.5;
	private static var s_parent		: GameState	= null;
	private static var s_laserVel	: Float		= 1.0;
	
	//*************************/
	/* member values
	//*************************/
	private var m_bulletNum	: Int;
	private var m_dir		: E_PLYDIR;
	private var m_pos 		: FlxPoint;
	private var m_addPos 	: FlxPoint;
	private var m_size		: FlxPoint;
	private var m_dirImg	: Direction;
	
	//*************************/
	/* static functions
	//*************************/
	public static function CreateInstance( _x : Int, _y : Int ) : Player
	{
		if ( s_player != null ){
			DebugUtil.Trace( "Player_Is_Already_Created" );
			return null;
		}
		s_parent = GameState.s_instance;
		
		s_player 	= new Player();
		s_player.init( _x, _y );
		return s_player;
	}
	
	public function GetInstance() : Player
	{
		if( s_player == null ){
			DebugUtil.Trace( "Player_Was_Not_Created_Yet" );
		}
		return s_player;
	}
	
	//*************************/
	/* member functions
	//*************************/
	public function new() 
	{
		super();

		// リソースのロード
		loadGraphic( AssetPaths.IMAGE_RES, true );
		
		// アニメーションの登録
	    animation.add( "Player", [AssetPaths.GameCommon.MapChip_Player], 1 );
		
		m_bulletNum	= 5;
		m_pos		= new FlxPoint();
		m_addPos	= new FlxPoint();
		m_size		= new FlxPoint();
		m_dirImg	= new Direction();
		m_dirImg.init();
		s_parent.add( m_dirImg );

		offset.set( AssetPaths.GameCommon.ResSize / 2, AssetPaths.GameCommon.ResSize / 2 );
		
	}
	
	private function init( _x : Int, _y : Int )
	{
		m_pos.set( _x, _y );
		m_addPos.set();
		m_size.set();
		m_dir = UP;
		m_dirImg.SetLocation( m_pos.x, m_pos.y, m_dir );
		animation.play( "Player" );
	}
	
	override public function update( elapsed : Float )
	{
		super.update( elapsed );
		
		if ( FlxG.keys.anyPressed( ["UP"] ) ){
			m_addPos.y -= s_velocity;
			m_dir = E_PLYDIR.UP;
		}
		else if ( FlxG.keys.anyPressed( ["DOWN"] ) ){
			m_addPos.y += s_velocity;
			m_dir = E_PLYDIR.DOWN;
		}

		if ( FlxG.keys.anyPressed( ["RIGHT"] ) ){
			m_addPos.x += s_velocity;
			m_dir = E_PLYDIR.RIGHT;
		}
		else if ( FlxG.keys.anyPressed( ["LEFT"] ) ){
			m_addPos.x -= s_velocity;
			m_dir = E_PLYDIR.LEFT;
		}
		
		if ( FlxG.keys.justPressed.Z ){
			Refline.Add( m_pos.x, m_pos.y, m_dir, s_laserVel, 70 );
		}
		if ( FlxG.keys.justPressed.SPACE ){
			trace( "SPACE" );
		}
		
		m_pos.add( m_addPos.x, m_addPos.y );
		m_addPos.set();
		setPosition( m_pos.x, m_pos.y );
		
		m_dirImg.SetLocation( x, y, m_dir );
	}
	
}