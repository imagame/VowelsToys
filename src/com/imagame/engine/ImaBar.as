package com.imagame.engine 
{
	import com.greensock.TweenLite;
	import com.imagame.game.Assets;
	import com.imagame.utils.ImaBitmapSheet;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * Imagame Progress Bar
	 * //TODO parentRef
	 * //TODO FillDirection
	 * //TODO Types of bar: filled, gradient
	 * @author imagame
	 */
	public class ImaBar extends ImaSprite 
	{
		public var bForceUpdate: Boolean; //To force update (repaint) of the bar, thought the value has not changed
		protected var _barType:uint;
		protected var _barWidth:uint;
		protected var _barHeight:uint;

		protected var _parent:*;
		protected var _parentVariable:String;
		public var fixedPosition:Boolean = true; //fixedPosition controls if the ImaBar sprite is at a fixed location on screen, or tracking its parent
		public var positionOffset:Point; //The positionOffset controls how far offset the ImaBar is from the parent sprite (if at all)
	

		protected var _min: Number; //The minimum value the bar can be (can never be >= max)
		protected var _max: Number; //The maximum value the bar can be (can never be <= min)
		protected var _range: Number; //How wide is the range of this bar? (max - min)		
		protected var _pct:Number; //What 1% of the bar is equal to in terms of value (range / 100)
		protected var _value: Number; //The current value - must always be between min and max
		protected var _pxPerPercent:Number;	//How many pixels = 1% of the bar (barWidth (or height) / 100)
		
		protected var _emptyBarRect:Rectangle;
		protected var _filledBarRect:Rectangle; //
		protected var _filledBarPoint:Point;
		protected var _zeroOffsetPoint:Point = new Point;

		protected var _fillDirection:uint;
		protected var _fillHorizontal:Boolean;
		
		public static const FILL_LEFT_TO_RIGHT:uint = 1;
		public static const FILL_RIGHT_TO_LEFT:uint = 2;
		public static const FILL_TOP_TO_BOTTOM:uint = 3;
		public static const FILL_BOTTOM_TO_TOP:uint = 4;
		public static const FILL_HORIZONTAL_INSIDE_OUT:uint = 5;
		public static const FILL_HORIZONTAL_OUTSIDE_IN:uint = 6;
		public static const FILL_VERTICAL_INSIDE_OUT:uint = 7;
		public static const FILL_VERTICAL_OUTSIDE_IN:uint = 8;
		
		private static const BAR_FILLED:uint = 1;
		private static const BAR_GRADIENT:uint = 2;
		private static const BAR_IMAGE:uint = 3;	
		
		public function ImaBar(id:uint, min:Number = 0, max:Number = 100, bmpSheet: ImaBitmapSheet= null, parentRef:* = null, variable:String = "", direction:uint = FILL_LEFT_TO_RIGHT) 
		{
			super(ImaSprite.TYPE_BAR, id);				
			if (bmpSheet == null)
				createFilledBar();
			else {				
				createImageBar(bmpSheet);
			}
			_barWidth = width;
			_barHeight = height;
			_filledBarPoint = new Point(0, 0);
			
			if (parentRef)
			{
				_parent = parentRef;
				_parentVariable = variable;
			}			
			setFillDirection(direction);
			setRange(min, max);
	
		}

		override public function destroy():void { 
			if(_bmp != null)
				removeChild(_bmp);
			_emptyBarRect = null;
			_filledBarRect = null;
			_filledBarPoint = null;
			_zeroOffsetPoint = null;
			super.destroy();
		}
		
		
		public function createFilledBar():void {
			//TODO
		}
		
		//public function createImageBar(empty:Class = null, fill:Class = null, emptyBackground:uint = 0xff000000, fillBackground:uint = 0xff00ff00):void
		public function createImageBar(bmpSheet: ImaBitmapSheet):void {
			_tileSheet = bmpSheet; 
			_bmp = new Bitmap();
			_bmp.bitmapData = _tileSheet.getTile(0).bitmapData;
			_bmp.bitmapData = new BitmapData(Assets.BAR_HUD_WIDTH, Assets.BAR_HUD_HEIGHT, true, 0);
			addChild(_bmp);
			_emptyBarRect = new Rectangle(0, 0, width, height);				
			_filledBarRect = new Rectangle(0, 0, width, height);
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
			
			//TODO: Impide tocar botonos fuera del dialogo
		} 
		
		private function showEnd():void {
			//set all components visible
			visible = true;
		}
		
		//****************************************************************************** Getters/Setters
		
		/**
		 * Set the direction from which the health bar will fill-up. Default is from left to right. Change takes effect immediately.
		 * 
		 * @param	direction	One of the ImaBar.FILL_ constants (such as FILL_LEFT_TO_RIGHT, FILL_TOP_TO_BOTTOM etc)
		 */
		public function setFillDirection(direction:uint):void
		{
			switch (direction){
				case FILL_LEFT_TO_RIGHT:
				case FILL_RIGHT_TO_LEFT:
				case FILL_HORIZONTAL_INSIDE_OUT:
				case FILL_HORIZONTAL_OUTSIDE_IN:
					_fillDirection = direction;
					_fillHorizontal = true;
					break;
					
				case FILL_TOP_TO_BOTTOM:
				case FILL_BOTTOM_TO_TOP:
				case FILL_VERTICAL_INSIDE_OUT:
				case FILL_VERTICAL_OUTSIDE_IN:
					_fillDirection = direction;
					_fillHorizontal = false;
					break;
			}
		}		
		
		/**
		 * Set the minimum and maximum allowed values for the ImaBar
		 * 
		 * @param	min			The minimum value. I.e. for a progress bar this would be zero (nothing loaded yet)
		 * @param	max			The maximum value the bar can reach. I.e. for a progress bar this would typically be 100.
		 */
		public function setRange(min:Number, max:Number):void
		{
			if (max <= min)
			{
				throw Error("ImaBar: max cannot be less than or equal to min");
				return;
			}
			
			_min = min;
			_max = max;			
			_range = _max - _min;
			
			if (_range < 100) {
				_pct = _range / 100;
			}
			else {
				_pct = _range / 100;
			}
			
			if (_fillHorizontal){
				_pxPerPercent = _barWidth / 100;
			}
			else{
				_pxPerPercent = _barHeight / 100;
			}
			
			if (_value) {
				if (_value > _max){
					_value = _max;
				}
				if (_value < _min){
					_value = _min;
				}
			}
			else {
				_value = _min;
			}
		}
	
		
		/**
		 * The percentage of how full the bar is (a value between 0 and 100)
		 */
		public function get percent():Number
		{
			if (_value > _max) {
				return 100;
			}			
			//return Math.floor((_value / _range) * 100);
			return ((_value / _range) * 100);
		}
		
		/**
		 * Sets the percentage of how full the bar is (a value between 0 and 100). This changes FlxBar.currentValue
		 */
		public function set percent(newPct:Number):void
		{
			if (newPct >= 0 && newPct <= 100){
				updateValue(_pct * newPct);				
				updateBar();
			}
		}
		
		/**
		 * Set the current value of the bar (must be between min and max range)
		 */
		public function set currentValue(newValue:Number):void
		{
			updateValue(newValue);			
			updateBar();
		}
		
		/**
		 * The current actual value of the bar
		 */
		public function get currentValue():Number
		{
			return _value;
		}
		
		
		//****************************************************************************** Execution

		protected function updateValueFromParent():void
		{
			updateValue(_parent[_parentVariable]);
		}
		
		protected function updateValue(newValue:Number, bTween:Boolean=false, gradualInc: Boolean=false):void 
		{
			if(newValue == 0 && _value > 0) {
			trace("IMABAR  ========================================================> valueact: " + _value + " newValue: " + newValue);
			}
			
			if (newValue > _max){
				newValue = _max;
			}			
			if (newValue < _min){
				newValue = _min;
			}			
			_value = newValue;
			
			/*
			if (_value == _min && emptyCallback is Function)
			{
				emptyCallback.call();
			}
			
			if (value == max && filledCallback is Function)
			{
				filledCallback.call();
			}
			
			if (value == min && emptyKill)
			{
				kill();
			}
			*/
		}		

		
		/**
		 * Called when the health bar detects a change in the health of the parent.
		 */
		protected function updateBar():void {
			if (_fillHorizontal){
				_filledBarRect.width = int(percent * _pxPerPercent);
			}
			else{
				_filledBarRect.height = int(percent * _pxPerPercent);
			}
			
			//delete content of the  progress bar 
			_bmp.bitmapData.copyPixels(_tileSheet.getTile(0).bitmapData, _emptyBarRect, _zeroOffsetPoint); 
						
			if (percent > 0)
			{
				switch (_fillDirection)
				{
					case FILL_LEFT_TO_RIGHT:
					case FILL_TOP_TO_BOTTOM:
						//	Already handled above
						break;
						
					case FILL_BOTTOM_TO_TOP:
						_filledBarRect.y = _barHeight - _filledBarRect.height;
						_filledBarPoint.y = _barHeight - _filledBarRect.height;
						break;
						
					case FILL_RIGHT_TO_LEFT:
						_filledBarRect.x = _barWidth - _filledBarRect.width;
						_filledBarPoint.x = _barWidth - _filledBarRect.width;
						break;
						
					case FILL_HORIZONTAL_INSIDE_OUT:
						_filledBarRect.x = int((_barWidth / 2) - (_filledBarRect.width / 2));
						_filledBarPoint.x = int((_barWidth / 2) - (_filledBarRect.width / 2));
						break;
						
					case FILL_HORIZONTAL_OUTSIDE_IN:
						_filledBarRect.width = int(100 - percent * _pxPerPercent);
						_filledBarPoint.x = int((_barWidth - _filledBarRect.width) / 2);
						break;
						
					case FILL_VERTICAL_INSIDE_OUT:
						_filledBarRect.y = int((_barHeight / 2) - (_filledBarRect.height / 2));
						_filledBarPoint.y = int((_barHeight / 2) - (_filledBarRect.height / 2));
						break;
						
					case FILL_VERTICAL_OUTSIDE_IN:
						_filledBarRect.height = int(100 - percent * _pxPerPercent);
						_filledBarPoint.y = int((_barHeight- _filledBarRect.height) / 2);
						break;
				}
				
				//paint progress in the bar				
				_bmp.bitmapData.copyPixels(_tileSheet.getTile(1).bitmapData, _filledBarRect, _filledBarPoint);
			}
				
		}
		
		override public function update():void {
			if (_parent)
			{
				if (_parent[_parentVariable] != _value || bForceUpdate)				
				{
					bForceUpdate = false;
					updateValueFromParent();
					updateBar();
				}
				
				if (fixedPosition == false)
				{
					x = parent.x + positionOffset.x;
					y = parent.y + positionOffset.y;
				}
			}			
		}
	}

}