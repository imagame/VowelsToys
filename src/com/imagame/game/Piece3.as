package com.imagame.game 
{
	import com.greensock.TweenLite;
	import com.imagame.engine.Registry;
	import com.imagame.fx.ImaFx;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	/**
	 * ...
	 * @author imagame
	 */
	public class Piece3 extends Piece 
	{
		
		public function Piece3(id:uint, group:uint, size: Point) 
		{
			super(id, group);
			_w = size.x;
			_h = size.y;			
		}
		
		//*************************************** Interactive actions 
		 
		/**
		 * Check if the piece is selectable 
		 * @return	True if situated in Box in visible state
		 */
		protected function chkSelectable():Boolean { 
			return (_sit == SIT_BOX_IN) && !_bSelected; // o cambiar por && _sts != STS_FINISHED 
		} 

		
		override public function doStartDrag(e:MouseEvent):void {         
			if(chkSelectable()) { 
				_bSelected = true; 
				Assets.playSound("Piece3sel");
				startDrag(false,_rectDrag); 
			} 
		} 
		
		override public function doStopDrag(e:MouseEvent):void { 
			stopDrag(); 
			
			chkDropPosition();        //Check if drop in a valid dst position, if true set it there and kill it. 
			//_bSelected = false; 
		} 
		
		
		
		
		override public function doTouchBegin(e:TouchEvent):void {   
			if(chkSelectable()) { 
				_bSelected = true;    
				Assets.playSound("Piece3sel");
				startTouchDrag(e.touchPointID, false, _rectDrag);
			}
		} 

		override public function doTouchEnd(e:TouchEvent):void { 
			stopTouchDrag(e.touchPointID); 
			chkDropPosition();        //Check if drop in a valid dst position, if true set it there and kill it. 
		} 
		
		
		/**
		 * Check if the current position of the piece matches a correct puzzle position. 
		 * If true puts the piece in puzzle and remove from box
		 * If false returns the piece to its source position in box
		 */
		private function chkDropPosition():void { 
			_dstPos = (Registry.game.getState() as GameState).puzzle.chkCorrectDstPos(x + width * 0.5, y + height * 0.5, this);               
							
			if (_dstPos != null) {  //If drop position is correct on behalf on group dropping condition 
				if(Registry.bTween) 
					onTweenDropPositionOk();         
				else 
					chkDropPositionEndOk();                                 
			}else { 
				Assets.playSound("Piece3ko");
				_bSelected = false;                                 
			}                 
		} 
		private function chkDropPositionEndOk():void { 
			ActionMoveFromBoxToPuzzle(_dstPos); 
		} 
		public function onTweenDropPositionOk():void { 
			TweenLite.to(this, 0.4, { x:_dstPos.x - width * 0.5, y:_dstPos.y - height * 0.5, onComplete: chkDropPositionEndOk } ); 
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
			Assets.playSound("Piece3ok");			
			
			//_sts = STS_FINISHED; 
			_sts = STS_DYING; //We kill the piece since it will not be painted in the puzzle
			
			_bSelected = false; 
			//Alternative for box end-condition: signal to notify a piece is moved from box to puzzle 
			//signalPieceMove.dispatch(this); => no importa 
		} 	
		protected function ActionMoveFromBoxToPuzzleFxInit():void { 
			playAnimation("InBox");
			ImaFx.imaFxZoomIn((Registry.game.getState() as GameState).puzzle, this, 2.4, 0.1, true, ActionMoveFromBoxToPuzzleFxEnd); 
		} 
		protected function ActionMoveFromBoxToPuzzleFxEnd():void { 
			playAnimation("InPuzzle");
			ActionMoveFromBoxToPuzzleEnd(); 
		} 
             		
	}

}