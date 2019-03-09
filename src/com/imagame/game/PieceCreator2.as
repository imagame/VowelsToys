package com.imagame.game 
{
	import com.imagame.utils.ImaBitmapSheetDirect;
	import com.imagame.utils.ImaCompositeImage;
	import com.imagame.utils.ImaRectAreaDivider;
	import com.imagame.utils.ImaSubBitmapSheet;
	import com.imagame.utils.ImaSubBitmapSheetDirect;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author imagame
	 */
	public class PieceCreator2 implements IPieceCreator 
	{
		private var _pieces: Vector.<Piece>;
		private var _dstPos: Vector.<Point>;	//Destination local positions (local pos within _img puzzle image)
		private var _dstSize: Vector.<Point>;        //Size for destination position areas (rectangles) 
		private var _dstMapPiece: Vector.<uint>;
		
		private var _numPieces: uint;
		
		private var _id: uint;			//id level within phase (1..5)
		private var _idPhase: uint;		//Phase id-> (0:A, 1:E, 2:I, 3:O, 4:U)         
		private var _img: Bitmap;		//Bmp (rendered vowel without bodyparts) 
		private var _bmp: Bitmap;		//Bmp (rendered vowel with bodyparts)
		private var _w: uint; 			//Bmp width 
		private var _h: uint;			//Bmp height 
   
		private var _imgComp: ImaCompositeImage; //Composite image (_img with bodyparts on it)         
		
		private var _piecesList: Vector.<int>;        //List of pieces id corresponding to the 5 bodyparts of the vowel 
		private var _posList: Vector.<int>; //Local center x,y pos within _img area where _pieceList pieces are located 
 		
		private var _auxRect: Rectangle = new Rectangle();
		
		public function PieceCreator2(id: uint, idPhase: uint, img: Bitmap, piecesList: Vector.<int>, posList: Vector.<int>) 
		{
			trace("IPIECECREATOR >> PieceCreator2()"); 
			
			_id = id; 
			_idPhase = idPhase;
			_img = img; 
			_w = img.width; 
			_h = img.height; 
			_piecesList = piecesList.concat(); 
			_posList = posList.concat(); 
			
			
			createCompositeImage(); //creates and sets _bmp
			createPieces();         
			createDstPositions(); 
			mapPiecesToPositions(); 			
		}
		
		 /** 
		 * Create the image composing of a vowel and a set of bodyparts, from which the pieces will be created. 
		 */ 
		private function createCompositeImage():void {                 
			//Define bmpSheets to contain all Bodypart pieces 
			var bmpSheetPiece: Vector.<ImaSubBitmapSheet> = new Vector.<ImaSubBitmapSheet>(Assets.NUMTOBJ);                                         
			var idxCat:uint = 0; 
			_auxRect.x = _auxRect.y = 0; 
			for(var i:uint=0; i< Assets.NUMTOBJ; i++) {                                         
					_auxRect.width = Assets.IMG_GFX_BODYPART_WIDTH[idxCat]*Assets.NUMBODYPART; //2*num_bodypart 
					_auxRect.height = Assets.IMG_GFX_BODYPART_HEIGHT[idxCat];       
					bmpSheetPiece[i] = new ImaSubBitmapSheet(Assets.GfxPieceBodyPart, Assets.IMG_GFX_BODYPART_WIDTH[idxCat], Assets.IMG_GFX_BODYPART_HEIGHT[idxCat], _auxRect);                 
					_auxRect.y += Assets.IMG_GFX_BODYPART_HEIGHT[idxCat]; 
					idxCat++; 
			} 
			
			//Compose bkg img(256x26) with additional N images copied in local positions (reg centered) on the base img 
			_imgComp = new ImaCompositeImage(_img, 0,0, _img.width, _img.height); //256x256 
			
			for (var i:uint=0; i < _piecesList.length; i++ ) {  
					var idPiece = _piecesList[i];
					var idxCat = idPiece / Assets.NUMBODYPART; 
					var idxInCat = idPiece % Assets.NUMBODYPART; 
					var wimg:int = bmpSheetPiece[idxCat].getTileWidth(); 
					var himg:int = bmpSheetPiece[idxCat].getTileHeight(); 
					var ximg:int = _posList[i*2]- wimg *0.5; 
					var yimg:int = _posList[i*2+1] - himg *0.5; 
					_imgComp.addBmd( bmpSheetPiece[idxCat].getTile(idxInCat).bitmapData, ximg, yimg); 
					//_imgComp.addBmd(bmd, x, y); //imgComp.addComp(bmd2, x, y, rot, zx, zy); 
			}                         
			_bmp = _imgComp.getBmp(); 
									
			//release resources 
			bmpSheetPiece = null;                         
		} 	
		


		/**
		 * Create a list of pieces <_pieces> from an image 
		 */
		private function createPieces():void {
			//Define pieces 
			var _piecesPos: Vector.<uint>; // = new Vector.<uint>;                         

			//[CONFIG] Game Difficulty parametrization                         
            var numOfPieces:Vector.<uint> = new Vector.<uint>;  //Number of puzzle pieces in each difficulty level, for each vowel (Min:4, Max: )
			numOfPieces.push(	3,4,5,6,8, 	//vowel A
								3,6,8,10,12, 	//vowel E
								4,6,8,12,14, 	//vowel I
								5,8,12,14,18, 	//vowel O
								6,10,14,17,20);	//vowel U          	       
			var nPieces: uint = numOfPieces[_idPhase * 5 + _id - 1];
			var areaDiv: ImaRectAreaDivider = new ImaRectAreaDivider(_bmp.bitmapData); //from x,y=0,0 for default image w,h 
			//sd = new ShapeDivider(rect, rect_shape, offset) //offset of rect_shape within rect ([0,0] if rects have the same dimensions)                         
			_piecesPos =  areaDiv.createDivisionsWithoutBlanks(nPieces, 0); //Factor homogeneidad: 0..1 (0: totalmente homogeneo, 1: variable máximo -cercano a w homogeneo-)             omposite: ImaBitmapSheetDirect = new ImaBitmapSheetDirect(_imgComp.getBmp(), _w, _h);
			
			
			//Create the defined pieces 
			_numPieces = _piecesPos.length / 4;  //4: x,y,w,h
			_pieces = new Vector.<Piece>(_numPieces); 
			for (var i:uint = 0; i < _numPieces; i++) { 
				var pos:uint = i * 4; 
				_pieces[i] = new Piece2(i, _piecesPos[pos + 2], _piecesPos[pos + 3]);        //create piece setting dst w and dst h 
				_pieces[i].x = _piecesPos[pos];                //Set x local position in puzzle, require to calculate dst position 
				_pieces[i].y = _piecesPos[pos + 1];        //Set x local position in puzzle, require to calculate dst position 			 

				//crear bitmapsheetdirect con un solo frame que coincide justamente con el recorte del número que se corresponde con la pieza en curso 
				//var bmpSheetPiece: ImaSubBitmapSheetDirect = new ImaSubBitmapSheetDirect(bmpSheetComposite.getTile(0), _piecesPos[pos + 2], _piecesPos[pos + 3], new Rectangle(Assets.IMG_VOWEL_WIDTH*2+_piecesPos[pos], _piecesPos[pos + 1], _piecesPos[pos + 2], _piecesPos[pos + 3])); //Tomamos solo el trozo de img (la pieza), como imagen única de todo el bitmpasheet 
			
				var bmpSheetPiece: ImaSubBitmapSheetDirect = new ImaSubBitmapSheetDirect(_bmp, _piecesPos[pos + 2], _piecesPos[pos + 3], 
				new Rectangle(_piecesPos[pos], _piecesPos[pos + 1], _piecesPos[pos + 2], _piecesPos[pos + 3])); //Tomamos solo el trozo de img (la pieza), como imagen única de todo el bitmpasheet 
			
				
				
				//create anim with only 1 image 
				//TODO: apply any bevel filter??
				_pieces[i].addAnimation("InBox", bmpSheetPiece, null, [0]); //necesario null y [0] ?? 
				
				_pieces[i].addAnimation("InPuzzle", bmpSheetPiece, null, [0]); 
			}
			     			
		}
		
		
		private function dynamicCreationPieces(inDif: int): Vector.<uint> {
			var _piecesPos: Vector.<uint> = new Vector.<uint>;
			_piecesPos.push(32, 0, 96, 96,  64, 96, 64, 64,  32, 160, 128, 64);	//x,y, dstw, dsth
			return _piecesPos;
		}
		
		/**
		 * Create a list of destination positions for the list of pieces, based in 0,0 local origin.
		 */
		private function createDstPositions():void {	
			_dstPos = new Vector.<Point>(_numPieces);			
					
			for (var i:uint = 0; i < _numPieces; i++) {
				_dstPos[i] = new Point(_pieces[i].x + _pieces[i].w * 0.5, _pieces[i].y + _pieces[i].h* 0.5);	//Adjust registration point to center for each position
			}						
		}
		
		
		/**
		 * Creates a list of objects to let check wich piece/s map to each dst position
		 */
		private function mapPiecesToPositions():void {
			_dstMapPiece = new Vector.<uint>(_numPieces);
			for (var i:uint = 0; i < _numPieces; i++) {
				_dstMapPiece[i] = i;
			}			
		}
		
		
		/* INTERFACE com.imagame.game.IPieceCreator */
		
		public function createPuzzle():AbstractPuzzle 
		{
			return (new Puzzle2(0, _pieces, _dstPos, _dstMapPiece, _bmp));    
		}
		
		public function getPieces():Vector.<Piece> 
		{
			return _pieces; 
		}
		
		public function destroy():void 
		{
			
		}
		
	}

}