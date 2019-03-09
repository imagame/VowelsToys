package com.imagame.engine 
{
	import com.imagame.game.Assets;
	import com.imagame.utils.ImaBitmapSheet;
	
	/**
	 * ...
	 * @author imagame
	 */
	public class ImaHUDButton extends ImaButton 
	{
		private var _w: uint; 		//button width
		private var _h:uint; 		//button height
		private var _sepx:uint; 	//Horizontal initial left/right separation			
		private var _sepy:uint; 	//Vertical initial top separation
		private var _sepinx:uint; 	//Horizontal in-buttons separation
		private var _sepiny:uint;	//Vertical in-buttons separation 		
		private var _numStates: uint;         //Number of graphics tiles in the bitmapSheet for the same button 																		//0: active, 1: selected, 2: clicked/over, 3:disabled 
		private var _idx: uint        //index of first graphics tile for the button in bitmapshee [0..numButtons*numStates-1] 
		private var _selected: Boolean; 

		/* 
		 * HUD Button
		@param	idx		Button index number within bmpSheet 
		@param	corner	Which one of the four screen corners locate the button [0..3]=uple,upri,dole,dori         
		@param	pos		Relative pos starting from up-left corner [0..N-1] 
		*/
		//public function ImaHUDButton(bmpSheet: ImaBitmapSheet, id: uint, numStates: uint, corner: uint, posx: uint, posy:uint=0, sepx:uint = Assets.BUTTON_HUD_SEPX, sepy:uint = Assets.BUTTON_HUD_SEPY, sepinx:uint = Assets.BUTTON_HUD_SEPINX, sepiny:uint = Assets.BUTTON_HUD_SEPINY, w:uint=Assets.BUTTON_HUD_WIDTH, h:uint=Assets.BUTTON_HUD_HEIGHT) 
		public function ImaHUDButton(id:uint, bmpSheet: ImaBitmapSheet, idx: uint, numStates: uint, corner: uint, posx: uint, posy:uint=0, sepx:uint = 8, sepy:uint = 8, sepinx:uint = 4, sepiny:uint = 4, w:uint=36, h:uint=36) 
		{ 
			_w = w; 
			_h = h; 
			_sepx = sepx;
			_sepy = sepy;
			_sepinx = sepinx; 
			_sepiny = sepiny; 
			_numStates = numStates; 
			_idx = idx*_numStates; 
			super(id, bmpSheet, _idx, _idx + 2, _idx + 2); //id, bmpsheet, up, do, over 
			x = (corner % 2 == 0)? _sepx + posx * _w + posx*_sepinx : Registry.gameRect.width - _sepx - (posx+1)*_w - posx*_sepinx; 
			y = (corner < 2 )? _sepy + posy * _h + posy*_sepiny : Registry.gameRect.height - _sepy - (posy+1)*_h - posy*_sepiny; 
                  
			//x = (corner % 2 == 0)? 8 + posx * Assets.BUTTON_HUD_WIDTH + posx*4: Registry.gameRect.width - 8 - (posx+1)*Assets.BUTTON_HUD_WIDTH - posx*4; 
			//y = (corner < 2 )? 8: Registry.gameRect.height - 8 - Assets.BUTTON_HUD_HEIGHT; 
			_selected = false; 
		} 
		
		public function get selected():Boolean{ 
			return _selected;                                 
		} 
		
		public function set selected(b: Boolean):void{ 
			if(_button.enabled){ 
				_selected = b; 
				loadGraphic((_selected)?_idx+1:_idx, _idx+2, _idx+2);                                 
			} 
		} 
		
		override public function enable(signalFunc: Function = null):void { 
			super.enable(signalFunc); 
			loadGraphic((_selected)?_idx+1:_idx, _idx+2, _idx+2);                                 
		} 
		
		override public function disable():void { 
			super.disable(); 
			loadGraphic(_idx+3);                                 
		} 
 	
	//NOOOOOOOOO, ahora se usa _id	
	//	override public function get id():uint {
	//		return _idx;
	//	}
	}

}