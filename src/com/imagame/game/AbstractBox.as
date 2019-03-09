package com.imagame.game 
{
	import com.imagame.engine.ImaSpriteGroup;
	import com.imagame.engine.Registry;
	import flash.geom.Point;
	
	/** 
	 * Box of puzzle pieces 
	 * Goal: Container of sprites (puzzle pieces) waiting to be dragged to the puzzle board 
	 * Functionality added to ImaSpriteGroup: 
	 * - Receive and add all the puzzle pieces to the container 
	 * - Initialize status and screen position of pieces 
	 * - Set the animation behaviour of each piece 
	 * @author imagame 
	 */ 
	public class AbstractBox extends ImaSpriteGroup 
	{				
		protected var _puzzle: AbstractPuzzle;
		protected var _pieceCategory: Vector.<uint>;	//Vector of differente piece categories values (piece.category)
		protected var _numCategories: uint; 			//Number of pieces categories (num of 'adjusted' elements in _pieceCategory)
		
		protected var _pieceSameWidth: Boolean;        	//True if all pieces width is the same 
		protected var _pieceSameHeight: Boolean;        //True if all pieces height is the same 
		protected var _pieceMaxWidth: uint;         
		protected var _pieceMaxHeight: uint; 
                
		
		//Structures for InBox pieces
		protected var _srclist: Vector.<Point>;    	//List of source positions, with centered registration point 
		protected var _srcId: Vector.<int>; 		//Ids of members occupying source positions (may be all, may be a subset) (-1 if not occupied)

		
		public function AbstractBox(id:uint, pieces: Vector.<Piece>) 
		{
			super(id);
			trace("IMASPRITEGROUP >> AbstractBox() " + id);
			
			//add and assign all pieces to the out box
			for (var i:uint = 0; i < pieces.length; i++) { 
				add(pieces[i]); 
				pieces[i].updPutOutBox();	
				pieces[i].setGroup(this)
			}  
			
			//Retrieve all the differente categories of pieces
			_pieceCategory = new Vector.<uint>;
			for each (var piece:Piece in pieces) 
				if (_pieceCategory.indexOf(piece.category) == -1)
					_pieceCategory.push(piece.category);
			
			//Retrieve piece dimensions
			getPieceSizes(pieces);
		} 		
		
		override public function destroy():void {
			if(_srclist != null) {
				for (var i:int = 0; i < _srclist.length; i++){ 
					_srclist[i] = null; 
				} 
				_srclist = null;
			}
			_srcId = null; 
			_pieceCategory = null;
			super.destroy(); 
		} 
		
		//--------------------------------------------------- getters/setters 
		
		
		public function setRefPuzzle(puzzle: AbstractPuzzle):void { 
			_puzzle = puzzle; 
		} 
 		
		/** 
		* Detect piece dimension (max w,h size, and same or different sizes) 
		*/ 
		protected function getPieceSizes(pieces: Vector.<Piece>):void{ 
			var w:uint = pieces[0].width; 
			var h:uint = pieces[0].height; 
			_pieceSameWidth = _pieceSameHeight = true; 
			
			for each (var piece:Piece in pieces){ 
				if(_pieceSameWidth && piece.width != w) 
					_pieceSameWidth = false; 
				if(_pieceSameHeight && piece.height != h) 
					_pieceSameHeight = false;                                         
				if(piece.width > w) 
					w = piece.width; 
				if(piece.height > h) 
					h = piece.height;                                         
			} 
			_pieceMaxWidth = w; 
			_pieceMaxHeight = h;                 
		} 
		
		protected function get pieceMaxWidth():uint {                         
			return _pieceMaxWidth; 
		} 
		
		protected function get pieceMaxHeight():uint { 
			return _pieceMaxHeight; 
		} 

		
		/*-------------------------------------------------------------------------- Piece operations */

		/**
		 * Put a piece in the Box (to be overriden by a subclass to: put in box if applies, assign anim, assign src pos,...)
		 * - By default it will be put out of the box (not visible)
		 * @param	piece
		 */
		public function setPieceInBox(piece: Piece):void { 
			add(piece); 
			piece.updPutOutBox();	
			piece.setGroup(this); 
		} 
		
		/**
		 * To be override by subclass to manage _srcId update after removing a inBox piece
		 * @param	piece
		 */
		public function removePieceFromBox(piece: Piece): void { 
			remove(piece); 
		} 
		
		
		public function retrieveByCategory(cat: uint):Piece { 
			for (var i:uint = 0; i < _members.length; i++) {
				if ((_members[i] as Piece).category == cat) 
					return (_members[i] as Piece); 				
			}
			return null;                    
		} 

		public function retrieveByIdx(idx:uint):Piece { 
			if (idx < _members.length)
				return (_members[idx] as Piece); 	
			else
				return null; 
		} 

		
	}

}