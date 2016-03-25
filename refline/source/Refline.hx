package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import haxe.ds.Vector;
import util.Array2D;
import AssetPaths;
import util.DebugUtil;

/**
 * ...
 * @author Ando
 */
 
enum E_DIR{
	UP;
	DOWN;
	LEFT;
	RIGHT;
}
 
class Refline extends FlxSprite
{
	//*************************/
	/* static values
	//*************************/
	// public
	public 	static var s_group		: FlxTypedGroup< Refline > = null;
	
	// private
	private static var s_lengthMax		: Int 	= 3;
	private	static var s_isCreategroup 	: Bool 	= false;
	private static var s_objCnt			: Int	= 0;
	private static var s_fgDbgPrint		: Bool	= false;

	//*************************/
	/* member values
	//*************************/
	private var m_dir 		: E_DIR = E_DIR.UP;		// 向き
	private var m_nextDir 	: E_DIR = E_DIR.DOWN;	// 向き
	private var m_pos		: FlxPoint;	// ポジション
	private var m_head 		: FlxPoint;	// 頭のポジション
	private var m_addPos	: FlxPoint;	// ポジションに加算する値
	private var m_addHead 	: FlxPoint;	// 頭のポジションに加算する値
	private var m_velocity	: Float;	// 速度
	private var m_fgLenMax	: Bool;		// のびきったかどうか
	private var m_fgHitWall	: Bool;		// 壁にぶつかったかどうか
	private var m_refCnt	: Int;		// 跳ね返れる回数
	private var m_Cnt		: Int;		// 跳ね返れる回数
	
	//*************************/
	/* static public functions
	//*************************/
	/*!
		@brief	専用のグループの作成をします。
		@date	2016/3/18
	*/
	public static function CreateGroup() : FlxTypedGroup< Refline >
	{
		if( s_group == null ){
			s_group = new FlxTypedGroup< Refline >( 60 );
			
			for ( i in 0...s_group.maxSize ){
				s_group.add( new Refline() );
			}
			
			s_fgDbgPrint = false;
			return s_group;
		}
		return null;
	}
	
	/*!
		@brief	グループのインスタンスを取得します。
		@date	2016/3/18
	*/
	public static function GetGroup() : FlxTypedGroup< Refline >
	{
		if( s_group != null ){
			return s_group;
		}
		return null;
	}
	
	/*!
		@brief	グループにオブジェクトを追加します。
		@date	2016/3/18
	*/
	public static function Add( _x : Float, _y : Float, _dir : E_DIR, _vel : Float = 4, _ref : Int = 10 )
	{
		if( s_group != null ){
			var _obj : Refline = s_group.recycle();
			s_group.add( _obj );
			
			_obj.init( Std.int( _x ), Std.int( _y ), _dir, _vel, _ref );
			
			s_objCnt++;
			s_fgDbgPrint = true;
		}
	}
	
	public static function DbgPrint()
	{
		if( s_fgDbgPrint ){
			s_fgDbgPrint = false;
//			DebugUtil.Trace( "ObjectCnt : " + s_objCnt );
		}
	}
	
	//*************************/
	/* public functions
	//*************************/
	/*!
		@brief	コンストラクタ
		@date	2016/3/18
	*/
	override public function new() 
	{
		super();

		// リソースのロード
		loadGraphic( AssetPaths.IMAGE_RES, true );
		
		// アニメーションの登録
	    animation.add( "Laser", [GameCommon.MapChip_Raser], 1);

		// 必要なオブジェクトの作成
		m_pos		= new FlxPoint();
		m_head		= new FlxPoint();
		m_addPos	= new FlxPoint();
		m_addHead	= new FlxPoint();
		
		// まだ使わないのでキルしておく
		kill();
		FlxG.watch.add(this, "y", "refline.y");
	}
	
	/*!
		@brief	初期化
		@date	2016/3/16
	*/
	public function init( _x : Int, _y : Int, _dir : E_DIR, _vel : Float = 4, _ref : Int = 10 )
	{
		m_pos.set( _x, _y );
		m_head.set();
		m_addPos.set();
		m_addHead.set();
		m_velocity 	= _vel;
		m_dir 		= _dir;
		m_fgLenMax	= false;
		m_fgHitWall	= false;
		m_refCnt	= _ref;
		
		// 指定した向きによって、角度を設定する。
		switch( m_dir ){
			case UP:	set_angle( 270 );
			case DOWN:	set_angle( 90 );
			case LEFT:	set_angle( 180 );
			case RIGHT:	set_angle( 0 );
		}
		
		// 中心点ずらし
		SetOrigin( GameCommon.ResSize, GameCommon.ResSize / 2 );

		// スケールのセット
		scale.set( 0, 1 );

		// ポジション設定
		setPosition( _x, _y );

		// アニメーションの開始
		animation.play( "Laser" );

		m_Cnt = 0;
	}
	
	/*!
		@brief	処理の更新
		@date	2016/3/16
	*/
	override public function update(elapsed:Float)
	{
//		super.update(elapsed);
		
		if ( !m_fgHitWall ){
			m_Cnt++;
			if( m_Cnt > 0 ){
				Update_BeforeHitWall();
				m_Cnt = 0;
			}
			else{
				return;
			}
		}
		else{
			Update_AfterHitWall();
		}

		// 速度を加算する
		{
			m_pos.addPoint( m_addPos );
			m_addPos.set();
			
			m_head.addPoint( m_addHead );
			m_addHead.set();
		}
		
		// ポジションの更新
		setPosition( 	m_pos.x + m_head.x, 
						m_pos.y + m_head.y );
		
		// 画面外チェック
		CheckOutOfCamera();				
		// デバッグ出力
//		DebugUtil.Trace( "( " + x + ", " + y + " )" );
	} 
	
