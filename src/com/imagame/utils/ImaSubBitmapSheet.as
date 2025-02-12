package com.imagame.utils 
{
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	/**
	 * BitmapSheet that occupies only a rectangle within the asset image
	 * @author imagame
	 */
	public class ImaSubBitmapSheet extends ImaBitmapSheet 
	{
		protected var _rectImg: Rectangle;
		protected var _numSubCols: uint;	//num tiles in X rect
		protected var _numSubRows: uint; //num tiles in Y rect
		protected var _numSubTiles: uint;
		
		public function ImaSubBitmapSheet(asset:Class, subTileWidth:uint, subTileHeight:uint, rectImg: Rectangle) 
		{
			super(asset, subTileWidth, subTileHeight);
			//_rectImg = rectImg;
			_rectImg = rectImg.clone();
			
			_numSubCols = _rectImg.width / subTileWidth;
			_numSubRows = _rectImg.height / subTileHeight;
			_numSubTiles = _numSubCols * _numSubRows;
		}
		
		override public function getTile(idx: uint): Bitmap {
			
			var x:uint = idx % _numSubCols;
			var y:uint = idx / _numSubCols;
			
			//get the bitmap part from the bitmap sheet and cache it 
			return ImaCachedBitmap.instance.createBitmapFromSheet(_asset, x * _tileWidth + _rectImg.left, y * _tileHeight + _rectImg.top, _tileWidth, _tileHeight);
			
		}
	}

}