package com.imagame.engine 
{ 
	import com.imagame.game.Assets; 
	import com.imagame.utils.ImaBitmapSheet; 
	import com.imagame.utils.ImaCachedBitmap;
	import flash.display.Bitmap; 
	import flash.display.DisplayObject; 
	import flash.display.SimpleButton; 
	import flash.display.Sprite; 
	import flash.events.MouseEvent; 
	
	import org.osflash.signals.natives.NativeSignal; 
	
	
	/** 
	 * Simple button with the ability of changing its graphics sheet 
	 * @author imagame 
	 */ 
	public class ImaButton extends ImaSprite 
	{ 
		public var signalclick: NativeSignal; 
		protected var _button: SimpleButton = new SimpleButton(); 
		//private var _selected: Boolean = false;

		//Default system buttons
		// id: 0..4 (0: Back to menu, 1: 1-star, 2: 2-stars, 3: 3-stars)
		// 4 tiles x id: active, selected-up, selected-down, disabled)
		
		public function ImaButton(id: uint, bmpSheet: ImaBitmapSheet= null, idxUp: int=0, idxDown: int=-1, idxOver:int = -1) 
		{ 
			super(ImaSprite.TYPE_BUTTON, id); 
			if (bmpSheet == null) 
				_tileSheet = new ImaBitmapSheet(Assets.GfxIcon0, 32, 32);        //TODO gfx por defecto para un ImaButton 
			else 
				_tileSheet = bmpSheet; 
			
			loadGraphic(idxUp, idxDown, idxOver); 
			addChild(_button); 
			
			signalclick = new NativeSignal(this, MouseEvent.MOUSE_UP, MouseEvent); 
		} 
				
/*		
		public function ImaButton(id: uint, bmpSheet: ImaBitmapSheet= null, idxUp: int=0, idxDown: int=-1, idxOver:int = -1) 
		{ 
				super(ImaSprite.TYPE_BUTTON, id); 
				if (bmpSheet == null) {
						_tileSheet = new ImaBitmapSheet(Assets.GfxButtonsHUD, Assets.BUTTON_HUD_WIDTH, Assets.BUTTON_HUD_HEIGHT);        //TODO gfx por defecto para un ImaButton 
						_selected = false;
						idxUp = (_selected)?id * 4: id*4+1;
						idxDown = id*4 + 2;
						idxOver = idxDown;
				}else 
						_tileSheet = bmpSheet; 
				
				loadGraphic(idxUp, idxDown, idxOver); 
				addChild(_button); 
				
				signalclick = new NativeSignal(this, MouseEvent.MOUSE_UP, MouseEvent); 
		} 
	*/	
		
		
		override public function destroy():void { 
				signalclick.removeAll(); 
				signalclick = null; 
				
				//DUDA (_button.upState as Bitmap).bitmapData.dispose(); //Necesario limpiar memoria de los estados de un SimpleButton?? 
				//_button.upState = null; 
				
				//_bmpSheet.destroy(); //DUDA Test if required 
				removeChild(_button); 
				_button = null; 
				super.destroy();
		} 

		public function loadGraphic(idxUp:int, idxDown: int = -1, idxOver: int = -1 ):void { 
			_button.upState = _tileSheet.getTile(idxUp); 
			_button.downState = (idxDown == -1)? _button.upState:_tileSheet.getTile(idxDown); 
			_button.overState = (idxOver == -1)?_button.downState: _tileSheet.getTile(idxOver); 
			_button.hitTestState = _button.upState; 
			//_button.hitTestState = _button.overState; 
		} 
		
		/**
		 * Enables the button and set the callback function when the button is clicked
		 * @param	func
		 */
		public function enable(func:Function = null):void {                                 
			_button.enabled = true; 
			if (func != null)
				signalclick.add(func);	//add the subscriber to the signal (required if previously disabled)
			//TODO _tileSheet.getTile(xxx) //Change disable graphic 
		} 
		
		public function disable():void {                                 
			_button.enabled = false; //It does not effects the NativeSignal!!
			signalclick.removeAll();	//It requires adding again the subscribers to the signal
			//TODO _tileSheet.getTile(xxx) //Change disable graphic 
		} 		
/*
		public function setSelected():void {
			_selected = true;
			var idxUp: uint = (_selected)?id * 4: id * 4 + 1;
			_button.upState = _tileSheet.getTile(idxUp);
		}

		public function setEnabled(b: Boolean):void {
			if(b)
				loadGraphic((_selected)?id * 4: id * 4 + 1, id * 4 + 2, id * 4 + 3 );
			else
				loadGraphic(id * 4 + 3);
			
		}
		*/
	} 

}