	//*************************/
	/* private functions
	//*************************/
	/*!
		@brief	画面外に出たら、タスクをキルします。
		@date	2016/3/24
	*/
	private function CheckOutOfCamera()
	{
		if( x < -5 || x > FlxG.width ||
			y < -5 || y > FlxG.height )
		{
			kill();
		}	
	}
	
	/*!
		@brief	壁にぶつかる前の更新処理
		@date	2016/3/18
	*/
	private function Update_BeforeHitWall()
	{
		// 長さが最大になる前。スケールのみ変更
		if ( !m_fgLenMax ){
			// スケールを大きくする
			scale.x += m_velocity / GameCommon.ResSize;
			
			// 頭の位置を指定してやる
			var _head : Float = m_velocity;
			switch( m_dir ){
				case UP:	m_addHead.set( 0, -_head );
				case DOWN:	m_addHead.set( 0, _head );
				case LEFT:	m_addHead.set( -_head, 0 );
				case RIGHT:	m_addHead.set( _head, 0 );
			}

			// スケールが最大になったら
			if( scale.x > s_lengthMax ){
				// スケールに補正を掛けて、最大値にする。
				scale.x = s_lengthMax;
				
				// 長さが最大になりましたフラグ
				m_fgLenMax = true;
			}

			// 長さが最大のとき
			if( m_fgLenMax ){
				// 中心点ずらし
				SetOrigin( GameCommon.ResSize, GameCommon.ResSize / 2 );
				
				// 頭の位置を指定してやる
				var _head : Float = GameCommon.ResSize * s_lengthMax;
				switch( m_dir ){
					case UP:
						m_addHead.set( 0, - ( m_head.y + _head ) );
						m_addPos.set( 0, m_velocity + m_addHead.y );
					case DOWN:
						m_addHead.set( 0, -( m_head.y - _head ) );
						m_addPos.set( 0, m_velocity - m_addHead.y );
					case LEFT:
						m_addHead.set( -( m_head.x + _head ), 0 );
						m_addPos.set( m_velocity + m_addHead.x, 0 );
					case RIGHT:
						m_addHead.set( -( m_head.x - _head ), 0 );
						m_addPos.set( m_velocity - m_addHead.x, 0 );
				}
			}
		}
		else{
			// 速度を加算する
			switch( m_dir ){
				case UP:	m_addPos.y -= m_velocity;
				case DOWN:	m_addPos.y += m_velocity;
				case LEFT:	m_addPos.x -= m_velocity;
				case RIGHT:	m_addPos.x += m_velocity;
			}
		}

		
		// 壁との接触チェック
		CheckHitWall();
	}
	
	/*!
		@brief	壁にぶつかった後の更新処理
		@date	2016/3/18
	*/
	private function Update_AfterHitWall()
	{
		// スケールを小さくする
		scale.x -= m_velocity / GameCommon.ResSize;
		
		// スケールが0以下になったら
		if( scale.x < 0 ){
			// スケールに補正を掛けて、0にする。
			scale.x = 0;
			s_objCnt--;
			s_fgDbgPrint = true;
			kill();
//			DebugUtil.Trace( x + ", " + y );
		}
	}
	
	/*!
		@brief	中心点ずらしをします。
		@date	2016/3/18
	*/
	private function SetOrigin( _x : Float, _y : Float ){
		origin.set( _x, _y );
		offset.set( _x, _y );
	}
	
