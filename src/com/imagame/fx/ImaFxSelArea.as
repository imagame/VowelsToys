package com.imagame.fx 
{
	import com.imagame.engine.ImaSprite;
	import com.imagame.engine.Registry;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author imagame
	 */
	public class ImaFxSelArea extends ImaSprite implements IImaFX 
	{
		protected var _x:uint;	//left x pos
		protected var _y:uint;	//top y pos
		protected var _w:uint;
		protected var _h:uint;
		protected var _numLoops: uint;	//Number of Anim loops
		protected var _curLoop:uint;	//Number of current loop
		protected var _bOnFx: Boolean;        //True if FX started (or paused), false is stopped                 		
		protected var _bPauseFx: Boolean;	//True if FX paused (visible graphics and not animated)
				
		protected var _shapeArea: Shape; 
		protected var _dashedLine: DashedLine; 
		
		/**
		 * Selection Area constructor
		 * @param	inX	Left x reg point
		 * @param	inY	Top y reg point	
		 * @param	inW	Width
		 * @param	inH	Height
		 * @param	inLoops
		 */
		public function ImaFxSelArea(inX:int, inY:int, inW: uint, inH:uint, inLoops: uint = 0) 
		{
			super(TYPE_FX, 0);
			_x = inX;
			_y = inY;
			_w = inW;
			_h = inH;
			
			_bOnFx = _bPauseFx = false; 
			
			_numLoops = inLoops;
			_curLoop = 0;
			
			_shapeArea = new Shape();
			_dashedLine = new DashedLine(_shapeArea,4,8); 
			addChild(_shapeArea); 
		}
		
		
		override public function init():void { 
			//_dashedLine.lineStyle(4,0xFFFFFF,0.7); 
			_dashedLine.lineStyle(4,0x000000,0.7); 
            //Draw.curvedBox(_dashedLine, x, y, _w, _h, 20) 
			curvedBox(_x, _y, _w, _h, 20);
			stopFx();
                        
			super.init();
		} 
		
		override public function destroy():void { 		
			removeChild(_shapeArea);
			_shapeArea = null;
			super.destroy(); 
		}
		
		/* INTERFACE com.imagame.fx.IImaFX */
		
		public function startFx(bStart:Boolean = false):void 
		{
			_bOnFx = true; 
			visible = true;
		}
		
		public function stopFx(bPause:Boolean = true, bVisible:Boolean = false):void 
		{
			_bOnFx = false;
			visible = bVisible;
		}
		
		public function curvedBox(x:Number, y:Number, w:Number,h:Number,radius:Number)
		{
			var circ:Number = 0.707107
			var off:Number = 0.6
			_dashedLine.moveTo(x+0,y+radius);
			_dashedLine.lineTo(x+0,y+h-radius);
			_dashedLine.curveTo(x+0,y+(h-radius)+radius*(1-off),x+0+(1-circ)*radius,y+h-(1-circ)*radius);
			_dashedLine.curveTo(x+(0+radius)-radius*(1-off),y+h,x+radius,y+h);
			_dashedLine.lineTo(x+w-radius,y+h);
			_dashedLine.curveTo(x+(w-radius)+radius*(1-off),y+h,x+w-(1-circ)*radius,y+h-(1-circ)*radius);
			_dashedLine.curveTo(x+w,y+(h-radius)+radius*(1-off),x+w,y+h-radius);
			_dashedLine.lineTo(x+w,y+0+radius);
			_dashedLine.curveTo(x+w, y+radius-radius*(1-off),x+w-(1-circ)*radius,y+0+(1-circ)*radius);
			_dashedLine.curveTo(x+(w-radius)+radius*(1-off),y+0,x+w-radius,y+0);
			_dashedLine.lineTo(x+radius,y+0);
			_dashedLine.curveTo(x+radius-radius*(1-off),y+0,x+(1-circ)*radius,y+(1-circ)*radius);
			_dashedLine.curveTo(x+0, y+radius-radius*(1-off),x+0,y+radius);
		}
		
	}

}