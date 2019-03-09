package com.imagame.game 
{
	import com.imagame.utils.ImaUtils;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * Box for Puzzle type 3
	 * @author imagame
	 */
	public class Box3 extends AbstractBox 
	{
		private var _numPieces: uint;
		private var _boxRect: Rectangle = new Rectangle(); //Rectangle that defines the box area
		private var _auxPoint: Point = new Point();
		
		
		/**
		 * Box3 constructor
		 * @param	id		5..9 (a,e,i,o,u)
		 * @param	pieces	
		 */
		public function Box3(id:uint, pieces:Vector.<Piece>, boxRect:Rectangle) 
		{
			super(id, pieces); 
			trace("ABSTRACTBOX >> Box3() " + id);
								
			_numPieces = pieces.length;
			_boxRect.copyFrom(boxRect);		
		}

		override public function destroy():void { 
			//TODO delete components
			_auxPoint = null;
			_boxRect = null;
			super.destroy(); 
		} 
		
		
		/** 
		* Initializes pieces contained in box (position and visible status) 
		*/ 
		override public function init():void {  
			//Apply default init piece method to all pieces
			for (var i:uint = 0; i < _members.length; i++) { 
				(_members[i] as Piece).init(); 
			} 
			
			//Assign all pieces to inbox
			var xoffset:uint = 16;
			var yoffset:uint = 0;
			for (var p:uint = 0; p < _numPieces; p++) {
				var piece:Piece = retrieve(p) as Piece;
				
				//Set a random position inside the board			
				//TODO: If necessary, Ads.size.y can be substracted from _boxRect.height, to avoid locate a piece inside the ad area (in practice is very difficult)
				_auxPoint.x = (uint)(ImaUtils.randomize(_boxRect.x + xoffset + piece.w , _boxRect.width - piece.w - xoffset)); 
				_auxPoint.y = (uint)(ImaUtils.randomize(_boxRect.y + yoffset + piece.h , _boxRect.height - piece.h - yoffset)); 
				
				piece.setSrcPos(_auxPoint);						//TODO: Set src point randomly in board, ensurign piece completelly fits in board dimensions
				piece.playAnimation("PreInBox",true); 
				piece.updPutInBox(); 
				
				piece.setDragArea(_boxRect);
			}
					 					
			super.init();        //Move on active state 
		} 
 
		
				
		/** 
		 * Update group sprites execution: call each sprite update() method, and chk exit group condition 
		 */                 
		override public function update():void { 
			super.update();  ///std behavior: para cada sprite de _members llama a update() 
				
			//Check if final condition is just met (if all piece sprites are positiones in dst positions) 
			if(_sts != STS_FINISHED) { 
				if (_members.length == 0){ //final condition: TODO (all have been put in puzzle)
					trace("BOX3 End condition met!!");
					_sts = STS_FINISHED;																
				} 
			} 
		} 			
		
	}

}