	/*! OldFunction
		@brief	壁に接触したか
		@date	2016/3/18
	*//*
	private function CheckHitWall_Old(){
		if ( !m_fgHitWall ){
			if( !m_fgLenMax ){
				return;
			}
			else{
				if ( x < GameCommon.ResSize ){
					m_addPos.x = GameCommon.ResSize - x;
					m_fgHitWall = true;
				}
				else if ( x > FlxG.width - GameCommon.ResSize ){
					m_addPos.x = ( FlxG.width - GameCommon.ResSize ) - x;
					m_fgHitWall = true;
				}
				else if ( y < GameCommon.ResSize ){
					m_addPos.y = GameCommon.ResSize - y;
					m_fgHitWall = true;
				}
				else if( y > FlxG.height - GameCommon.ResSize ){
					m_addPos.y = ( FlxG.height - GameCommon.ResSize ) - y;
					m_fgHitWall = true;
				}
			}
			
			// ここは一度しか通らない。
			if ( m_fgHitWall && m_refCnt > 0 ){
				var _rand = FlxG.random.int( 0, 2 );
				var _table : Array< E_DIR >;
				switch( m_dir ){
					case UP:	_table = [ DOWN, 	LEFT, 	RIGHT ];
					case DOWN:	_table = [ UP, 		LEFT, 	RIGHT ];
					case LEFT:	_table = [ UP, 		DOWN, 	RIGHT ];
					case RIGHT:	_table = [ UP, 		DOWN, 	LEFT ];
				}
				Add( x, y, _table[ _rand ], m_velocity * 0.9, m_refCnt - 1 );
//				DebugUtil.Trace( "create!! " + x + ", " + y + ", " + _table[ _rand ] + ", " + m_velocity );
			}
		}
	}*/

	
	/*************************************************************************************/
	/*	壁との判定関数群
	/*************************************************************************************/
	/*!
		@brief	壁との判定関数、大元
		@date	2016/3/24
	*/
	private function CheckHitWall()
	{
		var _mapPosX 	: Int 			= Std.int( x / GameCommon.ResSize );
		var _mapPosY 	: Int 			= Std.int( y / GameCommon.ResSize );
		
		// 判定を調べる順番。中央 → 中下 → 中上 → 中右 → 中左 → 右下 → 右上 → 左下 → 左上
		var _arrXY		: Array< Array< Int > >	=
					[ 
						[ _mapPosX	  ,	_mapPosY ],		[ _mapPosX	  ,	_mapPosY + 1 ],	[ _mapPosX , _mapPosY - 1 ],
						[ _mapPosX + 1, _mapPosY ],		[ _mapPosX - 1, _mapPosY ],
						[ _mapPosX + 1, _mapPosY + 1 ],	[ _mapPosX + 1, _mapPosY - 1 ],
						[ _mapPosX - 1, _mapPosY + 1 ],	[ _mapPosX - 1, _mapPosY - 1 ],
					];

		// マップのチェック
		{
			var _x : Int;
			var _y : Int;
						
			for ( i in 0..._arrXY.length ){
				_x = _arrXY[i][0];
				_y = _arrXY[i][1];
				
				// 検索場所がマップ範囲外にならば、チェックをしない
				if( _y < 0 || _y >= GameState.GetMapHeight() ||
					_x < 0 || _x >= GameState.GetMapWidth() )
				{
					continue;
				}
				
				// マップの種類を貰ってくる
				var _mapchip : Int = GameState.GetMapTile( _x, _y );
				
				// 判定する
				CheckHitWall_Proc( _mapchip, _x, _y );
				
				// 当たっていたら
				if ( m_fgHitWall ){
					// 跳ね返り回数が残っていたら、跳ね返る
					if ( m_refCnt > 0 ){
						Add( x + m_addPos.x + m_addHead.x, 
							 y + m_addPos.y + m_addHead.y,
							 m_nextDir, m_velocity, m_refCnt - 1 );
					}
					else{
						trace( "LimitRefrect" );
					}
					break;
				}
			}
		}
	}
	
	/*!
		@brief	判定の種類を細かい区分に分ける
		@date	2016/3/24
	*/
	private function CheckHitWall_Proc( _mapchip : Int, _x : Int, _y : Int )
	{
		var _fgHitWall : Bool = false;
		var _newPos : FlxPoint;

		// １フレ後に向かうポジション
		_newPos = new FlxPoint( x + m_addPos.x + m_addHead.x,  y + m_addPos.y + m_addHead.y );
		
		// 当たっているかを調べる。_newPosには補正値が返ってくる。
		switch( _mapchip ){
			case GameCommon.MapChip_None:	/*何もしない*/
			case GameCommon.MapChip_Normal:	_fgHitWall = CheckHitWall_Normal( _mapchip, _x, _y, _newPos );
			case GameCommon.MapChip_LT:		_fgHitWall = CheckHitWall_LT( _mapchip, _x, _y, _newPos );
			case GameCommon.MapChip_RT:		_fgHitWall = CheckHitWall_RT( _mapchip, _x, _y, _newPos );
			case GameCommon.MapChip_LB:		_fgHitWall = CheckHitWall_LB( _mapchip, _x, _y, _newPos );
			case GameCommon.MapChip_RB:		_fgHitWall = CheckHitWall_RB( _mapchip, _x, _y, _newPos );
			default:						/*何もしない*/
		}
		
		// 移動値を変更する
		if( _fgHitWall ){
			if( m_fgLenMax )	m_addPos.addPoint( _newPos );
			else				m_addHead.addPoint( _newPos );
			m_fgHitWall = true;
		}
	}
	
	/*!
		@brief	通常の壁と当たった場合
		@date	2016/3/24
	*/
	private function CheckHitWall_Normal( _mapchip : Int, _x : Int, _y : Int, _newPos : FlxPoint ) : Bool
	{
		var _brockSize 	: Float		= GameCommon.ResSize;
		var _oldPos		: FlxPoint	= new FlxPoint( x, y );
		var _brock		: FlxPoint 	= new FlxPoint( _x * _brockSize, _y * _brockSize );
		
		// 当たっているかどうか。
		{
			var _mapPosX	: Int = Std.int( _newPos.x / GameCommon.ResSize );
			var _mapPosY	: Int = Std.int( _newPos.y / GameCommon.ResSize );
			if( _mapPosX != _x || _mapPosY != _y ){
				// 当たっていないので、処理をやめる
				_newPos.set( 0, 0 );
				return false;
			}
		}

		// 補正値を算出
		if( _oldPos.x < _brock.x ){
			_newPos.set( _brock.x - _newPos.x - 0.1, 0 ); 
		}
		else if( _oldPos.x >= _brock.x + _brockSize ){
			_newPos.set( _brock.x + _brockSize - _newPos.x + 0.1, 0 );
		}
		else if( _oldPos.y < _brock.y ){
			_newPos.set( 0, _brock.y - _newPos.y - 0.1 );
		}
		else if( _oldPos.y >= _brock.y + _brockSize ){
			_newPos.set( 0, _brock.y + _brockSize - _newPos.y + 0.1 );
		}
		
		// 方向制御
		switch( m_dir ){
			case UP:	m_nextDir = DOWN;
			case DOWN:	m_nextDir = UP;
			case LEFT:	m_nextDir = RIGHT;
			case RIGHT:	m_nextDir = LEFT;
		}

		return true;
	}

