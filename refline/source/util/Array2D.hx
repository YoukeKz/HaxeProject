package util;

/**
 * ...
 * @author Ando
 */

class Array2D {
	private var m_width 	: Int;
	private var m_height 	: Int;
	private var m_array		: Map< Int, Int >;
	private var m_err	 	: Int = 1;	// 初期化しない状態はエラー状態とする
	
	/*!
		@brief	コンストラクタ
		@date	2016/3/14
	*/
	public function new( _width : Int, _height : Int )
	{
		if ( _width < 0 || _height < 0 ){
			DebugUtil.Trace( "ArraySize_Is_Lower_Than_Zero" );
			m_err = 1;
			return;
		}
		m_width 	= _width;
		m_height	= _height;
		m_array 	= new Map();
		m_err		= 0;
	}
	/**
	 * publics
	 */

	/*!
		@brief	要素を取得する
		@date	2016/3/15
	*/
	public function GetOne( _width : Int, _height : Int ) : Int
	{
		if( !IsArraySize( _width, _height ) ){
			return -1;
		}
		
		var _idx : Int = GetIdx( _width, _height );
		return m_array[ _idx ];
	}
	
	/*!
		@brief	要素に入力する
		@date	2016/3/15
	*/
	public function SetOne( _val : Int, _width : Int, _height : Int )
	{
		if( !IsArraySize( _width, _height ) ){
			return;
		}
		
		var _Idx : Int = GetIdx( _width, _height );
		m_array[ _Idx ] = _val;
	}
	
	/**
	 * privates
	 */
	
	/*!
		@brief	どこかでエラーを起こしていたら、TRUEが返ってくる
		@date	2016/3/14
	*/
	private function IsError() : Bool
	{
		return ( m_err != 0 );
	}
	
	/*!
		@brief	配列外チェック
		@date	2016/3/14
	*/
	private function IsArraySize( _width : Int, _height : Int ) : Bool
	{
		if( _width 	>= m_width 	||
			_width 	< 0 		||
			_height >= m_height	||
			_height < 0			)
		{
			DebugUtil.Trace( "OutOfRange, m_w:" + m_width + ", m_h:" + m_height + ", _w:" + _width + ", _h:" + _height );
			return false;
		}
		return true;
	}
	
	/*!
		@brief	配列の番号を返す
		@date	2016/3/15
	*/
	private function GetIdx( _width : Int, _height : Int ) : Int
	{
		if( !IsArraySize( _width, _height ) ){
			m_err = 1;
			DebugUtil.Trace( "Invalid_Index, w:" + _width + ", h:" + _height );
			return 0;
		}
		return ( _width + _height * m_width );
	}
	
	
}

 