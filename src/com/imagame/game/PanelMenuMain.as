package com.imagame.game 
{
	import com.imagame.engine.ImaHUDBar;
	import com.imagame.engine.ImaHUDButton;
	import com.imagame.engine.ImaSprite;
	import com.imagame.utils.ImaCachedBitmap;
	
	import com.imagame.engine.Registry;
	import com.imagame.engine.ImaButton;
	import com.imagame.engine.ImaPanel;
	import com.imagame.utils.ImaBitmapSheet;
	
	
	import flash.display.Bitmap;
	import flash.events.MouseEvent; 
		
	import org.osflash.signals.Signal; 	
	/**
	 * ...
	 * @author imagame
	 */
	public class PanelMenuMain extends ImaPanel 
	{
		protected var _btUcVowels: ImaButton;
		protected var _btLcVowels: ImaButton;
		protected var _btconfig: ImaButton;
		protected var _btstore: ImaButton;
		
		public var signalUcVowels: Signal;
		public var signalLcVowels: Signal;
		public var signalconfig: Signal;
		public var signalstore: Signal;

		public function PanelMenuMain(id:uint) 
		{
			super(id, null, false);
			var logo:Bitmap = ImaCachedBitmap.instance.createBitmap(Assets.GfxLogo);
			logo.x = (Registry.gameRect.width - logo.width) * 0.5
			logo.y = Registry.appUpOffset + 8;
			addChild(logo);
			
			var tit:Bitmap = ImaCachedBitmap.instance.createBitmap(Assets.GfxTitle);
			tit.x = (Registry.gameRect.width - tit.width) * 0.5
			tit.y = Registry.appUpOffset + 32;
			addChild(tit);
				
			//buttons creation
			
			//Create HUD Config button
			var _bmpSheetConfig:ImaBitmapSheet = new ImaBitmapSheet(Assets.GfxButtonsHUD, Assets.BUTTON_HUD_WIDTH, Assets.BUTTON_HUD_HEIGHT); 
			_btconfig = new ImaHUDButton(4,_bmpSheetConfig, 4, 4, ImaSprite.POS_UPLE, 0); 
			this.addChild(_btconfig);
			
			//Create HUD Store button
			var _bmpSheetConfig:ImaBitmapSheet = new ImaBitmapSheet(Assets.GfxButtonsLinkStore, Assets.BUTTON_STORE_WIDTH, Assets.BUTTON_STORE_HEIGHT); 
			_btstore = new ImaHUDButton(5,_bmpSheetConfig, 0, 4, ImaSprite.POS_UPRI, 0, 0, 0, 0, 0,0, Assets.BUTTON_STORE_WIDTH, Assets.BUTTON_STORE_HEIGHT); 
			this.addChild(_btstore);
			
			//Option: bitmap sheet
			var bmpSheet: ImaBitmapSheet = new ImaBitmapSheet(Assets.GfxButtonsPanelMenuMain, Assets.BUTTON_MENU_WIDTH, Assets.BUTTON_MENU_HEIGHT);

			_btUcVowels = new ImaButton(1, bmpSheet, 0, 1);
			_btUcVowels.x = (int)((Registry.gameRect.width - Assets.BUTTON_MENU_WIDTH * 2) / 3);
			_btUcVowels.y = (int)(Registry.gameRect.height * 0.5 - Assets.BUTTON_MENU_HEIGHT * 0.3); 
			this.addChild(_btUcVowels);
			
			_btLcVowels = new ImaButton(2, bmpSheet, 2, 3);
			_btLcVowels.x = _btUcVowels.x*2 + Assets.BUTTON_MENU_WIDTH;
			_btLcVowels.y = _btUcVowels.y; // (Registry.gameRect.height - _btplay.height) * 0.5;
			this.addChild(_btLcVowels);
												
			
			//click signals
			signalUcVowels = new Signal();
			_btUcVowels.signalclick.add(onUcVowelsClick);
			signalLcVowels = new Signal();
			_btLcVowels.signalclick.add(onLcVowelsClick);
			signalconfig = new Signal();
			_btconfig.signalclick.add(onConfigClick);	
			signalstore = new Signal();
			_btstore.signalclick.add(onStoreClick);
							
		}
		
		override public function destroy():void {
			_btUcVowels.destroy();
			removeChild(_btUcVowels);
			_btUcVowels = null;
			signalUcVowels.removeAll();
			signalUcVowels = null;
			
			_btLcVowels.destroy();
			removeChild(_btLcVowels);
			_btLcVowels = null;
			signalLcVowels.removeAll();
			signalLcVowels = null;
						
			_btconfig.destroy();
			removeChild(_btconfig);
			_btconfig = null;
			signalconfig.removeAll();
			signalconfig = null;
			
			_btstore.destroy();
			removeChild(_btstore);
			_btstore = null;
			signalstore.removeAll();
			signalstore = null;
			super.destroy();			
		}

		
		override public function enable(bEnable: Boolean = true):void {
			if (bEnable) {
				_btLcVowels.enable(onLcVowelsClick);
				_btUcVowels.enable(onUcVowelsClick);
				_btconfig.enable(onConfigClick);
				_btstore.enable(onStoreClick);
			}
			else {
				_btLcVowels.disable();
				_btUcVowels.disable();
				_btconfig.disable();
				_btstore.disable();
			}
			super.enable(bEnable);
		}
		
		//--------------------------------------------------- Interaction
		
		
		public function onUcVowelsClick(event:MouseEvent):void { 
			signalUcVowels.dispatch();
		}
	
			
		public function onLcVowelsClick(event:MouseEvent):void { 
			signalLcVowels.dispatch();
		}
				
		public function onConfigClick(event:MouseEvent):void { 
			signalconfig.dispatch();
		}
		
		public function onStoreClick(event:MouseEvent):void { 
			signalstore.dispatch();
		}
		
		
		override public function update():void {
			//TODO animations?
		}
	}

}