	/*!
		@brief	左上が斜めの壁と当たった場合
		@date	2016/3/24
	*/
	private function CheckHitWall_LT( _mapchip : Int, _x : Int, _y : Int, _newPos : FlxPoint ) : Bool
	{
//		return CheckHitWall_Irregular( _mapchip, _x, _y, _newPos );
		
		var _brockSize 	: Float		= GameCommon.ResSize;
		var _oldPos		: FlxPoint	= new FlxPoint( x, y );
		var _brock		: FlxPoint 	= new FlxPoint( _x * _brockSize, _y * _brockSize );
		var _brockNew	: FlxPoint 	= new FlxPoint( _brock.x, _brock.y );
		var _fgHitIrregular : Bool	= false;
		
		// 当たっているかどうか。
		{
			var _mapPosNewX	: Int = Std.int( _oldPos.x / GameCommon.ResSize );
			var _mapPosNewY	: Int = Std.int( _oldPos.y / GameCommon.ResSize );
			var _mapPosOldX	: Int = Std.int( _newPos.x / GameCommon.ResSize );
			var _mapPosOldY	: Int = Std.int( _newPos.y / GameCommon.ResSize );
			
			if ( ( _mapPosOldX != _x || _mapPosOldY != _y ) && 
				 ( _mapPosNewX != _x || _mapPosNewY != _y ) )
			{
				// 当たっていないので、処理をやめる
				_newPos.set( 0, 0 );
				return false;
			}
			// 左上側の場合
			else if( _oldPos.x < _brock.x + _brockSize &&
					 _oldPos.y < _brock.y + _brockSize )
			{
				var _dif : FlxPoint = new FlxPoint( _newPos.x - _oldPos.x, _newPos.y - _oldPos.y );
				// 移動の少ないほうを採用して、ブロックの場所を求める。
				if( _dif.x * _dif.x < _dif.y * _dif.y ){
					// ブロックの形状を変更
					var _brockOfs : Float = _newPos.x - _brock.x;
					_brockNew.set( _newPos.x, _brock.y + ( _brockSize - _brockOfs ) );
				}
				else{
					// ブロックの形状を変更
					var _brockOfs : Float = _newPos.y - _brock.y;
					_brockNew.set( _brock.x + ( _brockSize - _brockOfs ), _newPos.y );
				}
				trace("Check0");
				
				// 変更後の状態で当たっているならば
				if( _newPos.x >= _brockNew.x &&
					_newPos.y >= _brockNew.y )
				{
					trace("Check2");
					trace( "brock:" + _brock.x, _brock.y );
					trace( "brockNew:" + _brockNew.x, _brockNew.y );
					trace( "oldpos:" + _oldPos.x, _oldPos.y );
					trace( "newpos:" + _newPos.x, _newPos.y );
					// 特殊当たりフラグを立てる。　いらない？
					_fgHitIrregular = true;
				}
				else{
					trace("Check1");
					trace( "brock:" + _brock.x, _brock.y );
					trace( "brockNew:" + _brockNew.x, _brockNew.y );
					trace( "oldpos:" + _oldPos.x, _oldPos.y );
					trace( "newpos:" + _newPos.x, _newPos.y );
					trace( " " );

					// 当たっていなければ、処理をやめる
					_newPos.set( 0, 0 );
					return false;
				}
			}
		}
		
		// 補正値を算出
		if ( _oldPos.x < _brockNew.x ){
			// ブロックの左側が接触
			_newPos.set( _brockNew.x - _newPos.x - 0.1, 0 ); 
		}
		else if( _oldPos.x > _brockNew.x + _brockSize ){
			// ブロックの右側が接触
			_newPos.set( _brockNew.x + _brockSize - _newPos.x + 0.1, 0 );
		}
		else if( _oldPos.y < _brockNew.y ){
			// ブロックの上側が接触
			_newPos.set( 0, _brockNew.y - _newPos.y - 0.1 );
		}
		else if( _oldPos.y > _brockNew.y + _brockSize ){
			// ブロックの下側が接触
			_newPos.set( 0, _brockNew.y + _brockSize - _newPos.y + 0.1 );
		}

		trace( "newNewpos:" + _newPos.x, _newPos.y );
		trace( " " );

		// 方向制御
		switch( m_dir ){
			case UP:	m_nextDir = DOWN;
			case DOWN:	m_nextDir = LEFT;
			case LEFT:	m_nextDir = RIGHT;
			case RIGHT:	m_nextDir = UP;
		}
		
		return true;
	}
	
