package com.imagame.game 
{
	import com.imagame.engine.ImaSpriteGroup;
	import com.imagame.engine.Registry;
	import com.imagame.utils.ImaBitmapSheet;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/** 
	 * Group of pieces forming a puzzle 
	 * Goal: 
	 * Functionality added to ImaSpriteGroup: 
	 * - D.. 
	 * Consequences: 
	 * - F.. 
	 * @author imagame 
	 */ 
	public class AbstractPuzzle extends ImaSpriteGroup 
	{
		protected var _box: AbstractBox;
		
		//default puzzle structures (pieces are stored in _members ImaSpritegroup array)
		protected var _numPieces: uint //Number of puzzle pieces in all the rounds 		
		protected var _dstLocalPos: Vector.<Point>;		//List of local dst positions for all the rounds (center reg point), within the _bmp puzzle image
		protected var _dstGlobalPos: Vector.<Point>;	//List of global dst positions within the gamerect screen (center reg point)
		protected var _dstMapPiece: Vector.<uint>;        //Mapping condition between piece id, and dst positions 
		
		//auxiliar structures
		protected var _dststslist: Vector.<uint>;	//List of dst positions state (0: free, 1: occupied with piece, 2: occupied by default with nothing -closed position-) 
		public static const DSTSTS_FREE: uint = 0; 
		public static const DSTSTS_OCCUPIED: uint = 1; 
		public static const DSTSTS_UNUSABLE: uint = 2;  
		protected var _dstRadio: Vector.<Point>;	//List of Points radio distances for all the pices, to check correcto drop position
		
		
		/** 
		 * Abstract Puzzle
		 * Create a puzzle of connected/disconnected pieces 
		 * @param		id        Puzzle identificator
		 * @param		pieces    List of pieces  
		 * @param		dstPos		List of destination points to locate the pieces
		 * @param		dstSize		List of sizes for each pos
		 * @param 		dstMapPiece	List of attributes to map a destination point with 1/N pieces
		 */ 
		public function AbstractPuzzle(id:uint, pieces: Vector.<Piece>, dstPos: Vector.<Point>, dstMapPiece: Vector.<uint>) 
		{ 			
			super(id);                         
			 _numPieces = createPuzzleImage(pieces); //Create tilesheet and bmp images, and set x and y puzzle image position 
			
			_dstLocalPos = dstPos.map(pointCloner);
			_dstGlobalPos = (dstPos.map(pointCloner)).map(local2global);
			_dstMapPiece = dstMapPiece.concat();
		
			createAuxStructures(pieces);	//compone _dstlist e inicializa _dststslist. _members queda a null, sin piezas por defecto 			
		} 
		
		
		override public function destroy():void { 
			for (var i:int = 0; i < _numPieces; i++){
				_dstLocalPos[i] = null;
				_dstGlobalPos[i] = null;
			}
			_dstLocalPos = null;
			_dstGlobalPos = null;
			_dststslist = null;

			_dstMapPiece = null;
			//TODO destroy rounds
			
			removeChild(_bmp);
			_bmp = null;
			
			super.destroy(); 
		}
		
		override public function init():void {  
			//[DBG] Show dst debug positions
			var s:GameState = (Registry.game.getState() as GameState);
	/*		s.dbgInit();
			for (var i:uint = 0; i < _numPieces; i++) {
				s.dbgDrawRect(_dstGlobalPos[i].x-16, _dstGlobalPos[i].y-16, 32, 32);	//TODO: override para hacerlo dependiente de forma/tamaño de piezas de cada puzzle
			}*/
			super.init()
		} 
		
		/**
		 * Create puzzle image and set it in the display list
		 */
		protected function createPuzzleImage(pieces: Vector.<Piece>):uint { 
			var s:GameState = (Registry.game.getState() as GameState);
			_tileSheet = new ImaBitmapSheet(Assets.vowelImages[s.phase], Assets.IMG_VOWEL_WIDTH, Assets.IMG_VOWEL_HEIGHT);
			_bmp = _tileSheet.getTile(s.id); 
            addChild(_bmp);
 
			x = (uint)((Registry.gameRect.width - _bmp.width) * 0.5);	//uint: fuerza quitar decimales
			y = (uint)(Registry.appUpOffset + 16); 

			return pieces.length;
		} 
		
		/** 
		* Create auxiliar structures required to check correct piece dst position (To be overriden by puzzle class) 
		*/           
		protected function createAuxStructures(pieces: Vector.<Piece>):void { 
			_dstRadio = new Vector.<Point>(_numPieces);
			_dststslist = new Vector.<uint>(_numPieces);
			
			for(var i:uint; i<_numPieces; i++){ 
				_dstRadio[i] = new Point((uint)(pieces[i].w * 0.5),(uint)(pieces[i].h * 0.5)) ; // 16;	//TODO
				_dststslist[i] = DSTSTS_UNUSABLE; //By default all are unusable. To be overriden as free or occuppied in the subclass
			} 
		} 
       		
		
		//-------------------------------------------------------------------------- Getters/Setters
		
		public function setRefBox(box: AbstractBox):void { 
			_box = box; 
		} 
		
		
		public function getIdPiecesList():Vector.<int> { 
			var v: Vector.<int> = new Vector.<int>(_numPieces); 
			for each (var p:Piece in _members) { 
				v[p.category] = p.id;                                 
			} 
			return v; 
		} 
	
		public function getPosPiecesList():Vector.<int> { 
			var v: Vector.<int> = new Vector.<int>(); 
			for each (var p:Point in _dstLocalPos) { 
				v.push(p.x, p.y);                                 
			} 
			return v;                         
		} 
        
		
		
		public function getIdxGlobalPos(pos: Point):int {
			for (var i:uint = 0; i < _numPieces; i++)
				if (_dstGlobalPos[i].equals(pos))
					return i;
			return -1;
		}
		
		public function retrieveByDstPos(pos: Point):Piece { 
			for (var i:uint = 0; i < _members.length; i++) {
				var piece: Piece = (_members[i] as Piece);
				var dstpos = piece.getDstPos();
				if (dstpos.equals(pos)) 
					return (_members[i] as Piece); 
			} 
			return null;
			
			/*
			for (var i:uint = 0; i < _members.length; i++) {
				
				if ((_members[i] as Piece).getDstPos().equals(pos)) 
					return (_members[i] as Piece); 
			} 
			return null;   */                      
		} 
                
                
		public function retrieveByDstPosIdx(idx: int):Piece { 
			if(idx <0 || idx >= _numPieces) 
				return null; 
			else 
				return retrieveByDstPos(_dstGlobalPos[idx]); 
		}		
		
                
		/**
		 * To be overriden by subclass. To determine if clicked on a piece (it requires knowledge of pieces shape and position)
		 * @param	e	MouseEvent
		 */
		override public function doClick(localX:Number, localY:Number):void {
		}
		
		/*-------------------------------------------------------------------------- Piece operations */

		/**
		 * Put a valid piece in the puzzle in a given free position (assumes the piece matches the position)
		 * @param	piece	Piece to put in the puzzle
		 * @param	dstPos	Correct global dst position. (If called from Box it will be also sent this paramenter thought dst pos is already set (global Pos)
		 */
		public function setPieceInPuzzle(piece: Piece, dstPos: Point):void { 
			var idx:int = getIdxGlobalPos(dstPos);	//check if dst pos is correct (exist in puzzle)
			if (idx < 0)
				trace("<<ERR>>: AbstractPuzzle->SetPieceInPuzzle  (dstPos not found in _dstGlobalPos)");
			//trace(">>>>>>>>>>>>>>>> SetPieceInPuzzle: idx:" + idx + " dstPos: " + dstPos.x + "," + dstPos.y+"  localPos:"+_dstLocalPos[idx].x+","+_dstLocalPos[idx].y);
				
			setDstPosStatus(idx, false);
			add(piece); //assumed the piece is already removed from the box list
			
			//update piece data
			
			piece.playAnimation("InPuzzle", true, 0); // idx);	//utiliza idx para calcular frame, llamando a func pasad por parametro
			piece.updPutInPuzzle();
			piece.setDstPos(dstPos);
			piece.setGroup(this);
			piece.setPos(_dstLocalPos[idx].x, _dstLocalPos[idx].y);  //set local pos inside abstractpuzzle, but keeps _srcPos with its value (global src pos) 
		} 
		
		/** 
		 * Set a piece in Puzzle in a given position index 
		 * @param        piece        Piece to put in puzzle 
		 * @param        idx                _dstGlobalPos idx position to put the piece 
		 */ 
		public function setPieceInPuzzlePos(piece: Piece, idx: int):void { 
			if(idx < 0 || idx >= _dstGlobalPos.length) { 
				trace("<<ERR>>: AbstractPuzzle->SetPieceInPuzzle  (dstPos not found in _dstGlobalPos)"); 
				return; 
			} 
			setPieceInPuzzle(piece, _dstGlobalPos[idx]); 
		} 
  

		/**
		 * Removes a piece <piece> from its destination position <idx> (only required one of both parameters)
		 * Restores the initial puzzle background area in the position where the <piece> is located, or in the pos <idx>
		 * @param	piece	Piece located in a puzzle position 
		 * @return	index of the position where the piece was located. -1 if the pieces was not located in any puzzle position
		 */
		public function removePieceFromPuzzle(piece: Piece):int {        //Se usará al restablecer huecos por fallar al poner pieza (marcar hueco) de color incorrecto               
			var idx:int = getIdxGlobalPos(piece.getDstPos()) 
			if (idx == -1) {
				return -1
			}
			else{
				setDstPosStatus(idx, true); 
				remove(piece); //pasa a no mostrarse el _bmp 
				//piece.updPutOutPuzzle(); 
				return idx;
			}		
		} 
		
		/** 
		*        @param        removeCB        Callback Function to be called for each removed piece 
		*/ 
		public function removeAllPiecesFromPuzzle(removeCB: Function):uint { 
			return 0; 
		}    

		
		/**
		 * Set a (the) valid piece in a given position. To be used when the piece is unknown, just knowing the position where a piece has to be located.
		 * @param	idx	Index of the position to locate the piece
		 * @return	Piece just located in the puzzle, or null if the <index> is occupied
		 */
/*
		 public function setPieceInPuzzlePos(idx: uint):Piece {
			//Check if there is piece set in pos
			if (_dststslist[idx] == DSTSTS_FREE) { //if pos is free
				//averiguar que pieza encaja en una posicion dada
				var piece: Piece = getMapPiece(idx);
				//quitar de Box y añadir a Puzzle
				_box.removePieceFromBox(piece);
				setPieceInPuzzle(piece, _dstGlobalPos[idx]);
				return piece;
			}
			else 
				return null;
		}
	*/
		
		/**
		 * 
		 * @param	idx
		 * @return
		 */
		public function removePieceFromPuzzlePos(idx: uint):Piece {
			var piece: Piece = retrieveByDstPos(_dstGlobalPos[idx]);
			if (piece == null)
				trace("<<ERR>>: removePieceFromPuzzlePos() idx:" + idx + " _dstGlobalPos: " + _dstGlobalPos[idx].x + ","+_dstGlobalPos[idx].y);
			
			idx = removePieceFromPuzzle(piece); 
			if (idx == -1)
				return null;
			else
				return piece;
		}
		
		//Detecta el tipo de pieza que encaja en una posición y retorna una pieza válida (pieza libre en box)
		protected function getMapPiece(idx: uint): Piece {
			if(_dststslist[idx] == DSTSTS_FREE) //if position free pieces is in box
				return ((Registry.game.getState() as GameState).box.retrieve(_dstMapPiece[idx]) as Piece);
				//TODO retrieve por tipo, y no por id. (box.retrieveByType(_dstMapPiece[idx])
			else if (_dststslist[idx] == DSTSTS_OCCUPIED)	
				return (retrieve(_dstMapPiece[idx]) as Piece);
			else 
				return null;
		}
		
		
		
		
		/** 
		* Return a list of pieces not located in dst position 
		*/ 
		/*
		public function getFreePieces(): Vector.<Piece> { 
			var pieces:Vector.<Piece> = new toVector(_members);   
			//elimina las piezas colocadas por defecto 
			for(var i:uint; i<pieces.length; i++) { 
					if(pieces[i].sts == SIT_PUZZLE) 
							pieces.delete[i]; 
			} 
			return pieces; 
		} 
   		*/
		
		/**
		 * Set dst position status (to free/to occupied), and paint dst box accordingly	
		 * @param	idx	Position index [0..N-1]
		 * @param	free	Boolean indicating free or occupied status
		 */
		protected function setDstPosStatus(idx: uint, free: Boolean):void {
			if (free) {
				_dststslist[idx] = DSTSTS_FREE;	//set dst status to free, and paint dst box accordingly				
			} else {
				_dststslist[idx] = DSTSTS_OCCUPIED;	//set dst status to free, and paint dst box accordingly
			}
			//_bmplist[idx].bitmapData = (_bmpPosSheet.getTile((_num -(_phase-1)*3 - 1) * 2 + _dststslist[idx])).bitmapData; //status 0: 1er png, status 1: 2ºpng		
		}
		
		
		
		/** 
		 * Check if drop position is valid, based on group dropping condition (distance < _radio) 
		 * Assumption: only one position must be valid at the same time 
		 * @param	x 
		 * @param  	y 
		 * @param 	piece	Piece that ask to check if located in correct position
		 * @return  True if pos (x,y) is a valid destination position 
		 */ 
        public function chkCorrectDstPos(x: Number, y: Number, piece: Piece, updSts: Boolean=false): Point { 
			//r: a que round pertenece la pieza: 
			//idx: indice secuencia relativa dentro del round r 
			//To check in _dstPos[_round[_roundAct] + idx] 
					   
			return null; 
		} 
		
		//------------------------------------------------------------------------ Utils
		
		protected function distance(x1: Number, y1: Number, x2: Number, y2: Number): Number { 
			var dx: Number = x1 - x2; 
			var dy: Number = y1 -  y2; 
			return Math.sqrt(dx * dx + dy * dy); 
		} 

		protected function pointCloner(item:Point, index:int, vector:Vector.<Point>):Point {
			return item.clone();
		}
		protected function local2global(item:Point, index:int, vector:Vector.<Point>):Point
		{
			item.offset(x, y);
			return item;
		} 

		

		
	}

}