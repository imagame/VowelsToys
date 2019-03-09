package com.imagame.game 
{
	import com.imagame.engine.Registry;
	import com.imagame.utils.ImaUtils;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author imagame
	 */
	public class Box2 extends AbstractBox 
	{
		private var _numPieces: uint;
		private var _boxRect: Rectangle = new Rectangle(); //Rectangle that defines the box area
		
		public function Box2(id:uint, pieces:Vector.<Piece>, boxRect:Rectangle) 
		{ 
			super(id, pieces); 
			trace("ABSTRACTBOX >> Box2() " + id);
								
			_numPieces = pieces.length;
			_boxRect.copyFrom(boxRect);
			setSrcPosList();        //Define src positions (but there is still no assignment to any piece) 	
		} 
		
		override public function destroy():void { 
			//TODO delete components
			super.destroy(); 
			_boxRect = null;
		} 
		
		/** 
		* Initializes pieces contained in box (position and visible status) 
		*/ 
		
		override public function init():void {         
			//Assign initial pos 
			_srcId = new Vector.<int>(_numPieces); 
			for (var p:uint = 0; p < _numPieces; p++) { 
					var piece:Piece = retrieve(p) as Piece; 
					_srcId[piece.id] = piece.id; 
					piece.setDragArea(_boxRect);
			} 
			ImaUtils.shuffle(_srcId); 
			for (var i:uint = 0; i < _numPieces; i++) { 
					var piece:Piece = retrieve(i) as Piece; 
					piece.setSrcPos(_srclist[_srcId[i]]); 
			} 

			//Init piece 
			//Apply default init piece method to all pieces 
			for (var i:uint = 0; i < _members.length; i++) { 
				(_members[i] as Piece).init(); //Piece2.init() ->sit box out, tween to get visible, when tween ends: sit_box_in and visible 
			} 
        }       
  		
/*		override public function init():void {  
			//Apply default init piece method to all pieces
			for (var i:uint = 0; i < _members.length; i++) { 
				(_members[i] as Piece).init(); 
			} 
			
			//select initial pieces to assign to InBox src positions: All the pieces 
			_srcId = new Vector.<int>(_numPieces); 
			for (var p:uint = 0; p < _numPieces; p++) {
				var piece:Piece = retrieve(p) as Piece;
				setPieceInBoxPos(piece, piece.id); 
				
				piece.setDragArea(_boxRect); //TEST
			}
			//Shuffle de scr positions in box 
			ImaUtils.shuffle(_srcId); 
			for (var i:uint = 0; i < _numPieces; i++) {
				var piece:Piece = retrieve(i) as Piece;
				piece.setSrcPos(_srclist[_srcId[i]]);
			}
					 					
			super.init();        //Move on active state 
		} */
 
		/** 
		 * Exit function called when moving from STS_DYING to STS_DEAD, or directly from gamestate exit func 
		 * Closed and consolidate logic data 
		 */ 
		override public function exit():void { 
			//TODO any actions on exit?? Any fx to stop??
		}   		

		/**
		 * Define de initial positions for sprites. Options: 1,2,3,4,5,6 (number of pieces in In-Box)
		 * To be executed once in the creation of the Box 
		 */
		private function setSrcPosList():void {   
			_srclist = new Vector.<Point>(_numPieces); 
			
			var numLe: uint = Math.floor(_numPieces/2); 
			var numRi: uint = _numPieces - numLe; 				
			if (_numPieces <= 6) 				
				setSrcPosList2Cols(numLe, numRi);
			else {
				var numLe1:uint = Math.floor(numLe / 2);
				var numLe2:uint  = numLe - numLe1;
				var numRi1:uint  = Math.floor(numRi / 2);
				var numRi2:uint  = numRi - numRi1;
				setSrcPosList4Cols(numLe1, numLe2, numRi1, numRi2);
			}
		}
		
		 /** 
		 * Define de initial positions for sprites. Options: 1,2,3,4,5,6 (number of pieces in In-Box)
		 * To be executed once in the creation of the Box 
		 */                		
		private function setSrcPosList2Cols(numLe:uint, numRi:uint):void {   				
			var boxAdjW: uint = 16;                        //pixels of w adjustment, to bring the piece (Src pos) close to the puzzle 
			var boxW: uint = (Registry.gameRect.width - Assets.IMG_VOWEL_WIDTH) * 0.5 
			var xle:uint = boxW * 0.5 + boxAdjW; 
			var xri:uint = boxW + Assets.IMG_VOWEL_WIDTH + boxW * 0.5 - boxAdjW; 
				
			var boxAdjH: uint = Registry.appUpOffset+26;                //pixels of h adjustment, to jump over the fixed initial space (16) and the HUD buttons h space (32) 
			var boxH: uint = (Assets.IMG_VOWEL_HEIGHT + 64);        //remove the fixed 32 pixels of HUD buttons 							
			var sepleY:uint = boxH / (numLe + 1);	//Alt: (boxH - pieceMaxHeight * numLe) / (numLe + 1);
			var sepriY:uint = boxH / (numRi + 1); 
				
			for(var i:uint = 0; i< numLe; i++){ 
				_srclist[i] = new Point(); 
				_srclist[i].x = xle; 
				_srclist[i].y = boxAdjH + sepleY * (i+1); 
			} 
			for(var i:uint = 0; i< numRi; i++){ 
				_srclist[i + numLe] = new Point(); 
				_srclist[i + numLe].x = xri; 				
				_srclist[i + numLe].y = boxAdjH + sepriY * (i + 1);
			}                         			
		}  	
		
		
		private function setSrcPosList4Cols(numLe1:uint, numLe2:uint, numRi1:uint, numRi2:uint):void {   
			var boxAdjW: uint = 0;                        //pixels of w adjustment, to bring the piece (Src pos) close to the puzzle 
			var boxW: uint = (Registry.gameRect.width - Assets.IMG_VOWEL_WIDTH) * 0.5 
			var xle1:uint = boxW * 0.3 + boxAdjW; 
			var xle2:uint = boxW * 0.7 + boxAdjW; 
			var xri1:uint = boxW + Assets.IMG_VOWEL_WIDTH + boxW * 0.3 - boxAdjW; 
			var xri2:uint = boxW + Assets.IMG_VOWEL_WIDTH + boxW * 0.7 - boxAdjW; 

			var boxAdjH: uint = Registry.appUpOffset+26;                //pixels of h adjustment, to jump over the fixed initial space (16) and the HUD buttons h space (32) 
			var boxH: uint = (Assets.IMG_VOWEL_HEIGHT + 64);        //remove the fixed 32 pixels of HUD buttons 							
			var seple1Y:uint = boxH / (numLe1 + 1);
			var seple2Y:uint = boxH / (numLe1 + 2);
			var sepri1Y:uint = boxH / (numRi1 + 1); 
			var sepri2Y:uint = boxH / (numRi1 + 2);
			
			var idx:uint = 0;
			for(var i:uint = 0; i< numLe1; i++){ 
				_srclist[idx] = new Point(); 
				_srclist[idx].x = xle1; 
				_srclist[idx].y = boxAdjH + seple1Y * (i + 1); 
				idx++;
			} 
			for(var i:uint = 0; i< numLe2; i++){ 
				_srclist[idx] = new Point(); 
				_srclist[idx].x = xle2; 				
				_srclist[idx].y = boxAdjH + seple2Y * (i + 1);
				idx++;
			}   
			for(var i:uint = 0; i< numRi1; i++){ 
				_srclist[idx] = new Point(); 
				_srclist[idx].x = xri1; 
				_srclist[idx].y = boxAdjH + sepri1Y * (i + 1); 
				idx++;
			} 
			for(var i:uint = 0; i< numRi2; i++){ 
				_srclist[idx] = new Point(); 
				_srclist[idx].x = xri2; 				
				_srclist[idx].y = boxAdjH + sepri2Y * (i + 1);
				idx++;
			} 
		}
			
		

		/*-------------------------------------------------------------------------- Getters / Setters */
		
		
		
		
		/*-------------------------------------------------------------------------- Piece operations */

		/**
		 * Add piece to Box, setting in box if there its category is not in box
		 * @param	piece	Piece to put in box
		 */
		override public function setPieceInBox(piece: Piece):void {
			super.setPieceInBox(piece);	//adds to Box if piece comes from outside (puzzle)
			setPieceInBoxPos(piece, piece.id); 
		}

		/**
		 * Set a piece in Box in a given position
		 * @param	piece	Piece to put in box
		 * @param	idx		In-Box idx position to put the piece
		 */
		private function setPieceInBoxPos(piece: Piece, idx: uint):void { 
			_srcId[idx] = piece.id; 
			piece.playAnimation("InBox"); 
			piece.updPutInBox(); 
			piece.setSrcPos(_srclist[idx]); 
		}   		
		
		/**
		 * Remove piece from in-box and replace it by one with the same category from out-box (if any exist)
		 * @param	piece
		 */
		override public function removePieceFromBox(piece: Piece): void { 
			super.removePieceFromBox(piece);	//remove the piece from the group			
			_srcId[piece.id] = -1;			
		} 
		
 

		
		//------------------------------------------------------------------- Callbacks
	             		
				
		/** 
		 * Update group sprites execution: call each sprite update() method, and chk exit group condition 
		 */                 
		override public function update():void { 
			super.update();  ///std behavior: para cada sprite de _members llama a update() 
				
			//Check if final condition is just met (if all face sprites are positiones in dst positions) 
			if(_sts != STS_FINISHED) { 
				if (_members.length == 0){ //final condition: TODO (all have been put in puzzle)
					//trace("BOX2 End condition met!!");
					_sts = STS_FINISHED;																
				} 
			} 
		} 		
	}

}