	/*!
		@brief	右上が斜めの壁と当たった場合
		@date	2016/3/24
	*/
	private function CheckHitWall_RT( _mapchip : Int, _x : Int, _y : Int, _newPos : FlxPoint ) : Bool
	{
//		return CheckHitWall_Irregular( _mapchip, _x, _y, _newPos );
		
		var _brockSize 	: Float		= GameCommon.ResSize;
		var _oldPos		: FlxPoint	= new FlxPoint( x, y );
		var _brock		: FlxPoint 	= new FlxPoint( _x * _brockSize, _y * _brockSize );
		var _brockNew	: FlxPoint 	= new FlxPoint( _brock.x, _brock.y );
		var _fgHitIrregular : Bool	= false;
		
		// 当たっているかどうか。
		{
			var _mapPosNewX	: Int = Std.int( _oldPos.x / GameCommon.ResSize );
			var _mapPosNewY	: Int = Std.int( _oldPos.y / GameCommon.ResSize );
			var _mapPosOldX	: Int = Std.int( _newPos.x / GameCommon.ResSize );
			var _mapPosOldY	: Int = Std.int( _newPos.y / GameCommon.ResSize );
			
			if ( ( _mapPosOldX != _x || _mapPosOldY != _y ) && 
				 ( _mapPosNewX != _x || _mapPosNewY != _y ) )
			{
				// 当たっていないので、処理をやめる
				_newPos.set( 0, 0 );
				return false;
			}
			// 右上側の場合
			else if( _oldPos.x >= _brock.x &&
					 _oldPos.y < _brock.y + _brockSize )
			{
				var _dif : FlxPoint = new FlxPoint( _newPos.x - _oldPos.x, _newPos.y - _oldPos.y );
				// 移動の少ないほうを採用して、ブロックの場所を求める。
				if( _dif.x * _dif.x < _dif.y * _dif.y ){
					// ブロックの形状を変更
					var _brockOfs : Float = _newPos.x - _brock.x;
					_brockNew.set( _newPos.x - _brockSize, _brock.y + _brockOfs );
				}
				else{
					// ブロックの形状を変更
					var _brockOfs : Float = _newPos.y - _brock.y;
					_brockNew.set( _brock.x - ( _brockSize - _brockOfs ), _newPos.y );
				}
				trace("Check0");
				
				// 変更後の状態で当たっているならば
				if( _newPos.x <= _brockNew.x + _brockSize &&
					_newPos.y >= _brockNew.y )
				{
					trace("Check2");
					trace( "brock:" + _brock.x, _brock.y );
					trace( "brockNew:" + ( _brockNew.x + _brockSize ), _brockNew.y );
					trace( "oldpos:" + _oldPos.x, _oldPos.y );
					trace( "newpos:" + _newPos.x, _newPos.y );
					// 特殊当たりフラグを立てる。　いらない？
					_fgHitIrregular = true;
				}
				else{
					trace("Check1");
					trace( "brock:" + _brock.x, _brock.y );
					trace( "brockNew:" + ( _brockNew.x + _brockSize ), _brockNew.y );
					trace( "oldpos:" + _oldPos.x, _oldPos.y );
					trace( "newpos:" + _newPos.x, _newPos.y );
					trace( " " );

					// 当たっていなければ、処理をやめる
					_newPos.set( 0, 0 );
					return false;
				}
			}
		}
		
		// 補正値を算出
		if ( _oldPos.x < _brockNew.x ){
			trace( " Check003");
			// ブロックの左側が接触
			_newPos.set( _brockNew.x - _newPos.x - 0.1, 0 ); 
		}
		else if( _oldPos.x > _brockNew.x + _brockSize ){
			trace( " Check004");
			// ブロックの右側が接触
			_newPos.set( _brockNew.x + _brockSize - _newPos.x + 0.1, 0 );
		}
		else if ( _oldPos.y < _brockNew.y ){
			trace( " Check001");
			// ブロックの上側が接触
			_newPos.set( 0, _brockNew.y - _newPos.y - 0.1 );
		}
		else if( _oldPos.y > _brockNew.y + _brockSize ){
			trace( " Check002");
			// ブロックの下側が接触
			_newPos.set( 0, _brockNew.y + _brockSize - _newPos.y + 0.1 );
		}

		trace( "newNewpos:" + _newPos.x, _newPos.y );
		trace( " " );

		// 方向制御
		switch( m_dir ){
			case UP:	m_nextDir = DOWN;
			case DOWN:	m_nextDir = RIGHT;
			case LEFT:	m_nextDir = UP;
			case RIGHT:	m_nextDir = LEFT;
		}
		
		return true;
		
	}

