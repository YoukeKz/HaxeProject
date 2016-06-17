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
	private	static var s_velocity 	: Float		= 0.5;
	private static var s_parent		: GameState	= null;
	private static var s_laserVel	: Float		= 8;
	private static var s_refrectCnt	: Int		= 100;
	
	//*************************/
	/* member values
	//*************************/
	private var m_bulletNum	: Int;
	private var m_dir		: E_PLYDIR;
	private var m_pos 		: FlxPoint;
	private var m_addPos 	: FlxPoint;
	private var m_size		: FlxPoint;
	private var m_dirImg	: Direction;
	
	private var m_collHosei	: FlxPoint;
	private var m_fgHitWall	: Bool;
	
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
	
	override public function destroy()
	{
		super.destroy();

		s_player = null;
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
		m_collHosei	= new FlxPoint();
		m_dirImg	= new Direction();
		m_dirImg.init();
		s_parent.add( m_dirImg );
		
		offset.set( AssetPaths.GameCommon.ResSize / 2, AssetPaths.GameCommon.ResSize / 2 );
	}
	
	private function init( _x : Int, _y : Int )
	{
		m_pos.set( _x, _y );
		m_addPos.set();
		m_size.set( 6, 6 );
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
			Refline.Add( null, m_pos.x, m_pos.y, m_dir, s_laserVel, s_refrectCnt );
		}
		if ( FlxG.keys.justPressed.SPACE ){
			trace( "SPACE" );
		}
		
		CheckHitWall();
		
		// ポジションの更新
		{
			m_pos.addPoint( m_addPos );
			m_pos.addPoint( m_collHosei );
			m_addPos.set();
			m_collHosei.set();
			
			setPosition( m_pos.x, m_pos.y );
		}
		
		m_dirImg.SetLocation( x, y, m_dir );
	}
	
	private function CallBack_HitWall()
	{
		
	}
	
	/*************************************************************************************/
	/*	壁との判定関数群
	/*************************************************************************************/
	/*!
		@brief	壁との判定関数、大元
		@date	2016/3/24
	*/
	private function CheckHitWall()
	{
		var _mapPosX 	: Int 			= Std.int( x / AssetPaths.GameCommon.ResSize );
		var _mapPosY 	: Int 			= Std.int( y / AssetPaths.GameCommon.ResSize );
		
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
				CheckHitWall_Main( _mapchip, _x, _y );
				
				// 当たっていたら
				if ( m_fgHitWall ){
					CallBack_HitWall();
					break;
				}
			}
		}
	}
	
	/*!
		@brief	判定の種類を細かい区分に分ける
		@date	2016/3/24
	*/
	private function CheckHitWall_Main( _mapchip : Int, _x : Int, _y : Int )
	{
		var _fgHitWallX	: Bool		= false;
		var _fgHitWallY	: Bool		= false;

		var _newPos		: FlxPoint	= new FlxPoint();
		var _collHosei	: FlxPoint	= new FlxPoint( m_collHosei.x, m_collHosei.y );
		
		// X軸の移動
		{
			// １フレ後に向かうポジション
			_newPos.set( x + _collHosei.x + m_addPos.x, y + _collHosei.y );
			
			// 当たっているかを調べる。_newPosには補正値が返ってくる。
			_fgHitWallX = CheckHitWall_CheckHit( _mapchip, _x, _y, _newPos, true );

			_collHosei.x += _newPos.x;
			_collHosei.y += _newPos.y;
		}
		
		{
			// １フレ後に向かうポジション
			_newPos.set( x + _collHosei.x + m_addPos.x, y + _collHosei.y + m_addPos.y );
			
			// 当たっているかを調べる。_newPosには補正値が返ってくる。
			_fgHitWallY = CheckHitWall_CheckHit( _mapchip, _x, _y, _newPos, false );
		}

		if( _fgHitWallX || _fgHitWallY ){
			m_fgHitWall = true;
			
			_collHosei.set( m_collHosei.x, m_collHosei.y );
			
			// X軸の移動
			{
				_newPos.set( x + m_collHosei.x + m_addPos.x, y + m_collHosei.y );
				
				// 当たっているかを調べる。_newPosには補正値が返ってくる。
				_fgHitWallX = CheckHitWall_CheckHit( _mapchip, _x, _y, _newPos, true );
			}
			
			// Y軸の移動
			{
				// １フレ後に向かうポジション
				_newPos.set( x + m_collHosei.x + m_addPos.x, y + m_collHosei.y + m_addPos.y );
				
				// 当たっているかを調べる。_newPosには補正値が返ってくる。
				_fgHitWallY = CheckHitWall_CheckHit( _mapchip, _x, _y, _newPos, false );
			}

			m_collHosei.x += _newPos.x;
			m_collHosei.y += _newPos.y;
		}
	}
	
	/*!
		@brief	通常の壁と当たった場合
		@date	2016/3/24
	*/
	private function CheckHitWall_CheckHit( _mapchip : Int, _x : Int, _y : Int, _newPos : FlxPoint, _fgX : Bool ) : Bool
	{
		var _brockSize 	: Float		= AssetPaths.GameCommon.ResSize;

		if( _mapchip <= AssetPaths.GameCommon.MapChip_None ||
			_mapchip >= AssetPaths.GameCommon.MapChip_Max )
		{
			return false;
		}
		
		var _oldPos		: FlxPoint	= new FlxPoint( x, y );
		var _brock		: FlxPoint 	= new FlxPoint( _x * _brockSize, _y * _brockSize );
		var _brockNew	: FlxPoint 	= new FlxPoint( _brock.x, _brock.y );
		var _fgHitIrregular : Bool	= false;
		var _sizeX		: Float		= m_size.x / 2;
		var _sizeY		: Float		= m_size.y / 2;
		
		// 当たっているかどうか。
		{
			var _fgHitX : Bool = false;
			var _fgHitY : Bool = false;
			
			// 現在位置Xがそのマスにめり込んでいるかどうか。
			if( _oldPos.x + _sizeX >= _brockNew.x &&
				_oldPos.x - _sizeX < _brockNew.x + _brockSize )
			{
				_fgHitX = true;
			}
			// 未来位置Xがそのマスにめり込んでいるかどうか。
			else if( _newPos.x + _sizeX >= _brockNew.x &&
					 _newPos.x - _sizeX < _brockNew.x + _brockSize )
			{
				_fgHitX = true;
			}
			
			// 現在位置Yがそのマスにめり込んでいるかどうか。
			if( _oldPos.y + _sizeY >= _brockNew.y &&
				_oldPos.y - _sizeY < _brockNew.y + _brockSize )
			{
				_fgHitY = true;
			}
			// 未来位置Yがそのマスにめり込んでいるかどうか。
			else if( _newPos.y + _sizeY >= _brockNew.y &&
					 _newPos.y - _sizeY < _brockNew.y + _brockSize )
			{
				_fgHitY = true;
			}
			
			if( _fgHitX && _fgHitY ){
				
			}
			else{
				// 当たっていないので、処理をやめる
				_newPos.set( 0, 0 );
				return false;
			}
		}

		if( _fgX ){
			// 補正値を算出
			CheckHitWall_GetHoseiX( _oldPos, _newPos, _brockNew );
			
		}
		else{
			// 補正値を算出
			CheckHitWall_GetHoseiY( _oldPos, _newPos, _brockNew );
		}
		
		// 方向制御
		CheckHitWall_SetNextDir( _mapchip );
		
		return true;
	}

	private function CheckHitWall_GetHoseiX( _oldPos : FlxPoint, _newPos : FlxPoint, _brockNew : FlxPoint ) 
	{
		var _brockSize 	: Float		= AssetPaths.GameCommon.ResSize;
		var _sizeX		: Float		= m_size.x / 2;
		var _sizeY		: Float		= m_size.y / 2;
		
		// 補正値を算出
		if ( _oldPos.x + _sizeX > _brockNew.x ){
			// ブロックの左側が接触
			_newPos.set( _brockNew.x - _newPos.x - _sizeX, 0 ); 
		}
		else if( _oldPos.x - _sizeX >= _brockNew.x + _brockSize ){
			// ブロックの右側が接触
			_newPos.set( _brockNew.x + _brockSize - _newPos.x + _sizeX, 0 );
		}
	}
	private function CheckHitWall_GetHoseiY( _oldPos : FlxPoint, _newPos : FlxPoint, _brockNew : FlxPoint ) 
	{
		var _brockSize 	: Float		= AssetPaths.GameCommon.ResSize;
		var _sizeX		: Float		= m_size.x / 2;
		var _sizeY		: Float		= m_size.y / 2;
		
		if( _oldPos.y + _sizeY < _brockNew.y ){
			// ブロックの上側が接触
			_newPos.set( 0, _brockNew.y - _newPos.y - _sizeY );
		}
		else if( _oldPos.y - _sizeY >= _brockNew.y + _brockSize ){
			// ブロックの下側が接触
			_newPos.set( 0, _brockNew.y + _brockSize - _newPos.y + _sizeY );
		}
	}

	private function CheckHitWall_Irregular( _mapchip : Int, _oldPos : FlxPoint, _newPos : FlxPoint, _brock : FlxPoint, _brockNew : FlxPoint ) : Bool
	{
		// チェックフラグ。最初の項目にHitしなかったら、そのまま処理が通る
		var _fgCheck	: Bool 		= true;
		var _dif 		: FlxPoint	= new FlxPoint( _newPos.x - _oldPos.x, _newPos.y - _oldPos.y );
		var _brockSize 	: Float		= AssetPaths.GameCommon.ResSize;
		
		// 特殊な判定が必要かどうか。　必要な場合はチェックフラグを下げて、細かい判定を行なう。
		switch( _mapchip ){
			// マップチップが左上で、前回位置も左上の場合
			case AssetPaths.GameCommon.MapChip_LT:		if ( _oldPos.x <  _brock.x + _brockSize	&& _oldPos.y < _brock.y + _brockSize )	_fgCheck = false;
			// マップチップが右上で、前回位置も右上の場合
			case AssetPaths.GameCommon.MapChip_RT:		if( _oldPos.x >= _brock.x				&& _oldPos.y < _brock.y + _brockSize )	_fgCheck = false;
			// マップチップが左下で、前回位置も左下の場合
			case AssetPaths.GameCommon.MapChip_LB:		if( _oldPos.x <= _brock.x + _brockSize	&& _oldPos.y > _brock.y )				_fgCheck = false;
			// マップチップが右下で、前回位置も右下の場合
			case AssetPaths.GameCommon.MapChip_RB:		if( _oldPos.x >  _brock.x 				&& _oldPos.y > _brock.y )				_fgCheck = false;
			// その他、ここにはこないはず
			default:	trace( "WrongMapchip" );
		}

		// 検査に引っかかったら、再検査に行かないとダメなんですよ。
		if ( !_fgCheck ){
			_fgCheck = CheckHitWall_Irregular_Dir( _mapchip, _oldPos, _newPos, _brock, _brockNew );
		}
		
		return _fgCheck;
	}

	private function CheckHitWall_Irregular_Dir( _mapchip : Int, _oldPos : FlxPoint, _newPos : FlxPoint, _brock : FlxPoint, _brockNew : FlxPoint ) : Bool
	{
		// 前回と今回の移動差
		var _dif		: FlxPoint	= new FlxPoint( _newPos.x - _oldPos.x, _newPos.y - _oldPos.y );
		var _brockOfs	: FlxPoint	= new FlxPoint( _newPos.x - _brock.x, _newPos.y - _brock.y );
		var _brockSize 	: Float		= AssetPaths.GameCommon.ResSize;
		var _fgCheck	: Bool		= false;
		var _fgCheckX	: Bool 		= ( _dif.x * _dif.x < _dif.y * _dif.y );
		
		switch( _mapchip ){
			case AssetPaths.GameCommon.MapChip_LT:
				// 移動の少ないほうを採用して、ブロックの場所を求める。
				if ( _fgCheckX )	_brockNew.set( _brock.x, _brock.y + ( _brockSize - _brockOfs.x ) );
				else				_brockNew.set( _brock.x + ( _brockSize - _brockOfs.y ), _brock.y );
				
				// 変更後の状態で当たっているならば
				if( _newPos.x >= _brockNew.x &&
					_newPos.y >= _brockNew.y )
				{
					_fgCheck = true;
				}

			case AssetPaths.GameCommon.MapChip_RT:
				// 移動の少ないほうを採用して、ブロックの場所を求める。
				if ( _fgCheckX )	_brockNew.set( _brock.x, _brock.y + _brockOfs.x );
				else				_brockNew.set( _brock.x - ( _brockSize - _brockOfs.y ), _brock.y );
				
				// 変更後の状態で当たっているならば
				if( _newPos.x <= _brockNew.x + _brockSize &&
					_newPos.y >= _brockNew.y )
				{
					_fgCheck = true;
				}
				
			case AssetPaths.GameCommon.MapChip_LB:
				// 移動の少ないほうを採用して、ブロックの場所を求める。
				if ( _fgCheckX )	_brockNew.set( _brock.x, _brock.y - ( _brockSize - _brockOfs.x ) );
				else				_brockNew.set( _brock.x + _brockOfs.y, _brock.y );
				
				// 変更後の状態で当たっているならば
				if( _newPos.x >= _brockNew.x &&
					_newPos.y <= _brockNew.y + _brockSize )
				{
					_fgCheck = true;
				}
				
			case AssetPaths.GameCommon.MapChip_RB:
				// 移動の少ないほうを採用して、ブロックの場所を求める。
				if ( _fgCheckX )	_brockNew.set( _brock.x, _brock.y - _brockOfs.x );
				else				_brockNew.set( _brock.x - _brockOfs.y, _brock.y );

				// 変更後の状態で当たっているならば
				if( _newPos.x <= _brockNew.x + _brockSize &&
					_newPos.y <= _brockNew.y + _brockSize )
				{
					_fgCheck = true;
				}
				
			default: // 何もしない
		}
		
		return _fgCheck;
	}	

	private function CheckHitWall_SetNextDir( _mapChip : Int )
	{
	}
}