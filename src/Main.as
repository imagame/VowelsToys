package 
{
	import com.imagame.engine.ImaEngine;
	import com.imagame.game.MenuState;
	//import com.imagame.game.MenuState;
	import com.imagame.game.GameLevel1;
	import com.imagame.game.PropManager;
	
	/**
	 * Vowels Toys main class
	 * @author imagame
	 */
	[SWF(frameRate = "40", width = "480", height = "320",  backgroundColor = "#000000" )]
	public class Main extends ImaEngine 
	{
		
		public function Main():void 
		{
			super(new PropManager("vowelstoys"));
			start(new MenuState(0));
			//start(new GameLevel1(0,0,1));
		}
		

	}
	
}