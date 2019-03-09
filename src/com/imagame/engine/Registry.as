package com.imagame.engine 
{
	import com.imagame.game.Assets;
	import flash.display.Bitmap;
	import flash.display.Stage;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author imagame
	 */

	 public class Registry
	{
		//Versions
		static public var biOS:Boolean; //True if device is iOS 
		//[iOS]
		static public var IMAENGINE_VERSION: String = "1.1";
		static public var GAME_VERSION: String = "1.1.0"; //[iOS] version con publicidad
		
		//[ANDROID]
		//static public var IMAENGINE_VERSION: String = "1.1"; //1.1 - Initial version for Vowel Toys
		//static public var GAME_VERSION: String = "1.1.0"; //[ANDROID]	

		
		//Environment
		static public var game: ImaEngine;
		static public var stage: Stage;
		static public var multitouchSupported: Boolean;
		
		//App Settings
		static public var bSnd: Boolean = true;		//Sound enabled
		static public var bFx: Boolean = true;		//Graphics effects enabled
		static public var bTween: Boolean = true;	//Tweening activated
		static public var bAd: Boolean = false;		//Advertising support
		static public var bLowRange: Boolean = false;	//Low Range Device 
		
		//GUI and screen
		static public var screenRect: Rectangle;	//play stage size
		static public var deviceRect: Rectangle;	//device total size (including os menu bar,...)
		static public var dpi: Number;	//dpi
		static public var dpWide: Number; //density-independent pixels (dp): normalized pixel unit for defining resolution compared to a 160 dpi screen
		static public var inchesWide:Number; //screen wide in inches
	
		static public var gameDefaultRect: Rectangle;	//Default game scene size (NOT SCALED) - independent on device screen resolutions). 
		static public var gameRect: Rectangle;		//Extended game scene size (NOT SCALED) to adjust to X or y resolutionv 
		static public var appScale: Number;	
		static public var appLeftOffset: int; // >0 if baseExtendW > 0  (LOW RES)
		static public var appUpOffset: int;	// >0 if baseExtendH > 0  (LOW RES)
		//static public var gameExtScaleRect: Rectangle
		
		static public var baseExtendW: int;
		static public var baseExtendH: int; 
				
		//Game Properties
		static public var totalTime: Number;	//Total effective (not paused) game time
		static public var elapsedTime:Number; 	//elapsed Time in seconds

		
		//Managers
		static public var tMgr: ImaTimerManager = new ImaTimerManager();
		static public var gpMgr: ImaPropManager;
		static public var adMgr: ImaAdManager;
		//static public var lMgr: LevelManager = new LevelManager();

		
		/**
		 * Adjust a Global Rectangle (with positions in extended game scene size -gameRect-) to a local Rectangle (in gameDefaulRect)
		 * @param	r	Rectangle in extended game scene <gameRect>
		 */
		public static function gameRect2gameDefaultRect(r: Rectangle):void {
			//adjust if game rect extended horizontally
			if (appLeftOffset > 0) {
				r.x -= appLeftOffset;
				//adjust left x
				if (r.x < 0 && (r.width + r.x > 0)){
						r.width += r.x;
						r.x = 0;
				}
				//adjust right x
				if (r.x + r.width > gameDefaultRect.width) {
					r.width = gameDefaultRect.width - r.x;
				}
			}
				
			//adjust if game rect extended vertically
			if (appUpOffset > 0) {
				r.y -= appUpOffset;
				//adjust up y
				if (r.y < 0 && (r.height + r.y > 0)){
						r.height += r.y;
						r.y = 0;
				}
				//adjust bottom y
				if (r.y + r.height > gameDefaultRect.height) {
					r.height = gameDefaultRect.height - r.y;
				}	
			}
		}

		/**
		 * Determines the device range
		 */
		public static function setRange(): void {
			if (biOS)
				bLowRange = false;
			else {
				if (deviceRect.width <= 320 || deviceRect.height <= 320)
					bLowRange = true;
				else	
					bLowRange = false;
			}
		}		
	}

}