	/*!
		@brief	左下が斜めの壁と当たった場合
		@date	2016/3/24
	*/
	private function CheckHitWall_LB( _mapchip : Int, _x : Int, _y : Int, _newPos : FlxPoint ) : Bool
	{
//		return CheckHitWall_Irregular( _mapchip, _x, _y, _newPos );
		
		var _brockSize 	: Float		= GameCommon.ResSize;
		var _oldPos		: FlxPoint	= new FlxPoint( x, y );
		var _brock		: FlxPoint 	= new FlxPoint( _x * _brockSize, _y * _brockSize );
		var _brockNew	: FlxPoint 	= new FlxPoint( _brock.x, _brock.y );
		var _fgHitIrregular : Bool	= false;
		
		// 当たっているかどうか。
		{
			var _mapPosNewX	: Int = Std.int( _oldPos.x / GameCommon.ResSize );
			var _mapPosNewY	: Int = Std.int( _oldPos.y / GameCommon.ResSize );
			var _mapPosOldX	: Int = Std.int( _newPos.x / GameCommon.ResSize );
			var _mapPosOldY	: Int = Std.int( _newPos.y / GameCommon.ResSize );
			
			if ( ( _mapPosOldX != _x || _mapPosOldY != _y ) && 
				 ( _mapPosNewX != _x || _mapPosNewY != _y ) )
			{
				// 当たっていないので、処理をやめる
				_newPos.set( 0, 0 );
				return false;
			}
			// 左下側の場合
			else if( _oldPos.x <= _brock.x + _brockSize &&
					 _oldPos.y > _brock.y )
			{
				var _dif : FlxPoint = new FlxPoint( _newPos.x - _oldPos.x, _newPos.y - _oldPos.y );
				// 移動の少ないほうを採用して、ブロックの場所を求める。
				if( _dif.x * _dif.x < _dif.y * _dif.y ){
					// ブロックの形状を変更
					var _brockOfs : Float = _newPos.x - _brock.x;
					_brockNew.set( _newPos.x - _brockSize, _brock.y - ( _brockSize - _brockOfs ) );
				}
				else{
					// ブロックの形状を変更
					var _brockOfs : Float = _newPos.y - _brock.y;
					_brockNew.set( _brock.x + _brockOfs, _newPos.y );
				}
				trace("Check0");
				
				// 変更後の状態で当たっているならば
				if( _newPos.x >= _brockNew.x &&
					_newPos.y <= _brockNew.y + _brockSize )
				{
					trace("Check2");
					trace( "brock:" + _brock.x, _brock.y );
					trace( "brockNew:" + ( _brockNew.x + _brockSize ), _brockNew.y );
					trace( "oldpos:" + _oldPos.x, _oldPos.y );
					trace( "newpos:" + _newPos.x, _newPos.y );
					// 特殊当たりフラグを立てる。　いらない？
					_fgHitIrregular = true;
				}
				else{
					trace("Check1");
					trace( "brock:" + _brock.x, _brock.y );
					trace( "brockNew:" + ( _brockNew.x + _brockSize ), _brockNew.y );
					trace( "oldpos:" + _oldPos.x, _oldPos.y );
					trace( "newpos:" + _newPos.x, _newPos.y );
					trace( " " );

					// 当たっていなければ、処理をやめる
					_newPos.set( 0, 0 );
					return false;
				}
			}
		}
		
		// 補正値を算出
		if ( _oldPos.x < _brockNew.x ){
			// ブロックの左側が接触
			_newPos.set( _brockNew.x - _newPos.x - 0.1, 0 ); 
		}
		else if( _oldPos.x > _brockNew.x + _brockSize ){
			// ブロックの右側が接触
			_newPos.set( _brockNew.x + _brockSize - _newPos.x + 0.1, 0 );
		}
		else if( _oldPos.y >= _brockNew.y + _brockSize ){
			// ブロックの下側が接触
			_newPos.set( 0, _brockNew.y + _brockSize - _newPos.y + 0.1 );
		}
		else if( _oldPos.y < _brockNew.y ){
			// ブロックの上側が接触
			_newPos.set( 0, _brockNew.y - _newPos.y - 0.1 );
		}

		trace( "newNewpos:" + _newPos.x, _newPos.y );
		trace( " " );

		// 方向制御
		switch( m_dir ){
			case UP:	m_nextDir = LEFT;
			case DOWN:	m_nextDir = UP;
			case LEFT:	m_nextDir = RIGHT;
			case RIGHT:	m_nextDir = DOWN;
		}
		
		return true;
	}

	/*!
		@brief	右下が斜めの壁と当たった場合
		@date	2016/3/24
	*/
	private function CheckHitWall_RB( _mapchip : Int, _x : Int, _y : Int, _newPos : FlxPoint ) : Bool
	{
//		return CheckHitWall_Irregular( _mapchip, _x, _y, _newPos );
		
		var _brockSize 	: Float		= GameCommon.ResSize;
		var _oldPos		: FlxPoint	= new FlxPoint( x, y );
		var _brock		: FlxPoint 	= new FlxPoint( _x * _brockSize, _y * _brockSize );
		var _brockNew	: FlxPoint 	= new FlxPoint( _brock.x, _brock.y );
		var _fgHitIrregular : Bool	= false;
		
		// 当たっているかどうか。
		{
			var _mapPosNewX	: Int = Std.int( _oldPos.x / GameCommon.ResSize );
			var _mapPosNewY	: Int = Std.int( _oldPos.y / GameCommon.ResSize );
			var _mapPosOldX	: Int = Std.int( _newPos.x / GameCommon.ResSize );
			var _mapPosOldY	: Int = Std.int( _newPos.y / GameCommon.ResSize );
			
			if ( ( _mapPosOldX != _x || _mapPosOldY != _y ) && 
				 ( _mapPosNewX != _x || _mapPosNewY != _y ) )
			{
				// 当たっていないので、処理をやめる
				_newPos.set( 0, 0 );
				return false;
			}
			// 右下側の場合
			else if( _oldPos.x > _brock.x &&
					 _oldPos.y > _brock.y )
			{
				var _dif : FlxPoint = new FlxPoint( _newPos.x - _oldPos.x, _newPos.y - _oldPos.y );
				// 移動の少ないほうを採用して、ブロックの場所を求める。
				if( _dif.x * _dif.x < _dif.y * _dif.y ){
					// ブロックの形状を変更
					var _brockOfs : Float = _newPos.x - _brock.x;
					_brockNew.set( _newPos.x - _brockSize, _brock.y - _brockOfs );
				}
				else{
					// ブロックの形状を変更
					var _brockOfs : Float = _newPos.y - _brock.y;
					_brockNew.set( _brock.x - _brockOfs, _newPos.y - _brockSize );
				}
				trace("Check0");
				
				// 変更後の状態で当たっているならば
				if( _newPos.x <= _brockNew.x + _brockSize &&
					_newPos.y <= _brockNew.y + _brockSize )
				{
					trace("Check2");
					trace( "brock:" + _brock.x, _brock.y );
					trace( "brockNew:" + ( _brockNew.x + _brockSize ), _brockNew.y );
					trace( "oldpos:" + _oldPos.x, _oldPos.y );
					trace( "newpos:" + _newPos.x, _newPos.y );
					// 特殊当たりフラグを立てる。　いらない？
					_fgHitIrregular = true;
				}
				else{
					trace("Check1");
					trace( "brock:" + _brock.x, _brock.y );
					trace( "brockNew:" + ( _brockNew.x + _brockSize ), _brockNew.y );
					trace( "oldpos:" + _oldPos.x, _oldPos.y );
					trace( "newpos:" + _newPos.x, _newPos.y );
					trace( " " );

					// 当たっていなければ、処理をやめる
					_newPos.set( 0, 0 );
					return false;
				}
			}
		}
		
		// 補正値を算出
		if ( _oldPos.x < _brockNew.x ){
			// ブロックの左側が接触
			_newPos.set( _brockNew.x - _newPos.x - 0.1, 0 ); 
		}
		else if( _oldPos.x > _brockNew.x + _brockSize ){
			// ブロックの右側が接触
			_newPos.set( _brockNew.x + _brockSize - _newPos.x + 0.1, 0 );
		}
		else if( _oldPos.y < _brockNew.y ){
			// ブロックの上側が接触
			_newPos.set( 0, _brockNew.y - _newPos.y - 0.1 );
		}
		else if( _oldPos.y > _brockNew.y + _brockSize ){
			// ブロックの下側が接触
			_newPos.set( 0, _brockNew.y + _brockSize - _newPos.y + 0.1 );
		}

		trace( "newNewpos:" + _newPos.x, _newPos.y );
		trace( " " );

		// 方向制御
		switch( m_dir ){
			case UP:	m_nextDir = RIGHT;
			case DOWN:	m_nextDir = UP;
			case LEFT:	m_nextDir = DOWN;
			case RIGHT:	m_nextDir = LEFT;
		}
		
		return true;
		
	}

