package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	private static var WindowRight 		: Int	= 270;
	private static var WindowLeft 		: Int	= 10;
	
	// バーの定義
	private var m_bat	: FlxSprite;
	private static inline var BAT_SPEED 	: Int	= 350;
	private static inline var BAT_POS_Y 	: Int	= 230;
	private static inline var BAT_SIZE_X 	: Int	= 48;
	private static inline var BAT_SIZE_Y 	: Int	= 8;
	
	// ボールの定義
	private var m_ball	: FlxSprite;
	private var m_ballstat 	: Int = 0;
	private static inline var BALL_SIZE_X 	: Int	= 8;
	private static inline var BALL_SIZE_Y 	: Int	= 8;
	private static inline var BALL_SPD_MAX 	: Int	= 200;
	private static var INIT_BALL_POS_X 	: Int	= 0;
	private static var INIT_BALL_POS_Y	: Int	= 0;
	
	// 壁の定義
	private var m_walls		: FlxGroup;
	private var m_wall_L	: FlxSprite;
	private var m_wall_R	: FlxSprite;
	private var m_wall_T	: FlxSprite;
	private var m_wall_B	: FlxSprite;
	private var WALL_SIDE_SIZE_X	: Int = 10;	
	private var WALL_SIDE_SIZE_Y	: Int = 240 + 10;	
	private var WALL_FRONT_SIZE_X 	: Int = 320;	
	private var WALL_FRONT_SIZE_Y 	: Int = 10;

	// 破壊壁の定義
	private var m_bricks				: FlxGroup;
	private static inline var BRICKS_SIZE_X 	: Int = 15;
	private static inline var BRICKS_SIZE_Y 	: Int = 15;

	override public function create():Void
	{
		// バーの生成
		{
			m_bat = new FlxSprite( ( Main.m_width - BAT_SIZE_X ) / 2, BAT_POS_Y );
			m_bat.makeGraphic( BAT_SIZE_X, BAT_SIZE_Y, FlxColor.PINK );	// 40*6の矩形をピンク色で生成
			m_bat.immovable = true;							// 当たっても動かなくする
			add( m_bat );
		}
		
		// ボールの生成
		{
			INIT_BALL_POS_X = Std.int( ( Main.m_width - BALL_SIZE_X ) / 2 );
			INIT_BALL_POS_Y = Main.m_height - 100;
			m_ball = new FlxSprite( INIT_BALL_POS_X, INIT_BALL_POS_Y );
			m_ball.makeGraphic( BALL_SIZE_X, BALL_SIZE_Y, FlxColor.BLUE );
			m_ball.elasticity 	= 1;
			m_ball.maxVelocity.set( BALL_SPD_MAX, BALL_SPD_MAX );
			m_ball.velocity.y = BALL_SPD_MAX;
			
			// 初期の状態では、ボールは動かさない
			{
				m_ballstat = 0;
				m_ball.set_active( false );
			}
			
			add( m_ball );
		}
		
		// 壁を作成
		{
			m_walls = new FlxGroup();	// 壁グループ

			//　左壁
			m_wall_L = new FlxSprite( 0, 0 );
			m_wall_L.makeGraphic( WALL_SIDE_SIZE_X, WALL_SIDE_SIZE_Y, FlxColor.GRAY );
			m_wall_L.immovable = true;
			m_walls.add( m_wall_L );
			
			// 右壁
			m_wall_R = new FlxSprite( Main.m_width - WALL_SIDE_SIZE_X, 0 );
			m_wall_R.makeGraphic( WALL_SIDE_SIZE_X, WALL_SIDE_SIZE_Y, FlxColor.GRAY );
			m_wall_R.immovable = true;
			m_walls.add( m_wall_R );
			
			// 上壁
			m_wall_T = new FlxSprite( 0, 0 );
			m_wall_T.makeGraphic( WALL_FRONT_SIZE_X, WALL_FRONT_SIZE_Y, FlxColor.GRAY );
			m_wall_T.immovable = true;
			m_walls.add( m_wall_T );
			
			// 下壁
/*			m_wall_B = new FlxSprite( 0, WALL_SIDE_SIZE_Y );
			m_wall_B.makeGraphic( WALL_FRONT_SIZE_X, WALL_FRONT_SIZE_Y, FlxColor.GRAY );
			m_wall_B.immovable = true;
			m_walls.add( m_wall_B );
*/
			add( m_walls );
		}
		
		// 破壊壁の作成
		{
			m_bricks = new FlxGroup();
			var _bx		: Int = WALL_SIDE_SIZE_X;
			var _by		: Int = 30;
			var _loopx	: Int = Std.int( ( Main.m_width - WALL_SIDE_SIZE_X * 2 ) / BRICKS_SIZE_X );
			var _loopy	: Int = 6;
			var _colors:Array<Int> = [0xffd03ad1, 0xfff75352, 0xfffd8014, 0xffff9024, 0xff05b320, 0xff6d65f6];			
			for( _y in 0..._loopy ){
				for( _x in 0..._loopx ){
					var _tmp : FlxSprite = new FlxSprite( _bx, _by );
					_tmp.makeGraphic( BRICKS_SIZE_X, BRICKS_SIZE_Y, _colors[ _y ] );
					_tmp.immovable = true;
					m_bricks.add( _tmp );
					_bx += BRICKS_SIZE_X;
				}
				_bx = WALL_SIDE_SIZE_X;
				_by += BRICKS_SIZE_Y;
			}
			add( m_bricks );
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		m_bat.velocity.x = 0;
		
		if ( FlxG.keys.justPressed.SPACE ){
			if( m_ballstat == 0 ){
				m_ballstat = 1;
				m_ball.set_active( true );
				m_ball.velocity.set( 0, 200 );
			}
		}	
		
		// キー入力
		if ( FlxG.keys.anyPressed( ["LEFT"] ) ){
			if( m_bat.x > WindowLeft ){
				m_bat.velocity.x = -BAT_SPEED;
			}
		}
		else if ( FlxG.keys.anyPressed( ["RIGHT"] ) ){
			if( m_bat.x < WindowRight ){
				m_bat.velocity.x = BAT_SPEED;
			}
		}
		
		// Ｒキーでやりなおし　
		if( FlxG.keys.justReleased.R ){
			FlxG.resetState();
		}
		
		if( m_bat.x < WindowLeft ){
			m_bat.x = WindowLeft;
		}
		else if( m_bat.x > WindowRight ){
			m_bat.x = WindowRight;
		}
		
		FlxG.collide( m_ball, m_walls );
		FlxG.collide( m_bat, m_ball, Callback_Collision );
		FlxG.collide( m_ball, m_bricks, Callback_Bricks );
		
		if( m_ball.x < 0 				- 10	||
			m_ball.x > Main.m_width 	+ 10	||
			m_ball.y < 0 				- 10	||
			m_ball.y > Main.m_height 	+ 10 	)
		{
			m_ball.setPosition( INIT_BALL_POS_X, INIT_BALL_POS_Y );
			m_ballstat = 0;
			m_ball.set_active( false );
		}
	}
	
	private function Callback_Collision( _bat : FlxObject, _ball : FlxObject )
	{
		var _batmid 	: Int = Std.int( _bat.x )  + Std.int( BAT_SIZE_X / 2 );
		var _ballmid 	: Int = Std.int( _ball.x ) + Std.int( BALL_SIZE_X / 2 );
		var _diff 		: Int = 0;

		if ( _ballmid == _batmid ){
			_ball.velocity.x = FlxG.random.int( 0, 8 );
		}
		else{
			_diff = _ballmid - _batmid;
			_ball.velocity.x = 10 * _diff;
		}
	}
	
	private function Callback_Bricks( _ball : FlxObject, _bricks : FlxObject )
	{
		_bricks.exists = false;
		_bricks.kill;
	}

}
