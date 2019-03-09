package com.imagame.utils 
{
	import com.imagame.game.Assets;
	import flash.display.Bitmap;
	import com.imagame.utils.ImaCachedBitmap;
	/**
	 * Bitmap sheet
	 * Create a ImaBitmap Sheet for one sheet of bitmap graphic, and get each bitmap through the method getTile
	 * @author imagame
	 */
	public class ImaBitmapSheetDirect implements IImaBitmapSheet
	{
		protected var _bmp: Bitmap; //Bitmap sheet class
		//private var _bmpSheet: Bitmap;
		protected var _tileWidth: uint;	//tile width
		protected var _tileHeight: uint;	//tile height
		protected var _numCols: uint;	//num tiles in X
		protected var _numRows: uint; //num tiles in Y
		protected var _numTiles: uint;
		
		/**
		 * Creates a bitmap sheet
		 * @param	asset	bitmap tile sheet class
		 * @param	w	tile width
		 * @param	h	tile height
		 */
		
		public function ImaBitmapSheetDirect(bmp: Bitmap, tileWidth: uint, tileHeight: uint) 
		{
			_bmp = bmp;
			_tileWidth = tileWidth;
			_tileHeight = tileHeight;

			_numCols = bmp.width / tileWidth;
			_numRows = bmp.height / tileHeight;
			_numTiles = _numCols * _numRows;
		}
		
		public function getTile(idx: uint): Bitmap {
			var x:uint = idx % _numCols;
			var y:uint = idx / _numCols;
			
			//get the bitmap part from the bitmap sheet and cache it 
			return ImaCachedBitmap.instance.createBitmapFromSheetDirect(_bmp, x * _tileWidth, y * _tileHeight, _tileWidth, _tileHeight);
			//DUDA: ancho y alto +1 ??????
		}
		
		public function getTileWidth():uint {
			return _tileWidth;
		}
		public function getTileHeight():uint {
			return _tileHeight;
		}
		//TODO method destroy???
		
	}

}