	private function CheckHitWall_Irregular( _mapchip : Int, _x : Int, _y : Int, _newPos : FlxPoint ) : Bool
	{
		var _brockSize 	: Float		= GameCommon.ResSize;
		var _oldPos		: FlxPoint	= new FlxPoint( x, y );
		var _brock		: FlxPoint 	= new FlxPoint( _x * _brockSize, _y * _brockSize );
		var _brockNew	: FlxPoint 	= new FlxPoint( _brock.x, _brock.y );
		var _fgHitIrregular : Bool	= false;
		
		// 当たっているかどうか。
		{
			var _mapPosNewX	: Int = Std.int( _oldPos.x / GameCommon.ResSize );
			var _mapPosNewY	: Int = Std.int( _oldPos.y / GameCommon.ResSize );
			var _mapPosOldX	: Int = Std.int( _newPos.x / GameCommon.ResSize );
			var _mapPosOldY	: Int = Std.int( _newPos.y / GameCommon.ResSize );
			
			if ( ( _mapPosOldX != _x || _mapPosOldY != _y ) && 
				 ( _mapPosNewX != _x || _mapPosNewY != _y ) )
			{
				// 当たっていないので、処理をやめる
				_newPos.set( 0, 0 );
				return false;
			}
			else{
				var _fgCheck : Bool = CheckHitWall_Irregular_Dir( _mapchip, _oldPos, _newPos, _brock, _brockNew );
				if( !_fgCheck ){
					return false;
				}
				trace( "Check9" );
			}
		}
		
		trace( "Check10" );
		trace( "oldpos:" + _oldPos.x, _oldPos.y );
		trace( "newpos:" + _newPos.x, _newPos.y );
		trace( "brock:" + _brock.x, _brock.y );
		trace( "brockNew:" + _brockNew.x, _brockNew.y );
		
		// 補正値を算出
		if ( _oldPos.x < _brockNew.x ){
			// ブロックの左側が接触
			_newPos.set( _brockNew.x - _newPos.x - 0.1, 0 ); 
		}
		else if( _oldPos.x >= _brockNew.x + _brockSize ){
			// ブロックの右側が接触
			_newPos.set( _brockNew.x + _brockSize - _newPos.x + 0.1, 0 );
		}
		else if( _oldPos.y < _brockNew.y ){
			// ブロックの上側が接触
			_newPos.set( 0, _brockNew.y - _newPos.y - 0.1 );
		}
		else if( _oldPos.y >= _brockNew.y + _brockSize ){
			// ブロックの下側が接触
			_newPos.set( 0, _brockNew.y + _brockSize - _newPos.y + 0.1 );
		}

		trace( "newNewpos:" + _newPos.x, _newPos.y );
		trace( " " );

		switch( _mapchip ){
			// 左上の場合
			case AssetPaths.GameCommon.MapChip_LT:
				switch( m_dir ){
					case UP:	m_nextDir = DOWN;
					case DOWN:	m_nextDir = LEFT;
					case LEFT:	m_nextDir = RIGHT;
					case RIGHT:	m_nextDir = UP;
				}
				
			// 右上の場合
			case AssetPaths.GameCommon.MapChip_RT:
				switch( m_dir ){
					case UP:	m_nextDir = DOWN;
					case DOWN:	m_nextDir = RIGHT;
					case LEFT:	m_nextDir = UP;
					case RIGHT:	m_nextDir = LEFT;
				}
				
			// 左下の場合
			case AssetPaths.GameCommon.MapChip_LB:
				switch( m_dir ){
					case UP:	m_nextDir = LEFT;
					case DOWN:	m_nextDir = UP;
					case LEFT:	m_nextDir = RIGHT;
					case RIGHT:	m_nextDir = DOWN;
				}
				
			// 右下の場合
			case AssetPaths.GameCommon.MapChip_RB:
				switch( m_dir ){
					case UP:	m_nextDir = RIGHT;
					case DOWN:	m_nextDir = UP;
					case LEFT:	m_nextDir = DOWN;
					case RIGHT:	m_nextDir = LEFT;
				}
				
		}
		
		return true;
	}

