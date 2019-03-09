package com.imagame.engine 
{
	import com.greensock.TweenLite;
	import flash.desktop.NativeApplication;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.ui.Keyboard;
	
	import net.hires.debug.MovieMonitor;
	
	/**
	 * ...
	 * @author imagame
	 */
	public class ImaState 
	{
		protected var _id: uint; //state id: free use 
		protected var _sts: uint; //state 
		protected var _sbsts: uint;        //substate 
		protected var _stsOld: uint;		//state before pause
		protected var _sbstsOld: uint;		//substate before pause
		
		protected var _container: Sprite; 
		protected var _bkg:ImaBackground	//Background: to be add to _container in a subclass
		//protected var _dbgSpr:Sprite; 		//[DEBUG] Sprite for graphical debugging info
		protected var _dbgGfx:Graphics; 
		
		public static const STS_PLAY: uint = 0;
		public static const STS_INIT: uint = 1;
		public static const STS_END: uint = 2;
		public static const STS_PAUSE: uint = 3;
		public static const STS_KILLED: uint = 4;
		
		public static const SBSTS_INIT:uint = 0;
		public static const SBSTS_CONT:uint = 1;
		public static const SBSTS_END:uint = 2;	
		
		
		//[DEBUG]
		/*
		private var _movieMonitor: MovieMonitor;
		private var _imaLog: ImaLog;
		*/
		
		public function ImaState(id: uint) 
		{ 
			trace("IMASTATE >> ImaState()"); 
			_id = id; 			//TODO Compatibilizar control ratón con touch
			
			if(! Registry.multitouchSupported) {
				Registry.stage.addEventListener(MouseEvent.MOUSE_DOWN, doMouseDown);
				Registry.stage.addEventListener(MouseEvent.MOUSE_UP, doMouseUp );
				//Registry.stage.addEventListener(MouseEvent.MOUSE_MOVE, doMouseMove);
				Registry.stage.addEventListener(Event.MOUSE_LEAVE, doMouseLeave);
			}
			else {
				Registry.stage.addEventListener(TouchEvent.TOUCH_BEGIN, doTouchBegin);
				Registry.stage.addEventListener(TouchEvent.TOUCH_END, doTouchEnd);
				Registry.stage.addEventListener(TouchEvent.TOUCH_ROLL_OUT, doTouchRollOut);
				Registry.stage.addEventListener(TouchEvent.TOUCH_MOVE, doTouchMove);
				//Registry.stage.addEventListener(TouchEvent.TOUCH_TAP
			}
			
			// import flash.events.KeyboardEvent; import flash.ui.Keyboard;
			
						
			_container = new Sprite();
			//_container.cacheAsBitmap = true;  //OJO!!Comentar->si no provoca saltos
			//_container.cacheAsBitmapMatrix = new Matrix();
			
			//[TEST]
			//_container.scaleX = _container.scaleY = 1
			_container.scaleX = _container.scaleY = Registry.appScale;
			Registry.stage.addChild(_container);
			_container.x = _container.y = 0;
			_container.visible = false;

			
			//[DEBUG] Create Monitor
			/*
			_movieMonitor  = new MovieMonitor();
			Registry.stage.addChild(_movieMonitor);
			_movieMonitor.visible = true;
			_movieMonitor.y = Registry.gameRect.height - _movieMonitor.height;
			*/
			
/*			_imaLog = new ImaLog();
			Registry.stage.addChild(_imaLog);
	*/		
		
	/*
			//[DEBUG] Create debug sprite
			_dbgSpr = new Sprite(); 
			//_dbgGfx = _dbgSpr.graphics; 
			_dbgSpr.scaleX = _dbgSpr.scaleY = Registry.appScale;
			Registry.stage.addChild(_dbgSpr);
		*/	
			_sts = _stsOld = STS_INIT;
			_sbsts = _sbstsOld = SBSTS_INIT;
		}

		public function get id():uint {
			return _id;
		}		
		//********************************************* Control handlers
		
		protected function doMouseDown(e:MouseEvent):void { }
		protected function doMouseUp(e:MouseEvent):void { }
		protected function doMouseMove(e:MouseEvent):void { 
			trace("mouse back on stage");
			Registry.stage.removeEventListener(MouseEvent.MOUSE_MOVE, doMouseMove); 
		}
			
		protected function doMouseLeave(e:Event):void { 
			trace("Mouse Leaveeeeeeeeeeeeeeeeeeeeeeeee"); 
			Registry.stage.addEventListener(MouseEvent.MOUSE_MOVE, doMouseMove);
		}
		
		protected function doTouchBegin(e:TouchEvent):void { }
		protected function doTouchEnd(e:TouchEvent):void { }
		protected function doTouchRollOut(e:TouchEvent):void {}
		protected function doTouchMove(e:TouchEvent):void {}

		//Mouse drag & drop
		/*
		    spritexxx.addEventListener(MouseEvent.MOUSE_DOWN, onDrag);
			stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
				 
				 
       
			function onDrag(evt:MouseEvent):void {
				var w:Number = evt.currentTarget.width;
				var h:Number = evt.currentTarget.height;
				evt.currentTarget.startDrag(false, new Rectangle(0,0,400 - w, 400 - h));
			}
			
			function onUp(evt:MouseEvent):void{ 
				stopDrag() 
			}

		 */
		
	
		// override this
		public function create():void
		{
			trace("ImaState->create()");
			
			//Create debug sprite
			/*
			_dbgSpr = new Sprite(); 
			_dbgGfx = _dbgSpr.graphics; 
			_container.addChild(_dbgSpr); 
			*/
			
			//TODO start state timer
			
			//Tween: State content fade-in
			
			_container.visible = true;	
			if(Registry.bTween){
				_container.alpha = 0;
				TweenLite.to(_container, 1, { alpha:1 } ); 
			}
			
			//_sts = STS_PLAY;
			//Cambio: Engine 1.1 //En lugar de cambiar a estado directamente a STS_PLAY se cambia subestado cont, y en el update se cambia a PLAY, solo si la clase que extiende ImaState se responsabiliza de cambiar a sbsts END
			_sts = STS_INIT;
			_sbsts = SBSTS_CONT;
		}

		
		// override this
		public function destroy():void
		{			
			trace("ImaState->destroy()");
			
			
			//remove listeners
			Registry.stage.removeEventListener(MouseEvent.MOUSE_DOWN, doMouseDown);
			Registry.stage.removeEventListener(MouseEvent.MOUSE_UP, doMouseUp );
			Registry.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, doTouchBegin);
			Registry.stage.removeEventListener(TouchEvent.TOUCH_END, doTouchEnd);
			Registry.stage.removeEventListener(TouchEvent.TOUCH_ROLL_OUT, doTouchRollOut);
			Registry.stage.removeEventListener(TouchEvent.TOUCH_MOVE, doTouchMove);
			
			

			//_dbgGfx = null;
			_bkg.destroy();
			_bkg = null;
			
			Registry.stage.removeChild(_container);
			_container = null;
			
			//[DEBUG]
			/*
			if(_movieMonitor != null) {
				Registry.stage.removeChild(_movieMonitor);
				_movieMonitor = null;
			}
			if(_imaLog != null) {
				Registry.stage.removeChild(_imaLog);
				_imaLog = null;
			}
			if (_dbgSpr != null) {
				Registry.stage.removeChild(_dbgSpr);
				_dbgSpr = null;
			}
			*/
			
		}
		
		public function canvas():Sprite {
			return _container;
		}
		//[DEBUG]
		/*
		public function dbgCanvas():Sprite {
			return _dbgSpr;
		}
		*/
		
		public function get background():ImaBackground {
			return _bkg;
		}
		public function get sts():uint {
			return _sts;
		}
		public function get sbSts():uint {
			return _sbsts;
		}
		
		//override this
		public function pauseState():void {
			_stsOld = _sts;
			_sbstsOld = _sbsts;
			_sts = STS_PAUSE;
		}
		
		//override this
		public function resumeState():void {
			_sts = _stsOld;
			_sbsts = _sbstsOld;
		}
		
		//override this
		public function backState():void {
			
		}
		
		// override this
		public function update():void
		{
			if (_sts == STS_INIT) {
				if (_sbsts == SBSTS_END) {
					_sts = STS_PLAY;
					_sbsts = SBSTS_INIT;
				}
			}
		}
		
	}

}