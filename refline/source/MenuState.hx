package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import util.DebugUtil;

class MenuState extends FlxState
{
	private var m_group : FlxGroup;
	private var m_clock : Int;
	
	override public function create():Void
	{
		super.create();
		
		m_clock = 0;
		m_group = new FlxGroup(2);
		
		// タイトル描画
		{
			var _titleLen 	: Int = 5;
			var _chsz 		: Int = 60;
			var _title 		: FlxText = new FlxText( ( FlxG.width - _titleLen * _chsz / 1.7 ) / 2, 
													FlxG.height / 6, 
													0, "title", _chsz );
			add( _title );
		}

		// テキスト描画
		{
			var _textLen 	: Int = 11;
			var _chsz 		: Int = 30;
			var _text		: FlxText = new FlxText( ( FlxG.width - _textLen * _chsz / 1.5 ) / 2, 
													FlxG.height * 2 / 3, 
													0, "Press Enter", _chsz );
			m_group.add( _text );
		}
		
		add( m_group );
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		m_clock++;
		if ( m_clock >= 30 ){
			m_clock = 0;
		}
		else if( m_clock > 25 ){
			m_group.set_visible( false );
		}
		else{
			m_group.set_visible( true );
		}
		
		// 次のステートへ移る
		if ( FlxG.keys.justPressed.ENTER ){
			FlxG.switchState( new PlayState() );
		}
		
	}
}