	private function CheckHitWall_Irregular_Dir( _mapchip : Int, _oldPos : FlxPoint, _newPos : FlxPoint, _brock : FlxPoint, _brockNew : FlxPoint )
	{
		var _brockSize 	: Float		= GameCommon.ResSize;
		var _dif 		: FlxPoint = new FlxPoint( _newPos.x - _oldPos.x, _newPos.y - _oldPos.y );
		var _fgCheck 	: Bool = false;
		var _brockOfsX	: Float = _newPos.x - _brock.x;
		var _brockOfsY	: Float = _newPos.y - _brock.y;

		switch( _mapchip ){
			// 左上の場合
			case AssetPaths.GameCommon.MapChip_LT:
				if ( _oldPos.x < _brock.x + _brockSize &&
					 _oldPos.y < _brock.y + _brockSize )
				{
					_fgCheck = true;
				}
				
			// 右上の場合
			case AssetPaths.GameCommon.MapChip_RT:
				if ( _oldPos.x >= _brock.x &&
					 _oldPos.y < _brock.y + _brockSize )
				{
					_fgCheck = true;
				}
				
			// 左下の場合
			case AssetPaths.GameCommon.MapChip_LB:
				if ( _oldPos.x < _brock.x + _brockSize &&
					 _oldPos.y >= _brock.y )
				{
					_fgCheck = true;
				}
				
			// 右下の場合
			case AssetPaths.GameCommon.MapChip_RB:
				if ( _oldPos.x >= _brock.x &&
					 _oldPos.y >= _brock.y )
				{
					_fgCheck = true;
				}
		}
		
		// 一時チェック
		if( !_fgCheck ){
			return false;
		}
		
		var _dif : FlxPoint = new FlxPoint( _newPos.x - _oldPos.x, _newPos.y - _oldPos.y );
		
		// 移動の少ないほうを採用して、ブロックの場所を求める。
		// ｘのほうが短いので、ｘを元にｙを算出
		if( _dif.x * _dif.x < _dif.y * _dif.y ){
			var _brockOfs : Float = _newPos.x - _brock.x;
			switch( _mapchip ){
				// 左上の場合
				case AssetPaths.GameCommon.MapChip_LT:		_brockNew.set( _newPos.x, _brock.y + ( _brockSize - _brockOfs ) );
				// 右上の場合
				case AssetPaths.GameCommon.MapChip_RT:		_brockNew.set( _newPos.x - _brockSize, _brock.y + _brockOfs );
				// 左下の場合
				case AssetPaths.GameCommon.MapChip_LB:		_brockNew.set( _newPos.x, _brock.y + ( _brockOfs ) );
				// 右下の場合
				case AssetPaths.GameCommon.MapChip_RB:		_brockNew.set( _newPos.x, _brock.y + ( _brockSize - _brockOfs ) );
			}
		}
		// ｙのほうが短いので、ｙを元にｘを算出
		else{
			var _brockOfs : Float = _newPos.y - _brock.y;
			switch( _mapchip ){
				// 左上の場合
				case AssetPaths.GameCommon.MapChip_LT:		_brockNew.set( _brock.x + ( _brockSize - _brockOfs ), _newPos.y );
				// 右上の場合
				case AssetPaths.GameCommon.MapChip_RT:		_brockNew.set( _brock.x - ( _brockSize - _brockOfs ), _newPos.y );
				// 左下の場合
				case AssetPaths.GameCommon.MapChip_LB:		_brockNew.set( _brock.x + ( _brockOfs )				, _newPos.y );
				// 右下の場合
				case AssetPaths.GameCommon.MapChip_RB:		_brockNew.set( _brock.x + ( _brockSize - _brockOfs ), _newPos.y );
					
			}
		}
		
		_fgCheck = false;
		
		// 最終チェック
		switch( _mapchip ){
			// 左上の場合
			case AssetPaths.GameCommon.MapChip_LT:
				if( _newPos.x >= _brockNew.x &&
					_newPos.y >= _brockNew.y )
				{
					_fgCheck = true;
				}
			// 右上の場合
			case AssetPaths.GameCommon.MapChip_RT:
				// 変更後の状態で当たっているならば
				if( _newPos.x <= _brockNew.x + _brockSize &&
					_newPos.y >= _brockNew.y )
				{
					_fgCheck = true;
				}
			// 左下の場合
			case AssetPaths.GameCommon.MapChip_LB:
				if( _newPos.x >= _brockNew.x &&
					_newPos.y >= _brockNew.y )
				{
					_fgCheck = true;
				}
			// 右下の場合
			case AssetPaths.GameCommon.MapChip_RB:
				if( _newPos.x >= _brockNew.x &&
					_newPos.y >= _brockNew.y )
				{
					_fgCheck = true;
				}
				
		}
		// 変更後の状態で当たっているならば
		if( _fgCheck )
		{
/*			trace("Check2");
			trace( "brock:" + _brock.x, _brock.y );
			trace( "brockNew:" + _brockNew.x, _brockNew.y );
			trace( "oldpos:" + _oldPos.x, _oldPos.y );
			trace( "newpos:" + _newPos.x, _newPos.y );
*/
		}
		else{
/*			trace("Check1");
			trace( "brock:" + _brock.x, _brock.y );
			trace( "brockNew:" + _brockNew.x, _brockNew.y );
			trace( "oldpos:" + _oldPos.x, _oldPos.y );
			trace( "newpos:" + _newPos.x, _newPos.y );
			trace( " " );
*/
			// 当たっていなければ、処理をやめる
			_newPos.set( 0, 0 );
			return false;
		}
		
		return true;
	}
}
