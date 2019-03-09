package com.imagame.game 
{
	import com.greensock.TweenLite;
	import com.imagame.engine.ImaSprite;
	import com.imagame.engine.Registry;
	import com.imagame.fx.ImaFx;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	/**
	 * ...
	 * @author imagame
	 */
	public class Piece1 extends Piece 
	{
		private var _idxInCat: uint;
		
		public function Piece1(id:uint, category:uint, idxInCat: uint) 
		{
			super(id, category);
			_idxInCat = idxInCat;
			
			
		}
		
		//***************************************************** Getters/Setters 
		
		public function get idxInCat():uint {
			return _idxInCat;
		}
		
		//*************************************** Interactive actions 
		 
		/**
		 * Check if the piece is selectable 
		 * @return	True if situated in Box in visible state
		 */
		protected function chkSelectable():Boolean { 
			return _sit == SIT_BOX_IN && !_bSelected && _sts != STS_FINISHED;
			//return (_sit == SIT_BOX_IN) && !_bSelected; // o cambiar por && _sts != STS_FINISHED 
		} 
		
		override public function doStartDrag(e:MouseEvent):void {         
			if(chkSelectable()) { 
				_bSelected = true; 
				playAnimation("InPuzzle");
				Assets.playSound("Piece1sel");

				//_rectDrag.setTo(8, 0, Registry.gameRect.width - getWidth(), Registry.gameRect.height - getHeight());
				//startDrag(false, _rectDrag); 
				startDrag();
							
				setZ( -1); //set it on top of the rest of in-Box pieces
				
				//send BodyPartSelect message to box and to puzzle
				((Registry.game.getState() as GameState).box as Box1).onBodyPartSelect(this); 				
				((Registry.game.getState() as GameState).puzzle as Puzzle1).onBodyPartSelect(this); 
			} 
		} 
		
		override public function doStopDrag(e:MouseEvent):void { 
			if(_bSelected){
				stopDrag(); 	
				if (chkDropPosition())        //Check if drop in a valid dst position, if true set it there and kill it. 
					Assets.playSound("Piece1ok");
				else
					Assets.playSound("Piece1ko");
			}
		} 
		
		
		override public function doTouchBegin(e:TouchEvent):void {   
			if(chkSelectable()) { 
				_bSelected = true; 
				playAnimation("InPuzzle");
				Assets.playSound("Piece1sel");

				//_rectDrag.setTo(8, 0, Registry.gameRect.width - getWidth(), Registry.gameRect.height - getHeight());
				startTouchDrag(e.touchPointID); // , false, _rectDrag); 
							
				setZ( -1); //set it on top of the rest of in-Box pieces
				
				//send BodyPartSelect message to box and to puzzle
				((Registry.game.getState() as GameState).box as Box1).onBodyPartSelect(this); 				
				((Registry.game.getState() as GameState).puzzle as Puzzle1).onBodyPartSelect(this); 		
			}
		} 
		
		override public function doTouchEnd(e:TouchEvent):void { 
			if(_bSelected){
				stopTouchDrag(e.touchPointID); 
				if (chkDropPosition())        //Check if drop in a valid dst position, if true set it there and kill it. 
					Assets.playSound("Piece1ok");
				else
					Assets.playSound("Piece1ko");
			}
		} 
		
		/**
		 * Check if the current position of the piece matches a correct puzzle position. 
		 * If true puts the piece in puzzle and remove from box
		 * If false returns the piece to its source position in box
		 */
		private function chkDropPosition():Boolean { 
			_dstPos = (Registry.game.getState() as GameState).puzzle.chkCorrectDstPos(x + width * 0.5, y + height * 0.5, this);               
							
			if(_dstPos != null) {  //If drop position is correct on behalf on group dropping condition 
				if(Registry.bTween) 
					onTweenDropPositionOk(); //        
				else 
					chkDropPositionEndOk(); 
				return true;
			}else { 
				if(Registry.bTween) 
					onTweenDropPositionKo(); //Tween from current pos to src pos                           
				else 
					chkDropPositionEndKo();  
				return false;
			}                 
		}
		
		private function chkDropPositionEndOk():void { 	
			//If current _dstPos is occupied by other piece, send it to inbox 
			var piece: Piece = (Registry.game.getState() as GameState).puzzle.retrieveByDstPos(_dstPos); 
			if (piece != null) { 
				(piece as Piece1).ActionMoveFromPuzzleToBox();
			} 			
			//Put piece in puzzle and remove from box
			ActionMoveFromBoxToPuzzle(_dstPos); 
			((Registry.game.getState() as GameState).puzzle as Puzzle1).onBodyPartRestore(this); 
		} 
		
		//restore gfx, and pos relative to its dimension, in In-Box
		private function chkDropPositionEndKo():void { 
			playAnimation("InBoxEnabled");
			updDim();			
			setPos(_srcPos.x, _srcPos.y);
			_bSelected = false;                  
			 
			//send BodyPartRestore message to box and to puzzle
			((Registry.game.getState() as GameState).box as Box1).onBodyPartRestore(this); 				
			((Registry.game.getState() as GameState).puzzle as Puzzle1).onBodyPartRestore(this); 
		}
		public function onTweenDropPositionOk():void { 
			TweenLite.to(this, 0.4, { x:_dstPos.x - width * 0.5, y:_dstPos.y - height * 0.5, onComplete: chkDropPositionEndOk } ); 
		} 
		public function onTweenDropPositionKo():void { 
			TweenLite.to(this, 0.25, { x:_srcPos.x-width*0.5, y:_srcPos.y-height*0.5, onComplete: chkDropPositionEndKo} ); 
		} 
		
		/**
		 * Puts the piece in a puzzle position defined by parameter 
		 * @param	dstGlobalPos
		 */
		public function ActionMoveFromBoxToPuzzle(dstGlobalPos: Point):void { 
			(Registry.game.getState() as GameState).box.removePieceFromBox(this); 
			(Registry.game.getState() as GameState).puzzle.setPieceInPuzzle(this,dstGlobalPos); 
			if(Registry.bFx) 
				ActionMoveFromBoxToPuzzleFxInit(); 
			else 
				ActionMoveFromBoxToPuzzleEnd(); 
		}                 
		protected function ActionMoveFromBoxToPuzzleEnd():void {
			 _sts = STS_FINISHED;  //change piece state to FINISHED(Important: To change its state to ACTIVE if piece is replaced later) 
			_bSelected = false; 
		} 	
		protected function ActionMoveFromBoxToPuzzleFxInit():void { 
			ImaFx.imaFxZoomIn((Registry.game.getState() as GameState).puzzle, this, 1.4, 0.1, true, ActionMoveFromBoxToPuzzleFxEnd); 
		} 
		protected function ActionMoveFromBoxToPuzzleFxEnd():void { 
			ActionMoveFromBoxToPuzzleEnd(); 
		} 
                		
		public function ActionMoveFromPuzzleToBox():void { 
			(Registry.game.getState() as GameState).puzzle.removePieceFromPuzzle(this);                                 
			(Registry.game.getState() as GameState).box.setPieceInBox(this); 
			_sts = STS_ACTIVE; 
		} 

		override public function update():void { 
			//llamada a super.update() para tratar cambios estados crear->init y muriendo->muerto			
			super.update(); 
		}  
	}

}