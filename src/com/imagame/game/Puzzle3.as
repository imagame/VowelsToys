package com.imagame.game 
{
	import com.imagame.engine.Registry;
	import com.imagame.utils.ImaBitmapSheet;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.BevelFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * ...
	 * @author imagame
	 */
	public class Puzzle3 extends AbstractPuzzle 
	{
		private var _bmpComp: Bitmap;
		protected var _bmpPiecesShapes: Bitmap;
		protected var _dstShape: Vector.<uint>;        //Piece Shape Id for each dst positions 
		
		private var _auxRect: Rectangle = new Rectangle(); 
		private var _auxPoint: Point = new Point();
		private var _auxBmdClean: BitmapData;
				
		public function Puzzle3(id:uint, pieces:Vector.<Piece>, dstPos:Vector.<Point>, dstMapPiece:Vector.<uint>, inBmpComp:Bitmap ) 
		{
			_bmpComp = inBmpComp;
			super(id, pieces, dstPos, dstMapPiece);		
			createPiecesShapesImage(pieces); 
		}
		
		override public function destroy():void { 			
			removeChild(_bmpPiecesShapes);
			_bmpPiecesShapes = null;
                       
			//aux objects 
			_dstShape = null;
			_auxRect = null; 
			_auxPoint = null; 
			_auxBmdClean.dispose();
			_auxBmdClean = null;
                        	
			for (var i:uint = 0; i < _numPieces; i++){
				_dstRadio[i] = null; 
			}
			_dstRadio = null;
			
			super.destroy(); 
		}		
		
		/**
		 * Create puzzle image, composing background + level number image + piece shapes
		 * @param	pieces
		 */
		override protected function createPuzzleImage(pieces: Vector.<Piece>):uint {			                        
			var s:GameState = (Registry.game.getState() as GameState); 					
			
			//Copy background 
			_bmp = s.background.getImg();   
			//Copy composite image (vowel with bodyparts) on background image
			_bmp.bitmapData.copyPixels(
				_bmpComp.bitmapData, 
				new Rectangle(0, 0, Assets.IMG_VOWEL_WIDTH, Assets.IMG_VOWEL_HEIGHT), 
				new Point((uint)((Registry.gameRect.width - Assets.IMG_VOWEL_WIDTH) * 0.5), 
				(uint)(Registry.appUpOffset + 16)),
				null,null,true);
			addChild(_bmp); 	
			return pieces.length;
		}

		/** 
		* Create auxiliar structures required to check correct piece dst position  
		*/           
		override protected function createAuxStructures(pieces: Vector.<Piece>):void { 
			super.createAuxStructures(pieces); 
			
			// [CONFIG] Game difficulty parametrization 
			var radio:int = 16;
			
			_dstShape = new Vector.<uint>(_numPieces); 
			//Mark as free all piece positions 
			for (var i:uint = 0; i < _numPieces; i++) { 
					_dstRadio[i] = new Point(radio,radio); 
					_dststslist[i] = DSTSTS_FREE; 
					_dstShape[i] = pieces[i].category; 
			} 
			_auxBmdClean = new BitmapData(_bmp.bitmapData.width, _bmp.bitmapData.height);
		} 
		
		
		
		/**
		 * Create initial piece shapes on puzzle (by default all pieces are in box, so all piece position shapes are included in the image)
		 * @param	pieces
		 */
		protected function createPiecesShapesImage(pieces: Vector.<Piece>):void {                                 
			_tileSheet = new ImaBitmapSheet(Assets.GfxSpritePieceShape, Assets.SPRITE_PIECESHAPE3_WIDTH, Assets.SPRITE_PIECESHAPE3_HEIGHT);                         
			var _bmdPiecesShapes: BitmapData = new BitmapData(Registry.gameRect.width, Registry.gameRect.height, true, 0); 
			for (var i:uint = 0; i < pieces.length; i++) { 
				_auxRect.setTo(0, 0, Assets.SPRITE_PIECESHAPE3_WIDTH, Assets.SPRITE_PIECESHAPE3_HEIGHT);
				_auxPoint.setTo(pieces[i].x, pieces[i].y);
				_bmdPiecesShapes.copyPixels(_tileSheet.getTile(pieces[i].category).bitmapData, _auxRect, _auxPoint, null, null,true); 
			}     
			//apply filter to all shapes
			_auxPoint.setTo(0, 0);
			_bmdPiecesShapes.applyFilter(_bmdPiecesShapes, Registry.gameRect, _auxPoint, new BevelFilter(2,-135));						
			_bmpPiecesShapes = new Bitmap(_bmdPiecesShapes);         
			addChild(_bmpPiecesShapes); 
		} 
                		
		
		/** 
		* Update the piece positions (shape) layer (paint the free puzzle positions)         
		*/ 
		protected function updatePiecesShapesImage():void {                         
			//Borrar _bmpPiecesShapes 
			_bmpPiecesShapes.bitmapData.fillRect(_bmpPiecesShapes.bitmapData.rect,0x000000);

			var shapeHalfW:uint = Assets.SPRITE_PIECESHAPE3_WIDTH*0.5; 
			var shapeHalfH:uint = Assets.SPRITE_PIECESHAPE3_WIDTH*0.5; 
			
			//recorrer las posiciones de piezas y pintar las que estén libres en _bmpPiecesShapes 
			for(var i:uint=0; i < _numPieces; i++) { 
				//If the dst position is free, paint the shape. Obtain the idShape from the _mapDsts vector 
				if(_dststslist[i] == DSTSTS_FREE) { 
					_auxRect.setTo(0, 0, Assets.SPRITE_PIECESHAPE3_WIDTH, Assets.SPRITE_PIECESHAPE3_HEIGHT); 
					_auxPoint.setTo(_dstGlobalPos[i].x - shapeHalfW, _dstGlobalPos[i].y - shapeHalfH); //Pos: obtener la pos up-le de la pieza 
					_bmpPiecesShapes.bitmapData.copyPixels(_tileSheet.getTile(_dstShape[i]).bitmapData, _auxRect, _auxPoint, null, null, true); 
				} 
			} 
			//apply filter to all shapes
			_auxPoint.setTo(0, 0);
			_bmpPiecesShapes.bitmapData.applyFilter(_bmpPiecesShapes.bitmapData, Registry.gameRect, _auxPoint, new BevelFilter(2,-135)); 
		} 
		
				
		override public function setPieceInPuzzle(piece: Piece, dstPos: Point):void { 
			super.setPieceInPuzzle(piece, dstPos);
			updatePiecesShapesImage();	//update shape pieces		
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