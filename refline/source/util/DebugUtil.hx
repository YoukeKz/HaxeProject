package util;
import flixel.FlxObject;

/**
 * ...
 * @author Ando
 */

/*!
	@brief	デバッグに使用する関数
	@date	2016/3/14
*/
class DebugUtil{
	// デバッグモードを使用する場合は m_debug に 0 以外を入れる
	private static var m_debug : Int = 1;
	
	/*!
		@brief	テキスト出力します。
		@date	2016/3/14
	*/
	public static function Trace( _msg : String )
	{
		if( m_debug != 0 ){
			trace( _msg );
		}
	}
	
	/*!
		@brief	止まらないけど、アサートのつもり
		@date	2016/3/15
	*/
	public static function Assert( _fg : Bool, _msg : String )
	{
		if ( m_debug != 0 ){
			if( !_fg ){
				trace( _msg );
			}
		}
	}
	
}