package com.imagame.utils 
{
	import flash.display.Bitmap;
	
	/**
	 * ...
	 * @author imagame
	 */
	public interface IImaBitmapSheet 
	{
		function getTile(idx: uint): Bitmap;
		function getTileWidth():uint;
		function getTileHeight():uint;
	}
	
}