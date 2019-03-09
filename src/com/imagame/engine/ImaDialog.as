package com.imagame.engine 
{ 
	import com.greensock.easing.Bounce;
	import com.greensock.TweenLite;
	import com.imagame.fx.ImaFx;
	import com.imagame.game.Assets; 
	import com.imagame.utils.ImaBitmapSheet;
	import com.imagame.utils.ImaCachedBitmap; 
	import flash.display.Bitmap;
	import flash.display.Sprite; 
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import org.osflash.signals.Signal;
	/** 
	 * ... 
	 * @author imagame 
	 */ 
	public class ImaDialog extends ImaSprite 
	{ 
		protected var _parent: ImaState;
		protected var _btMenu: ImaButton;        //Button Back to Menue 
		protected var _btRepeat: ImaButton;        //Button Repeat level 
		protected var _btNext: ImaButton;        //Button Next level 

		protected var _sprContainer: Sprite;    //Sprite container: contains the dialog icon frame                
		protected var _containerTimer: ImaTimer;        //Timer 
		protected var _sprFrmIcon: Sprite; 
		protected var _sprIcon: ImaSpriteAnim;  

		protected var _aGfx: Array = [Assets.GfxDlg0, Assets.GfxFxFrmIconDlg, Assets.GfxButtonsDlg]; //Default graphics
		protected var _gfxBtW: uint = Assets.BUTTON_DLG_WIDTH; 
		protected var _gfxBtH: uint = Assets.BUTTON_DLG_HEIGHT; 
		
		public var signalClick: Signal; 
		
		/** 
		*        Creates a dialog showing the graphic <id> from the tilesheet <ts>, and showing buttons 
		*        @param id        tile id in iconTs 
		*        @param iconTs        Tilesheet containing icons for the dialog 
		*/ 
		public function ImaDialog(id:uint, parentRef:ImaState, iconTs: ImaBitmapSheet, aBt: Array, aGfx: Array=null, bw: uint=0, bh:uint=0) 
		{ 
			super(TYPE_DLG, id); 
			_parent = parentRef;
			visible = false;			

			//replace default graphics
			if(aGfx != null) {
				for (var i:uint = 0; i < _aGfx.length; i++)
					if (aGfx[i] != null)
						_aGfx[i] = aGfx[i];
			}
			
			//create Dialog background and center in screen 
			_bmp = ImaCachedBitmap.instance.createBitmap(_aGfx[0]); 
			x = (uint)((Registry.gameRect.width - _bmp.width)* 0.5); 
			y = (uint)((Registry.gameRect.height - _bmp.height)* 0.5);                                 
			addChild(_bmp); 

			//Create Icon container, center horizontally in dialog, and center-32px vertically
			_sprContainer = new Sprite();        //position in centre of dialog 
			_sprContainer.x = (uint) (_bmp.x  + _bmp.width * 0.5); 
			_sprContainer.y = (uint) (_bmp.height * 0.5 - 32);     						
			_sprContainer.cacheAsBitmap = true; 
			_sprContainer.cacheAsBitmapMatrix = new Matrix(); 
			addChild(_sprContainer);   
			_sprContainer.visible = false;			
              
			//Create icon frame
			_sprFrmIcon = new Sprite();                                                                 
			_sprFrmIcon.addChild(ImaCachedBitmap.instance.createBitmap(_aGfx[1])); 
			_sprFrmIcon.x = - _sprFrmIcon.width *0.5; //adjust reg point in uple sprContainer point, to let it be rotated by its center
			_sprFrmIcon.y = - _sprFrmIcon.height*0.5; 
			_sprContainer.addChild(_sprFrmIcon);        //add icon to container         
			
			//Create dialog icon
			_tileSheet = iconTs;        //Tilesheet for dialog icons 
			_sprIcon = new ImaSpriteAnim(ImaSprite.TYPE_ICON, 0); 
			_sprIcon.addAnimation("default", _tileSheet, null, [0]);	
			_sprIcon.playAnimation("default");
			_sprIcon.x = (uint)((_bmp.width - _sprIcon.width)*0.5); 
			_sprIcon.y = (uint)(96 - _sprIcon.height * 0.5); // 96: vert adjust;
			_sprIcon.cacheAsBitmap = true;
			_sprIcon.cacheAsBitmapMatrix = new Matrix(); 
			addChild(_sprIcon);        //add icon to container 			
			_sprIcon.visible = false;
			
			
			
			//Create buttons (using standar dialog buttons) 
			var btSheet: ImaBitmapSheet = new ImaBitmapSheet(_aGfx[2], _gfxBtW, _gfxBtH); 
			
			var numBt:uint = 0; 
			for(var i:uint= 0; i< aBt.length; i++) 
				if(aBt[i]) 
					numBt++; 
			var sepx:uint = _bmp.width/(numBt+1);        //button separation 
			
			if (aBt[0]) { 
				//TODO Menu Button 
				_btMenu = new ImaButton(0, btSheet, 0, 2,1);        //4 tiles x button = 4x3 =12 
				_btMenu.x = (uint)(sepx - _btMenu.width*0.5);        //centering asuming there is only 1 button 
				_btMenu.y = (uint)(_bmp.height - _btMenu.height - 8); 
				addChild(_btMenu); 
				_btMenu.visible = false;                                                                         
				_btMenu.signalclick.add(onMenuClick)                                 
			} 
			
			if (aBt[1]) {
				//TODO Repeat Button
				_btRepeat = null;
			}
			
			if(aBt[2]) { //Next Button
				_btNext = new ImaButton(2, btSheet, 8, 10,9);        //4 tiles x button = 4x3 =12 
				//_btNext.x = (uint)((_bmp.width - _btNext.width)*0.5);        //centering asuming there is only 1 button 
				 _btNext.x = (uint)((sepx*numBt - _btNext.width*0.5));        //centering asuming there is only 1 button 
				_btNext.y = (uint)(_bmp.height - _btNext.height - 8); 
				addChild(_btNext); 
				_btNext.visible = false;
				_btNext.signalclick.add(onNextClick); 
			}			
			_containerTimer = new ImaTimer(); 
			
			signalClick = new Signal(); 
		} 
		
		override public function destroy():void {                         
			//TODO destroy all created buttons (pending: Repeat button)
			if(_btMenu != null) {
				_btMenu.destroy(); 
				removeChild(_btMenu); 
				_btMenu = null; 
			}
			
			if(_btNext != null) {
				_btNext.destroy(); 
				removeChild(_btNext); 
				_btNext = null; 
			}
			
			removeChild(_sprIcon); 
			_sprIcon.destroy();
			_sprIcon = null; 
			
			_sprContainer.removeChild(_sprFrmIcon); 
			_sprFrmIcon = null; 
			removeChild(_sprContainer); 
			_sprContainer = null; 
			
			
			_containerTimer.destroy(); 
			_containerTimer = null; 
		
			
			removeChild(_bmp); 
			
			signalClick.removeAll(); 
			signalClick = null; 
			super.destroy(); 
		} 
		
		
								  
		/** 
		 * Exit function called when moving from STS_DYING to STS_DEAD, or directly from gamestate exit func 
		 * Closed and consolidate logic data 
		 */ 
		override public function exit():void { 
			_containerTimer.stop(); 
		} 
		
		public function show(inDelay: Number=0):void { 
			visible = true; 

			//Tweening: Zoom + Fade out 
			if(Registry.bTween) {
				alpha = 0; 
				var targetX:uint = x; 
				var targetY:uint = y; 
				x += width*0.5; 
				y += height*0.5; 
				scaleX = 0.25; 
				scaleY = 0.25; 
				TweenLite.to(this, 0.4, { delay: inDelay, alpha:1, x: targetX, y: targetY, scaleX:1, scaleY:1, onComplete: showEnd } ); 
			}
			else
				showEnd();
			
			//TODO: Impide tocar botones fuera del dialogo (gestionado por fuera)
		} 
		
		protected function showEnd():void {
			//Set all components visible
			for (var i:int = this.numChildren - 1; i >= 0; i--) {
				this.getChildAt(i).visible = true;
			}
			//Activate timer for container fx
			_containerTimer.start(0.05, 0, OnContainerTimer); //set timer for button animation   
			//Starts animation sequence in the icon
			open();
		}
		
		/**
		 * Opening event where perform init actions, after each time the dialog is shown.
		 */
		protected function open():void {
			//To be overriden
		}
		
		/**
		 * Close the dialog, dispatching the closing action (menu, repeat, next)
		 * The imastate containing the dialog must destroy it from its destroy method, after having closed it. No update() action can executed
		 * @param	idBt
		 */
		public function close(idBt: uint):void { 
			_containerTimer.stop(); 
			visible = false;
			onButtonDispatch(idBt);
		} 
		
		protected function OnContainerTimer(timer: ImaTimer):void { 
			_sprContainer.rotation += 5;         
		} 
		
		//-------------------------------------------- Interaction
		
		public function doMouseDown(e:MouseEvent):void {}
		public function doMouseUp(e:MouseEvent):void {}			
		override public function doTouchBegin(e:TouchEvent):void { }
		override public function doTouchEnd(e:TouchEvent):void {  }
		
		//Signal handling 
		protected function onMenuClick(event:MouseEvent):void { 
			close(0);
		} 
		protected function onRepeatClick(event:MouseEvent):void { 
			close(1);	
		} 
		protected function onNextClick(event:MouseEvent):void { 
			Assets.playSound("BtHud");
			close(2);	
		} 
		
		
		private function onButtonDispatch(idBt: uint):void {
			signalClick.dispatch(idBt);
		}
			
		override public function update():void {
			_sprIcon.update();
			//TODO any dialog action not related to default dialog icon animation
			super.update();
			
		}
	} 

} 
