package com.imagame.engine 
{
	import com.imagame.game.Assets;
	import com.imagame.utils.ImaBitmapSheet;
	import com.imagame.utils.ImaCachedBitmap;
	import flash.events.TouchEvent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent; 
	
	import org.osflash.signals.Signal; 
	
	/**
	 * ...
	 * @author imagame
	 */
	public class ImaPanel extends Sprite 
	{
		protected var _id: uint; 
		protected var _btback: ImaHUDButton;
		
		
		public var signalback: Signal;
		
		public function ImaPanel(id: uint, gfxTitle: Class= null, bBack: Boolean=false) 
		{
			_id = id;
			if (gfxTitle != null) {
				var tit: Bitmap = ImaCachedBitmap.instance.createBitmap(gfxTitle);
				tit.x = (Registry.gameRect.width - tit.width) * 0.5
				tit.y = Registry.appUpOffset;
				addChild(tit);
			}

			if (bBack) {
				//Create HUD menu button    
				var _bmpSheet:ImaBitmapSheet = new ImaBitmapSheet(Assets.GfxButtonsHUD, Assets.BUTTON_HUD_WIDTH, Assets.BUTTON_HUD_HEIGHT); 
				_btback = new ImaHUDButton(0,_bmpSheet, 0, 4, ImaSprite.POS_UPLE, 0); 
				this.addChild(_btback);
				
				//mouse click signals
				signalback = new Signal();
				_btback.signalclick.add(onBackClick);
			}
			
		}
				
		public function destroy():void {
			if(_btback != null){
				_btback.destroy();
				removeChild(_btback);
				_btback = null;
				signalback.removeAll();
				signalback = null;
			}
			//removeChildren();
		}
		
		/**
		 * Init function called each time a panel is getting active (visible when switching panels in a menu panel-chain) 
		 */
		public function init():void { 
		} 
		 
		/**
		 * Init function called each time a panel is getting inactive (hiden when switching panels in a menu panel-chain)
		 */
		public function exit():void { 
		} 
                
		/**
		 * Enable/Disable all interactive elements in the panel
		 * @param	bEnable
		 */
		public function enable(bEnable: Boolean = true):void {
			if(_btback != null) {
				if (bEnable)
					_btback.disable();
				else
					_btback.enable();		
			}
		}
		//-------------------------------------------- Interaction
		
		public function doMouseDown(e:MouseEvent):void {}
		public function doMouseUp(e:MouseEvent):void {}			
		public function doTouchBegin(e:TouchEvent):void {}
		public function doTouchEnd(e:TouchEvent):void {}
		
		
		
		public function onBackClick(event:MouseEvent):void { 
			Assets.playSound("BtHud");
			signalback.dispatch();
		}
		
		//override
		public function update():void {
			//trace("ImaPanel: update");
		}
		
		
	}

}