package com.imagame.engine 
{
	import com.imagame.game.PropManager;
	import flash.display.Sprite;
	import com.greensock.plugins.AutoAlphaPlugin;
	import com.greensock.TweenLite;
	import com.imagame.engine.ImaEngine;
	import com.imagame.engine.ImaPropManager;
	import com.imagame.engine.ImaTimerManager;
	import com.imagame.engine.Registry;
	import com.imagame.engine.ImaState;
	import com.imagame.game.Assets;
	import flash.display.StageQuality;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import flash.system.Capabilities;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.events.StageOrientationEvent;
	import flash.geom.Rectangle
	
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.StageOrientation;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import flash.system.System;

	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.TintPlugin;
	
//	import com.sticksports.nativeExtensions.SilentSwitch;
	import flash.media.SoundMixer;	//Required to to mute sounds if the hardware silent switch is on/off in iOS [IOS]
	import flash.media.AudioPlaybackMode; //Required to to mute sounds if the hardware silent switch is on/off in iOS [IOS]

	//Import ANE
//	import com.adobe.nativeExtensions.Vibration;
//	import so.cuo.anes.admob.Admob;
//	import so.cuo.anes.admob.AdSize;
//	import so.cuo.anes.admob.Admob;
	


	/**
	 * ImaGame Engine
	 * @author imagame
	 */
	public class ImaEngine extends Sprite
	{
		private var _state: ImaState;
		private static const GAME_DEFAULT_WIDTH: int = 480;
		private static const GAME_DEFAULT_HEIGHT: int = 320;
		
		protected var _totalTime:uint;        //Total number of milliseconds elapsed since game start. 
               
		
		public function ImaEngine(gpMgr: ImaPropManager):void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;	//No escala pero debe establecerse la propiedad <requestedDisplayResolution>standard</requestedDisplayResolution>
			stage.align = StageAlign.TOP_LEFT;
			//stage.quality = StageQuality.LOW; 
			//stage.quality = StageQuality.MEDIUM; //[ANDROID] con <renderMode>auto</renderMode>
			stage.quality = StageQuality.HIGH; //IOS
						
			// entry point
			if (CONFIG::debug == true) trace("Main-> AIR runtimeVersion:"+NativeApplication.nativeApplication.runtimeVersion);
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE; //Keep screen awake preventing entering in idle mode (ex. if you use accelerometer instead of touch)
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, AppActivate);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, AppDeactivate); //[iOS] Not reliable 100% . [ANDROID]HOME button =>  will always return the user to the Android desktop, thus deactivating our application 
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, AppExit);
			
			
			//[iOS]
			//NativeApplication.nativeApplication.executeInBackground = true; //[AIR3.3] Habilita estado BACKGROUND, o pasa a estado suspendido
			//NativeApplication.nativeApplication.addEventListener(Event.Event.SUSPEND, AppSuspended); //[AIR3.3]

			//[ANDROID]
			//Mobile Menu key
			//stage.addEventListener(KeyboardEvent.KEY_UP, onOptionsKey);  //or KEY_DOWN
			//TODO crear function onOptionsKey para controlar pulsación tecla Exit y forzar salida app
			//manejar event.keyCode == Keyboard.BACK, y keyboard.MENU
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, doKeyDown);
			
			//detect screen real resolution (forcing resize event)
			Registry.stage = stage;	
			
			stage.addEventListener(Event.RESIZE, onResize);
			stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGING, onChangingOrientation);
			onResize();
			detectDevice();
			detectScaleFactor();
						
			
			trace("cap= srx: " + Capabilities.screenResolutionX + " sry: " + Capabilities.screenResolutionY); //size of device entire screen
			trace("stage= fscrW: " + Registry.stage.fullScreenWidth + " fscrH: " + Registry.stage.fullScreenHeight); //size of screen
			trace("stage= sw: " + Registry.stage.stageWidth + " sh: " + Registry.stage.stageHeight); //size of swf file
			trace("game= w: " + Registry.gameRect.width + " h: " + Registry.gameRect.height); //size of swf file
			trace("appScale: " + Registry.appScale + "  offset[x,y]: " + Registry.appLeftOffset + "," + Registry.appUpOffset);
			
			// touch or gesture?
			if (Multitouch.supportsTouchEvents) {
				Registry.multitouchSupported = true;
				Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
				//Multitouch.inputMode = MultitouchInputMode.NONE;
			} else	
				Registry.multitouchSupported = false;
				
				
			_totalTime = getTimer();
			Registry.game = this;
			Registry.gpMgr = gpMgr;

			Registry.gpMgr.load(); 
			//[TEST]
			//(Registry.gpMgr as PropManager).setGameProgress([3,2,5,1,0,3,2,4,0,1]); 
			
	//		(Registry.gpMgr as PropManager).setGameProgress(0, 51, 51, [2, 3, 3, 3, 3, 3, 3, 3, 3]); //TEST only level1.3 to round 2
		//	(Registry.gpMgr as PropManager).setGameProgress(0, 51, 54+51, [2,3,3,3,3,3,3,3,3]); //TEST only level1.3 to round 3
			//(Registry.gpMgr as PropManager).setGameProgress(0, 0, 0, [0, 0, 0, 0, 0, 0, 0, 0, 0]); //TEST Reset
			//(Registry.gpMgr as PropManager).setGameProgress(0, 5, 5, [1, 1, 1, 1, 1, 0, 0, 0, 0]); //TEST Reset
			
			
			//Ad Manager
			if(Registry.bAd)
				Registry.adMgr = new ImaAdManager();
			
			Assets.prepareSounds();
			
			//[ANE][IOS] SilentSwitch
			//SilentSwitch.apply();	//[iOS] ANE to take into account sound swith
			SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT; //[IOS] mute sound if switch hwd is on
			
			
			//[ANE][IOS] Vibration
			/*
			if (Vibration.isSupported){
				var vb:Vibration=new Vibration();
				vb.vibrate(2000);
			}
			*/
			
			
			TweenPlugin.activate([TintPlugin]);
			TweenPlugin.activate([AutoAlphaPlugin]);
		}
		
		protected function start(state:ImaState):void {
			switchState(state);		
			state.pauseState();  //la app se va desactivar por el resize. Asegura que se conserve el sts/sbsts despues de la desactivación de la aplicación
			
			stage.addEventListener(Event.ENTER_FRAME, update);		
		}
		
		
		//********************************************************************* EVENT CONTROL
		
		//[ANDROID]
		private function doKeyDown(e:KeyboardEvent):void 
		{ 
			if (e.keyCode == Keyboard.BACK) { 
				e.preventDefault();
                e.stopImmediatePropagation();
				_state.backState();
			}
		}
		
		private function AppSuspended(e:Event):void {
			trace("MAIN >> AppSuspended");
			pauseGame();
		}
		
		/**
		 * Is this Application exit????????????????????? => save game state
		 * @param	e
		 */
		private function AppDeactivate(e:Event):void {
			trace("MAIN >> AppDeactivate");
			pauseGame();
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;						

		}
		
		/**
		 * Is this Application open????????????????????? => open game state
		 * @param	e
		 */
		private function AppActivate(e:Event):void {
			trace("MAIN >> AppActivate");
			resumeGame();
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;	
		}
		
		private function AppExit(e:Event):void {
			removeEventListener(Event.ENTER_FRAME, update);
			NativeApplication.nativeApplication.removeEventListener(Event.ACTIVATE, AppActivate);
			NativeApplication.nativeApplication.removeEventListener(Event.DEACTIVATE, AppDeactivate);
			NativeApplication.nativeApplication.removeEventListener(Event.EXITING, AppExit);
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
		}		
		
		
		
		
		/**
		 * Orientation management: Only supported Landscape orientation mode
		 * @param	e	StageOrientationEvent
		 */
		private function onChangingOrientation(e:StageOrientationEvent):void {
			if(e.afterOrientation == StageOrientation.DEFAULT ||
				e.afterOrientation == StageOrientation.UPSIDE_DOWN)
				e.preventDefault();
		}
		
		private function onResize(...ig) :void {
			trace("MAIN >> onResize");
			
			//Game scene fixed size (same for all device screen resolutions)
			Registry.gameDefaultRect = new Rectangle(0, 0, GAME_DEFAULT_WIDTH, GAME_DEFAULT_HEIGHT);
			
			//device size assuming landscape orientation
			/* fullscreeWidht / Height no da los valores ok
			var deviceRect:Rectangle = new Rectangle(0, 0,
				Math.max(stage.fullScreenWidth, stage.fullScreenHeight),
				Math.min(stage.fullScreenWidth, stage.fullScreenHeight));
			*/
			
			Registry.screenRect = new Rectangle(0, 0,
				Math.max(stage.stageWidth, stage.stageHeight),
				Math.min(stage.stageWidth, stage.stageHeight));	;
			
			Registry.deviceRect = new Rectangle(0, 0,
				Math.max(stage.fullScreenWidth, stage.fullScreenHeight),
				Math.min(stage.fullScreenWidth, stage.fullScreenHeight));
			
			//Desktop
			//TODO test with different devices 
			Registry.screenRect = Registry.deviceRect;		//Si desactivamos la igualdad entonces no hay zoom e iphone4 (screenRect: 640x320, y DevRect: 480x320)
			
			
			// adjust the gui to fit the new device 
			//trace("resize=> stage= sw: " + stage.stageWidth + " sh: " + stage.stageHeight); //size of swf file
			//trace("resize=> stage= fscrW: " + stage.fullScreenWidth + " fscrH: " + stage.fullScreenHeight); //size of screen
			trace("resize=> screenRect.w: " + Registry.screenRect.width + "  screenRect.h: " + Registry.screenRect.height);
			trace("resize=> deviceRect.w: " + Registry.deviceRect.width + "  deviceRect.h: " + Registry.deviceRect.height);
//			trace("resize=> stage= fsw: " + Registry.screenRect.width + " fsh: " + Registry.screenRect.height); //size of swf file
		}
		
		//************************************************************** DEVICE 
		
		private function detectDevice():void {
			var info:Array = Capabilities.os.split(" ");
			trace("Device-0: " + info[0]);
			trace("Device-1: " + info[1]);
			trace("Device-2: " + info[2]);

			Registry.biOS = Capabilities.manufacturer.indexOf("iOS") != -1;				
			Registry.dpi = getDeviceDPI();
			Registry.dpWide = Registry.deviceRect.width * 160 / Registry.dpi;
			Registry.inchesWide = Registry.deviceRect.width / Registry.dpi;
			
			Registry.setRange(); //Determines if the device is a low range device
		}
		
		private function detectScaleFactor():void {
			Registry.gameRect = Registry.gameDefaultRect.clone();
			// if device is wider than GUI's aspect ratio, height determines scale
			if ((Registry.screenRect.width/Registry.screenRect.height) > (Registry.gameDefaultRect.width/Registry.gameDefaultRect.height)) {
				Registry.appScale = Registry.screenRect.height / Registry.gameDefaultRect.height;
				trace("Registry.appScale: "+Registry.appScale+ " = Registry.screenRect.height: "+Registry.screenRect.height+"Registry.gameDefaultRect.height:"+Registry.gameDefaultRect.height);
				
				Registry.gameRect.width = Math.round(Registry.screenRect.width / Registry.appScale);
				Registry.appLeftOffset = Math.round((Registry.gameRect.width - Registry.gameDefaultRect.width) / 2);
				Registry.appUpOffset = 0;
			} 
			// if device is taller than GUI's aspect ratio, width determines scale
			else {
				Registry.appScale = Registry.screenRect.width / Registry.gameDefaultRect.width;
				Registry.gameRect.height = Math.round(Registry.screenRect.height / Registry.appScale);
				Registry.appUpOffset = Math.round((Registry.gameRect.height - Registry.gameDefaultRect.height) / 2);
				Registry.appLeftOffset = 0;
			}
		}
		
		private function getDeviceDPI():Number {
			var serverString:String = unescape(Capabilities.serverString);
			var reportedDpi:Number = Number(serverString.split("&DP=", 2)[1]);
			trace ("Server reported DPi: " + reportedDpi + " vs Capabilites.screenDPI: " + Capabilities.screenDPI);
			return Capabilities.screenDPI;
		}

		//**************************** APP LIFE CYCLE
		
	
		
		public function switchState(state: ImaState):void {
			if (_state != null) {
				//TweenLite.to(_state.canvas, 1, { tint:0xff9900 } );
				//TweenLite.to(_state.canvas, 1, {autoAlpha:0});
				_state.destroy();
				_state = null;
				System.gc();
			}
			_state = state;
			_state.create();
		}
		
		public function getState():ImaState {
			return _state;
		}
		
		private function pauseGame():void {
			//Enable pause mode in current state
			_state.pauseState();
			//TODO Remove any listener events, timers etc.
			
			//Save game state
			Registry.gpMgr.save();
		}
		
		
		private function resumeGame():void {
			//TODO restore game state
			//_initState.initSharedObject();
			_state.resumeState();
			
			//TODO Activate any listener events, timers etc.
			
			//game continues in pause mode till user resumes play state.
		}

		public function exitGame():void {
			NativeApplication.nativeApplication.exit(); 
		}

		public function getTotalTime():uint {
			return _totalTime;
		}

		private function update(e:Event):void {		
			var actTime:uint = getTimer(); 
			var elapsedTime:uint = actTime - _totalTime; 
			_totalTime = actTime; 		
			
			//ImaSoundMgr.updateSounds(); 
			Registry.elapsedTime = elapsedTime * 0.001;
			Registry.totalTime += Registry.elapsedTime;
			Registry.tMgr.update();
                        
			_state.update();
		}		
		
	}

}