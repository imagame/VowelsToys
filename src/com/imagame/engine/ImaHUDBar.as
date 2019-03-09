package com.imagame.engine 
{
	import com.greensock.TweenLite;
	import com.imagame.game.Assets;
	import com.imagame.utils.IImaBitmapSheet;
	import com.imagame.utils.ImaBitmapSheet;
	import com.imagame.utils.ImaSubBitmapSheet;
	import com.imagame.utils.ImaSubBitmapSheetDirect;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	/**
	 * HUD progress Bar with preceding icon (variable, based in external value)
	 * 
	 * @author imagame
	 */
	public class ImaHUDBar extends ImaBar 
	{
		protected var _tileSheetIcon: IImaBitmapSheet;
		protected var _bmpIcon: Bitmap;
		protected var _valueIcon: int;
		protected var _parentVariableIcon:String;

		/**
		 * ImaHUDbar constructor
		 * @param	id			identifier	
		 * @param	min			Min value
		 * @param	max			Max value
		 * @param	bmpSheet	ImaBitmapSheet
		 * @param	corner		Which one of the four screen corners locate the bar [0..3]=uple,upri,dole,dori,
		 * @param	centre
		 * @param	offsetx
		 * @param	offsety
		 * @param	parentRef
		 * @param	variable
		 * @param	idxIcon
		 */
		public function ImaHUDBar(id:uint, min:Number = 0, max:Number = 100, bmpSheet:ImaBitmapSheet = null, corner: uint = 0, centre: uint = 0,  offsetx:uint = 0, offsety:uint = 0, parentRef:* = null, variable:String = "", variableIcon:String ="")
		{
			super(id, min, max, bmpSheet, parentRef, variable );
			x = (corner % 2 == 0)? 8 + offsetx: Registry.gameRect.width - 8 - _barWidth - offsetx; 
			y = (corner < 2 )? 8 + offsety: Registry.gameRect.height - 8 - _barHeight - offsety; 		
			if (centre == ImaSprite.POS_CENTREX)
					x = (Registry.gameRect.width - _barWidth) * 0.5;
			else if (centre == ImaSprite.POS_CENTREY)
					y = (Registry.gameRect.height - _barHeight) * 0.5;

			//Create icon bar
			_valueIcon = 0;
			_parentVariableIcon = variableIcon;
			_tileSheetIcon = new ImaSubBitmapSheetDirect(_tileSheet.getBmp(), Assets.BAR_ICON_HUD_WIDTH, Assets.BAR_ICON_HUD_HEIGHT, new Rectangle(0, Assets.BAR_HUD_HEIGHT * 2, Assets.BAR_HUD_WIDTH, Assets.BAR_ICON_HUD_HEIGHT));
			
			_bmpIcon = new Bitmap();			
			_bmpIcon.bitmapData = _tileSheetIcon.getTile(_valueIcon).bitmapData; //Default icon (till imaHUDBar is updated) 
			_bmpIcon.x = -Assets.BAR_ICON_HUD_WIDTH-2;
			_bmpIcon.y = (Assets.BAR_HUD_HEIGHT - Assets.BAR_ICON_HUD_HEIGHT) * 0.5;
			addChild(_bmpIcon);
		}

		
		
		override public function destroy():void 
		{ 
			_tileSheetIcon = null;
			if(_bmpIcon != null)
				removeChild(_bmpIcon); 
				//removeChildAt(1);
			_bmpIcon = null;
			super.destroy();
		}
		
		/** 
		 * Set the current value of the icon bar ( 
		 */ 
		public function set currentValueIcon(newValue:uint):void 
		{ 
				updateValueIcon(newValue);                         
				updateBarIcon(); 
		} 
                
		/** 
		 * The current actual value of the bar icon 
		 */ 
		public function get currentValueIcon():uint 
		{ 
				return _valueIcon; 
		} 
		
		 
		//****************************************************************************** Execution 
                
		override protected function updateValueFromParent():void 
		{ 
			//update Bar value 
			updateValue(_parent[_parentVariable]); 
			//update icon value 
			if(_parentVariableIcon != null) 
				updateValueIcon(_parent[_parentVariableIcon]); 
		} 
                
		
		override protected function updateValue(newValue:Number, bTween:Boolean=false, gradualInc: Boolean=false):void 
		{ 
			//Icon tweening 
			if(bTween && Registry.bTween) 
				onTweenUpdateValue(); //         
			//else 
			//        updateValueEnd(gradualInc); 
							
			if(gradualInc) {         //Gradual increment        //TODO: use ImaTimer 
				var tmpVal:uint = _value; 
				var numInc:int = newValue - tmpVal; 
				for(var i:uint=0; i< Math.abs(numInc); i++){ 
					tmpVal += (numInc > 0)?1:-1; 
					super.updateValue(tmpVal); 
				} 
			} 
			else //one step increment 
				super.updateValue(newValue); 
		} 
		
		/** 
		*        Icon tweening: zoom int 
		*/ 
		protected function onTweenUpdateValue():void{ 
				var targetX:uint = _bmpIcon.x; 
				var targetY:uint = _bmpIcon.y; 
				x += _bmpIcon.width*0.5; 
				y += _bmpIcon.height*0.5; 
				scaleX = 0.25; 
				scaleY = 0.25; 
				TweenLite.to(_bmpIcon, 0.4, {x: targetX, y: targetY, scaleX:1, scaleY:1} ); 
				//TODO Tweelite con ease in,out 
		} 		
		
		protected function updateValueIcon(newValue: int):void { 
			/* 
			//TODO  Limit Icon value 
			if (newValue > _maxValIcon){ 
					newValue = _maxValIcon; 
			}                         
			if (newValue < _minValIcon){ 
					newValue = _minValIcon; 
			}                         
			*/ 
			_valueIcon = newValue; 
		} 
	
		/** 
		* Updates the bar icon (no the bar progress) 
		*/ 
		protected function updateBarIcon():void { 
			_bmpIcon.bitmapData = _tileSheetIcon.getTile(_valueIcon).bitmapData; 
		} 
		
		/** 
		 * Called when the health bar detects a change in the health of the parent. 
		 */ 
		override protected function updateBar():void { 
			updateBarIcon(); 
			super.updateBar(); 
		} 
     		
	}

}