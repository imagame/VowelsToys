package com.imagame.game 
{
	import com.greensock.TweenLite;
	import com.imagame.engine.ImaState;
	import com.imagame.engine.Registry;
	import com.imagame.utils.ImaBitmapSheet;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author imagame
	 */
	public class Puzzle2 extends AbstractPuzzle 
	{
		private var _bmpComp: Bitmap;
		private var _pieceLst: Vector.<Object>;
		
		private var _idT1: TweenLite;
		private var _idT2: TweenLite;

		private var _auxPoint: Point = new Point();
		private var _auxRect: Rectangle = new Rectangle();
		
		public function Puzzle2(id:uint, pieces:Vector.<Piece>, dstPos:Vector.<Point>, dstMapPiece:Vector.<uint>, inBmpComp:Bitmap) 
		{
			_bmpComp = inBmpComp;
			super(id, pieces, dstPos, dstMapPiece);		
		}
		
		/** 
		* Create auxiliar structures required to check correct piece dst position  
		*/           
		override protected function createAuxStructures(pieces: Vector.<Piece>):void { 
			super.createAuxStructures(pieces); 
			
			// [CONFIG] Game difficulty parametrization 
			var radio:int = 32;
			
			//override radio and state positions
			//Mark as free all piece positions 
			for (var i:uint = 0; i < _numPieces; i++) {
				_dstRadio[i] = new Point(radio,radio); 
				_dststslist[i] = DSTSTS_FREE;
			}			
			
			//create _piecesLst required to FX-hide-pieces in init() method
			//_auxPoint.setTo(0,0); 
			var bmpBkg: Bitmap = (Registry.game.getState() as ImaState).background.getImg();
			_auxPoint.setTo(x,y); 
			bmpBkg.bitmapData.copyPixels(_bmp.bitmapData, _bmp.bitmapData.rect, _auxPoint); 
			
			var bmdBkg: BitmapData = new BitmapData(256, 256);
			bmdBkg = (Registry.game.getState() as ImaState).background.getImg().bitmapData.clone();
			bmdBkg.copyPixels(_bmp.bitmapData, _bmp.bitmapData.rect, _auxPoint); 
			
			
			
			
			_auxPoint.setTo(0,0); 
			_pieceLst = new Vector.<Object> 
			for(var i:uint = 0; i< pieces.length; i++){ 
				var bmdPiece: BitmapData = new BitmapData(pieces[i].w, pieces[i].h);// , true, 0x0); 
				var gx:uint = x + pieces[i].x; //global x coord: vowel x (left-margin + xinit vowel) + local pos 
				var gy:uint = y + pieces[i].y; 
				_auxRect.setTo(gx, gy, pieces[i].w, pieces[i].h); 
				//bmdPiece.copyPixels(bmpBkg.bitmapData, _auxRect, _auxPoint); 
				bmdPiece.copyPixels(bmdBkg, _auxRect, _auxPoint); 
				_pieceLst[i] = {bmp: new Bitmap(bmdPiece), x: pieces[i].x, y: pieces[i].y, w: pieces[i].w, h: pieces[i].h}; 
			} 
		} 
		
		override protected function createPuzzleImage(pieces: Vector.<Piece>):uint { 
			var s:GameState = (Registry.game.getState() as GameState); 
			_tileSheet = new ImaBitmapSheet(Assets.vowelImages[s.phase], Assets.IMG_VOWEL_WIDTH, Assets.IMG_VOWEL_HEIGHT); 
			_bmp = _tileSheet.getTile(0); //tile 0: outlined vowel                         
            addChild(_bmp);    
			addChild(_bmpComp);                       			
 
			x = (uint)((Registry.gameRect.width - _bmp.width) * 0.5);	//uint: fuerza quitar decimales
			y = (uint)(Registry.appUpOffset + 16); 
			
			return pieces.length;
		} 
		
		override public function destroy():void { 
			if (_idT1 != null) {
				_idT1.kill();
				_idT1 = null;
			}
			if (_idT2 != null) {
				_idT2.kill();
				_idT2 = null;
			}

			for (var i:uint = 0; i < _pieceLst.length; i++){
				removeChild(_pieceLst[i].bmp);
				_pieceLst[i].bmp = null;
			}
			_pieceLst[i] = null;

			removeChild(_bmpComp);
			_bmpComp = null;
			
			for (var i:uint = 0; i < _numPieces; i++){
				_dstRadio[i] = null; 
			}
			_dstRadio = null;
			
			
			super.destroy(); 
		}
		
		/**
		 * Hide visible Vowel, gradually piece by piece 
		 */
		override public function init():void { 
			for (var i:uint = 0; i < _pieceLst.length; i++) {
				_pieceLst[i].bmp.x = _pieceLst[i].x;
				_pieceLst[i].bmp.y = _pieceLst[i].y;
				addChild(_pieceLst[i].bmp);
				if (Registry.bTween) {
					_pieceLst[i].bmp.alpha = 0;
					_idT2 = TweenLite.to(_pieceLst[i].bmp, 0.4, { delay:i * 0.2 + 1, alpha:1, onComplete: initClear(i)  } ); 
				}
			}
			if (Registry.bTween) {
				_idT1 = TweenLite.to(_bmpComp, 0.5, { delay: _pieceLst.length*0.2+1, alpha:0, onComplete: function() { _bmpComp.visible = false; }} );
			}else {
				_bmpComp.visible = false;
			}
			
			
			super.init();
		}          
		
		private function initClear(inIdx: uint):void {
			_pieceLst[inIdx].visible = false;
		}
 		
		
		
		/** 
		 * Check if drop position is valid, based on group dropping conditions 
		 * Condition 1:(distance < _radio) -> identificar la dst más próxima a x,y. Chequear que se cumple distance rule. 
		 * Condition 2: chk if piece matches position (for 1:1 mapping or 1:N mapping) 
		 * Assumption: only one position must be valid at the same time 
		 * @param        x 
		 * @param          y 
		 * @return  True if pos (x,y) is a valid destination position 
		 */ 
        override public function chkCorrectDstPos(x: Number, y: Number, piece: Piece, updSts: Boolean=false): Point { 
			//return _dstGlobalPos[piece.id]; 
			
			//[TODO] Implement puzzle rounds 
			//r: a que round pertenece la pieza: 
			//idx: indice secuencia relativa dentro del round r 
			//To check in _dstPos[_round[_roundAct] + idx] 
			for(var i:uint=0; i < _numPieces; i++){                         
				//Chk cond 1 
				if(_dststslist[i]==DSTSTS_FREE && distance(x, y, _dstGlobalPos[i].x, _dstGlobalPos[i].y) < _dstRadio[i].x) {        //_radio: valor en pixels                                         
					//Chk cond 2 
					if(chkCorrectPuzzleCondition(piece.id,i)) {                                         
						if (updSts) { 
							setDstPosStatus(i, false); //Update dst bmp (set occupied graphic) 
						} 
						return _dstGlobalPos[i]; 
					} 
				}                                                         
			}                         
			return null;                                             
		} 

		/** 
		*        Checks if a piece matches the puzzle <idxPos> position 
		*/ 
		private function chkCorrectPuzzleCondition(idPiece: uint, idxPos: uint): Boolean { 
				//if 1-piece:1-position mapping 
				return (_dstMapPiece[idxPos] == idPiece); 
		} 		

				
	}

}