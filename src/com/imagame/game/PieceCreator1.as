package com.imagame.game 
{
	import adobe.utils.CustomActions;
	import avmplus.getQualifiedClassName;
	import com.greensock.loading.data.ImageLoaderVars;
	import com.imagame.engine.ImaBackground;
	import com.imagame.engine.ImaSpriteAnim;
	import com.imagame.engine.ImaState;
	import com.imagame.engine.Registry;
	import com.imagame.utils.ImaBitmapSheet;
	import com.imagame.utils.ImaBitmapSheetDirect;
	import com.imagame.utils.ImaCachedBitmap;
	import com.imagame.utils.ImaSubBitmapSheet;
	import com.imagame.utils.ImaSubBitmapSheetDirect;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	/**
	 * Creator of pieces with the following features:
	 * - Square pieces with same width and height and an color attribute 
	 * A puzzle to be created requires:
	 * - Create list of pieces
	 * - Create Destination positions for the pieces (relative positions)
	 * - Map each piece to every posible destination (a Map function for every position accepting a list of pieces --or kind of pieces--)
	 * @author imagame
	 */
	public class PieceCreator1 implements IPieceCreator 
	{			
		private var _pieces: Vector.<Piece>;
		private var _dstPos: Vector.<Point>;	//Destination local positions (local pos within _img puzzle image)
		private var _dstSize: Vector.<Point>;        //Size for destination position areas (rectangles) 
		private var _dstMapPiece: Vector.<uint>;
		
		private var _numPieces: uint;
		
		private var _id: uint;
		private var _auxRect: Rectangle = new Rectangle();		

		//specific piece creator variables
		protected var _pieceSizeInBox: Vector.<uint>; 
		protected var _pieceSizeInPuz: Vector.<uint>;
		
		/**
		 * 
		 * @param	id		Vowel idx: 1..10 (A,E,I,O,U, a, e, i, o, u)
		 * @param	img		Img sheet of the base puzzle images for the id number
		 * @param	w		Piece width
		 * @param	h		Piece height
		 * @return
		 */
		public function PieceCreator1(id: uint) 
		{
			trace("IPIECECREATOR >> PieceCreator1()");
			
			_id = id;			
			_numPieces = Assets.NUMTOBJ * Assets.NUMBODYPART;
			createPieces();	
			createDstPositions(_id);
			mapPiecesToPositions();
		}
		
		public function destroy():void {
			for (var i:int = 0; i < _pieces.length; i++)
				_pieces[i].destroy();
			_pieces = null;
			for (var i:int = 0; i < _dstPos.length; i++)
				_dstPos[i] = null;
			_dstPos = null;
			for (var i:int = 0; i < _dstSize.length; i++)
				_dstSize[i] = null;
			_dstSize = null;
			_dstMapPiece = null;
			
		}
		
		
		
		/**
		  Creates all the possible pieces (body parts) with it inbox and inpuzzle set of graphics
		 */
		protected function createPieces():void
		{						
			_pieces = new Vector.<Piece>(_numPieces);
			var idxCat:uint = 0; //Piece category
			var idxObjInCat:uint = 0; // object in category counter 
                                                
			var bmpSheetPieceInBox: ImaBitmapSheet = new ImaBitmapSheet(Assets.GfxIconBodyPart, Assets.IMG_ICON_BODYPART_WIDTH, Assets.IMG_ICON_BODYPART_HEIGHT);                                                 
			_auxRect.setTo(0, 0, Assets.IMG_GFX_BODYPART_WIDTH[idxCat]*10,Assets.IMG_GFX_BODYPART_HEIGHT[idxCat]); 
			var bmpSheetPieceInPuz: ImaSubBitmapSheet = new ImaSubBitmapSheet(Assets.GfxPieceBodyPart, Assets.IMG_GFX_BODYPART_WIDTH[idxCat], Assets.IMG_GFX_BODYPART_HEIGHT[idxCat], _auxRect); 

			for (var i:uint = 0; i < _numPieces; i++) {
				_pieces[i] = new Piece1(i, idxCat, idxObjInCat);	//create piece with id(i), category (idxCat), and sequence in category (idxObjInCat)
				
				//create anim with only 1 image, for in-box gfx and for dragging and in-puz gfx 
			//	_pieces[i].addAnimation("InBoxDisabled", bmpSheetPieceInBox, null, [idxCat * Assets.NUMBODYPART * 2 + idxObjInCat * 2]); //2: active and disabled gfx 
			//	_pieces[i].addAnimation("InBoxEnabled", bmpSheetPieceInBox, null, [idxCat * Assets.NUMBODYPART * 2 + idxObjInCat * 2 + 1]); //2: active and disabled gfx 
				_pieces[i].addAnimation("InBoxEnabled", bmpSheetPieceInBox, null, [idxCat * Assets.NUMBODYPART * 3 + idxObjInCat * 3 + 2]); //3: void, disabled and active gfx 
				_pieces[i].addAnimation("InPuzzle", bmpSheetPieceInPuz, null, [idxObjInCat]); 
                                
				idxObjInCat++;                                 
				if (idxObjInCat >= Assets.NUMBODYPART) { 
					idxCat++; 
					idxObjInCat = 0; 
					
					_auxRect.y += Assets.IMG_GFX_BODYPART_HEIGHT[idxCat-1]; 
					_auxRect.width = Assets.IMG_GFX_BODYPART_WIDTH[idxCat]*5; 
					_auxRect.height = Assets.IMG_GFX_BODYPART_HEIGHT[idxCat];                                         
					bmpSheetPieceInPuz = new ImaSubBitmapSheet(Assets.GfxPieceBodyPart, Assets.IMG_GFX_BODYPART_WIDTH[idxCat], Assets.IMG_GFX_BODYPART_HEIGHT[idxCat], _auxRect); 
				} 
			}				
		}
		
		/**
		 * Create a list of destination areas (positions and sizes) for the list of pieces, based in 0,0 local origin.
		 */
		protected function createDstPositions(inTObj: uint):void {
			//Body parts local position within vowel gfx 
			var _bodyParts: Vector.<uint>;  //local position data: [x,y,w,h] centered pos                                                
			_bodyParts = new Vector.<uint>;// (Assets.NUMTOBJ * 4); 
			//TODO: Pte determinar si las pos x,y dependen de la vowel, o son siempre las mismas (Ej la i minuscula, distinta de la O may, para colocar los pies)
			_bodyParts.push((uint)(Assets.IMG_VOWEL_WIDTH * 0.5), 32, Assets.IMG_GFX_BODYPART_WIDTH[0], Assets.IMG_GFX_BODYPART_HEIGHT[0]); //PTE: x,y dependientes de vowel			
			_bodyParts.push((uint)(Assets.IMG_VOWEL_WIDTH * 0.5), 80, Assets.IMG_GFX_BODYPART_WIDTH[1], Assets.IMG_GFX_BODYPART_HEIGHT[1]); 
			_bodyParts.push((uint)(Assets.IMG_VOWEL_WIDTH * 0.5), 96, Assets.IMG_GFX_BODYPART_WIDTH[2], Assets.IMG_GFX_BODYPART_HEIGHT[2]); 
			_bodyParts.push((uint)(Assets.IMG_VOWEL_WIDTH * 0.5), 128, Assets.IMG_GFX_BODYPART_WIDTH[3], Assets.IMG_GFX_BODYPART_HEIGHT[3]); 
			_bodyParts.push((uint)(Assets.IMG_VOWEL_WIDTH * 0.5), 216, Assets.IMG_GFX_BODYPART_WIDTH[4], Assets.IMG_GFX_BODYPART_HEIGHT[4]); 
			
			_dstPos = new Vector.<Point>(Assets.NUMTOBJ);                                                         
			for (var i:uint = 0; i < Assets.NUMTOBJ; i++) { 
				//_dstPos[i] = new Point(_bodyParts[ _pieces[i].category*4], _bodyParts[ _pieces[i].category*4 +1]); //reg point (central)                                 
		//		_dstPos[i] = new Point(_bodyParts[i * 4], _bodyParts[ i * 4 +1]); //reg point (central)       
				_dstPos[i] = new Point(_bodyParts[i*4], Assets.IMG_GFX_BODYPART_POSY[inTObj*Assets.NUMTOBJ+i]); 
			}         
			
			_dstSize = new Vector.<Point>(Assets.NUMTOBJ);                                                         
			for (var i:uint = 0; i < Assets.NUMTOBJ; i++) { 
				_dstSize[i] = new Point(_bodyParts[ i*4+2], _bodyParts[ i*4 +3]); //reg point (central)                                 
			}              			
		}
		
		/**
		 * Creates a list of objects to let check wich piece/s map to each dst position
		 */
		protected function mapPiecesToPositions():void {
			_dstMapPiece = new Vector.<uint>(Assets.NUMTOBJ);
			for (var i:uint = 0; i < Assets.NUMTOBJ; i++) { 
				_dstMapPiece[i] = i; 
			} 
		}
		
		
		/*----------------------------------------------------------------- Getters/Setters */
		
		public function getPieces():Vector.<Piece> { 
			return _pieces; 
		} 
		
		public function getNumOfPieceCategory(): uint {
			var _pieceCategory: Vector.<uint> = new Vector.<uint>;
			for each (var piece:Piece in _pieces) 
				if (_pieceCategory.indexOf(piece.category) == -1)
					_pieceCategory.push(piece.category);
			return _pieceCategory.length - 1; //we substract NON USE CATEGORY
		}


		/* INTERFACE com.imagame.game.IPieceCreator */
		
		public function createPuzzle(): AbstractPuzzle {	
			return (new Puzzle1(0, _pieces, _dstPos, _dstSize, _dstMapPiece));    
		}		
		
	}

}