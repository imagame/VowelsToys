package com.imagame.utils 
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;

	/**
	 * ...
	 * @author imagame
	 */
	public class ImaCachedBitmap 
	{
		private static var _instance: ImaCachedBitmap;
		private static var cachedData:Object = { };	//static data cache
	
		public function ImaCachedBitmap(enforcer:SingletonEnforcer) 
		{			
		}
		
		public static function get instance():ImaCachedBitmap
 		{
 			if(ImaCachedBitmap._instance == null)
 			{
 				ImaCachedBitmap._instance = new ImaCachedBitmap(new SingletonEnforcer());
 			}
 			return ImaCachedBitmap._instance;
 		}
		
		public function createBitmap(asset:Class, scale:int = 1):Bitmap {
			//Check the cache to see if we've already cached this asset
			var data:BitmapData = cachedData[getQualifiedClassName(asset)]; //+"x+"width+"y"+width
			if (!data) {
				// Not yet cached. Let's do it now
				
				// This should make "Class", "Sprite", and "Bitmap" data types all work.
				var instance: Sprite = new Sprite();
				instance.addChild(new asset());
				
				// Get the bounds of the object in case top-left isn't 0,0
			//	var bounds:Rectangle = instance.getBounds(data);
				
				// Optionally, use a matrix to up-scale the vector asset,
				// this way you can increase scale later and it still looks good.
				var m:Matrix = new Matrix();
			//	m.translate(-bounds.x, -bounds.y);
				m.scale(scale, scale);
				
				// This shoves the data to our cache. For mobiles in GPU-rendering mode,
				// also uploads automatically to the GPU as a texture at this point.
				data = new BitmapData(instance.width * scale, instance.height * scale, true, 0x0);
				data.draw(instance, m, null, null, null, true); // final true enables smoothing
				cachedData[getQualifiedClassName(asset)] = data;
			}
			
			// This uses the data already in the GPU texture bank, saving a draw/memory/push call:
			var clip:Bitmap = new Bitmap(data, "auto", true);
			
			// Use the bitmap class to inversely scale, so the asset still
			// appear to be it's normal size
			clip.scaleX = clip.scaleY = 1 / scale;
			
			return clip;
		}
		
		
		public function createBitmapFromSheet(asset:Class, x:uint, y:uint, w:uint, h:uint, scale:int = 1):Bitmap {
			//Check the cache to see if we've already cached this asset
			var data:BitmapData = cachedData[getQualifiedClassName(asset)+"_x"+x+"y"+y+"w"+w+"h"+h]; 
			if (!data) {
				var instance: Sprite = new Sprite();
				instance.addChild(new asset());	
				var bounds:Rectangle = new Rectangle(x, y, w, h);
				var m:Matrix = new Matrix();
				m.translate(-bounds.x, -bounds.y);
				m.scale(scale, scale);
				data = new BitmapData(w, h, true, 0x0);
				data.draw(instance, m, null, null, null, true); // final true enables smoothing
				cachedData[getQualifiedClassName(asset)+"_x"+x+"y"+y+"w"+w+"h"+h] = data;
			}
			var clip:Bitmap = new Bitmap(data, "auto", true);
			clip.scaleX = clip.scaleY = 1 / scale;
			
			
			return clip;
		}
		
		/*
		public function createBitmapFromSheetDirect(bmp:Bitmap, x:uint, y:uint, w:uint, h:uint, scale:int = 1):Bitmap {
			//Check the cache to see if we've already cached this bitmap
			var data:BitmapData = cachedData[bmp.name+"_x"+x+"y"+y+"w"+w+"h"+h]; 
			if (!data) {
				var instance: Sprite = new Sprite();
				instance.addChild(bmp);	
				var bounds:Rectangle = new Rectangle(x, y, w, h);
				var m:Matrix = new Matrix();
				m.translate(-bounds.x, -bounds.y);
				m.scale(scale, scale);
				data = new BitmapData(w,h,true,0x0);
				data.draw(instance, m, null, null, null, true); // final true enables smoothing
				cachedData[bmp.name+"_x"+x+"y"+y+"w"+w+"h"+h] = data;
			}
			var clip:Bitmap = new Bitmap(data, "auto", true);
			clip.scaleX = clip.scaleY = 1 / scale;
			
			
			return clip;
		}	
		*/
		
		/*
		public function createBitmapFromSheetDirect(bmp:Bitmap, x:uint, y:uint, w:uint, h:uint):Bitmap {
			//Check the cache to see if we've already cached this bitmap
			var data:BitmapData = cachedData[bmp.name+"_x"+x+"y"+y+"w"+w+"h"+h]; 
			if (!data) {
				var instance: Sprite = new Sprite();
				instance.addChild(bmp);	
				var bounds:Rectangle = new Rectangle(x, y, w, h);
				var m:Matrix = new Matrix();
				m.translate(-bounds.x, -bounds.y);

				data = new BitmapData(w,h,true,0x0);
				//data.draw(instance, m, null, null, null, true); // final true enables smoothing
				data.draw(instance, m);
				cachedData[bmp.name+"_x"+x+"y"+y+"w"+w+"h"+h] = data;
			}			
			var clip:Bitmap = new Bitmap(data);
					
			return clip;
		}	
		*/
		
		public function createBitmapFromSheetDirect(bmp:Bitmap, x:uint, y:uint, w:uint, h:uint):Bitmap {			
			var data:BitmapData = cachedData[bmp.name+"_x"+x+"y"+y+"w"+w+"h"+h]; 
			if (!data) {                 
				//var data:BitmapData = new BitmapData(w, h, true, 0x00000000); 
				data = new BitmapData(w, h, true, 0x00000000); 
				data.copyPixels(bmp.bitmapData, new Rectangle(x,y,w,h), new Point()); 
				cachedData[bmp.name+"_x"+x+"y"+y+"w"+w+"h"+h] = data; 
			}                         
			var clip:Bitmap = new Bitmap(data); 			
			
			return clip; 
     	}	
		
	}

	
}
class SingletonEnforcer{}