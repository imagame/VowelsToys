package com.imagame.utils 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author imagame
	 */
	public class ImaCompositeImage 
	{
		//protected var _bmp:Bitmap;
		protected var _bmd:BitmapData;
		protected var _auxRect: Rectangle = new Rectangle();
		protected var _auxPoint: Point = new Point();
		
		public function ImaCompositeImage(inBmp: Bitmap, inX: int, inY:int, inW: int, inH: int) 
		{
			_bmd = new BitmapData(inW, inH, true,0x0); 
			_auxRect.setTo(inX, inY, inW, inH);
			_bmd.copyPixels(inBmp.bitmapData, _auxRect, _auxPoint);
		}
	
		public function addBmd(inBmd: BitmapData, inDstX: int, inDstY: int):void {
			_auxRect.setTo(0, 0, inBmd.width, inBmd.height); 
			_auxPoint.setTo(inDstX, inDstY); 
				
			_bmd.copyPixels(inBmd, _auxRect, _auxPoint,null,null,true); //copy _auxRect in 0,0            			
		} 
	
		public function addExtBmd(inBmd: BitmapData, inDstX: uint, inDstY:uint, inRot: uint, inZoom: uint): void { 
		} 
		
		public function getBmp():Bitmap {
			var bmp:Bitmap = new Bitmap(_bmd); 
			return bmp;
		}
		
		/** 
		*        Example: 
		*                var alphaBitmap:BitmapData = new BitmapData(width, height, true, toARGB(0x000000, (.5 * 255))); 
		*                _bitmapData.copyPixels(_bitmaps.vault[BitmapNames.BITMAP], _drawRect, _drawPoint, alphaBitmap, null, true); 
		* 
		*/ 
		protected function toARGB(rgb:uint, newAlpha:uint):uint 
		{ 
			var argb:uint = 0; 
			argb = (rgb); 
			argb += (newAlpha<<24); 
			return argb; 
		} 		
	}

}