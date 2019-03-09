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
	public class Piece2 extends Piece 
	{
		private var _idT1: TweenLite;

		public function Piece2(id:uint, w:uint=0, h:uint=0) 
		{
			super(id, 0);
			_w = w;
			_h = h;
			
		}
		
		override public function init():void {   
			visible = true; 
			playAnimation("InBox");  
			if(Registry.bTween){
				alpha = 0; 
				_idT1 = TweenLite.to(this, 2, { delay:_id * 0.2 + 2, alpha:1, onComplete: updPutInBox } ); 
				super.init();
				updPutInBox(); //ERR: para evitar tween que acabe antes que super.init
			}
			else {
				super.init();  //sit box out, visible false 
				updPutInBox();
			}
						
		} 
		
		override public function destroy():void  { 
			if(_idT1 != null) { 
				_idT1.kill(); 
				_idT1 = null; 
			} 
			super.destroy();
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
				Assets.playSound("Piece2sel");
				startDrag(false, _rectDrag); 
			} 
		} 
		
		override public function doStopDrag(e:MouseEvent):void { 
			stopDrag(); 			
			if (chkDropPosition())        //Check if drop in a valid dst position, if true set it there and kill it. 
				Assets.playSound("Piece2ok");
			else
				Assets.playSound("Piece2ko");
		} 
		
		
		
		
		override public function doTouchBegin(e:TouchEvent):void {   
			if(chkSelectable()) { 
				_bSelected = true; 
				Assets.playSound("Piece2sel");
				startTouchDrag(e.touchPointID, false, _rectDrag);    
			}
		} 

		override public function doTouchEnd(e:TouchEvent):void { 
			stopTouchDrag(e.touchPointID); 
			if (chkDropPosition())        //Check if drop in a valid dst position, if true set it there and kill it. 
				Assets.playSound("Piece2ok");
			else
				Assets.playSound("Piece2ko");
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
			ActionMoveFromBoxToPuzzle(_dstPos); 
		} 
		private function chkDropPositionEndKo():void {  
			setPos(_srcPos.x, _srcPos.y);
			//x = _srcPos.x-width*0.5; 
			//y = _srcPos.y-height*0.5; 
			_bSelected = false;                         
		}
		public function onTweenDropPositionOk():void { 
			TweenLite.to(this, 0.4, { x:_dstPos.x - width * 0.5, y:_dstPos.y - height * 0.5, onComplete: chkDropPositionEndOk } ); 
		} 
		public function onTweenDropPositionKo():void { 
			TweenLite.to(this, 0.25, { x:_srcPos.x-width*0.5, y:_srcPos.y-height*0.5, onComplete: function(){_bSelected = false;}} ); 
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
			_sts = STS_FINISHED; 
			_bSelected = false; 
			//Alternative for box end-condition: signal to notify a piece is moved from box to puzzle 
			//signalPieceMove.dispatch(this); => no importa 
		} 	
		protected function ActionMoveFromBoxToPuzzleFxInit():void { 
			ImaFx.imaFxZoomIn((Registry.game.getState() as GameState).puzzle, this, 1.4, 0.1, true, ActionMoveFromBoxToPuzzleFxEnd); 
		} 
		protected function ActionMoveFromBoxToPuzzleFxEnd():void { 
			ActionMoveFromBoxToPuzzleEnd(); 
		} 
                
			
	}

}