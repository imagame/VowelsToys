package com.imagame.engine 
{
	import com.greensock.TweenLite;
	import com.imagame.game.MenuState;
	import com.imagame.utils.IImaBitmapSheet;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author imagame
	 */
	public class ImaIcon extends ImaSpriteAnim
	{
		protected var _rectDrag: Rectangle = new Rectangle();
		protected var _chkDropCB: Function;
		protected var _dropOkCB: Function;
		protected var _dropKoCB: Function;
		
		protected var _bSelected: Boolean = false;        //Selected by touch event 
		protected var _srcPos:Point;	//source pos at the start of draggin operation
		protected var _dstPos: Point;	//Destination point for dragging icon

			
		/**
		 * Icon constructor
		 * @param	id
		 * @param	bmp
		 * @param	idxUp
		 * @param	idxDown
		 * @param	idxOver
		 * @param	rectDrag
		 * @param	chkDropCB
		 * @param	dropOkCB
		 * @param	dropkoCB
		 */
		/*
		 public function ImaIcon(id:int, bmp: Bitmap, idxUp: int=0, idxDown: int=-1, idxOver:int = -1, rectDrag: Rectangle=null, chkDropCB: Function = null, dropOkCB: Function = null, dropkoCB: Function = null) 
		{
			super(ImaSprite.TYPE_ICON, id);
			addChild(bmp);
		}
		
		override public function doClick(localX: Number, localY:Number):void {
			trace("ImaIcon->doClick()");
			
			Registry.game.switchState(new MenuState(0));
		}
		*/
		public function ImaIcon(id:int, bs: IImaBitmapSheet, aGfxIdx: Array)
		{
			super(ImaSprite.TYPE_ICON, id);
			addAnimation("icon", bs, null, aGfxIdx);
			//TODO: Add Anim behaviour to icon
			//addAnimation("iconAnim", bs, null, aGfxIdx, null, 5, true);
			playAnimation("icon");
			
		}
		
		override public function destroy():void  {
			_srcPos = null;
			_dstPos = null;
			_rectDrag = null;
			super.destroy();
		}
		
		public function addDragBehaviour(rectDrag: Rectangle=null, chkDropCB: Function = null, dropOkCB: Function = null, dropkoCB: Function = null ):void {
			setDragArea(rectDrag);
			
			_chkDropCB = chkDropCB;
			_dropOkCB = dropOkCB;
			_dropKoCB = dropkoCB;
		}
		
		//------------------------------------ Dragging behaviour
		
		protected function setDragArea(rect: Rectangle):void{ 
			_rectDrag.copyFrom(rect); 
			_rectDrag.width -= _bmp.width;
		}
		
		
		override public function doStartDrag(e:MouseEvent):void {	
			_bSelected = true; 
			if(_srcPos==null)
				_srcPos = new Point(x, y);
			startDrag(false, _rectDrag);
		}
		
		override public function doStopDrag(e:MouseEvent):void {
			stopDrag();
			chkDropPosition();	//Check if drop in a valid dst position, if true set it there and kill it.
		}
				
		override public function doTouchBegin(e:TouchEvent):void { 	
			_bSelected = true; 
			if(_srcPos==null) 
				_srcPos = new Point(x, y);
			startTouchDrag(e.touchPointID, false, _rectDrag);                         
		} 

		override public function doTouchEnd(e:TouchEvent):void { 
			stopTouchDrag(e.touchPointID); 
			chkDropPosition();	
		}		
		
		
		private function chkDropPosition():void {
			_dstPos = _chkDropCB(x,y);
		
			if(_dstPos != null) {  //If drop position is correct on behalf on group dropping condition 
				//Tween de desplazamiento hasta centro pos dst y fade out 
				//_sts = STS_FINISHED;
				onTweenInitDropOk();	
			}else { 
				onTweenInitDropKo(); //Tween from current pos to src pos 
					         
			} 	
		
		} 
		
		
		public function onTweenInitDropOk():void {
			TweenLite.to(this, 0.4, { x:_dstPos.x, y:_dstPos.y, onComplete: _dropOkCB(_id) } ); 
			//on complete function with params: {onComplete:myFunction, onCompleteParams:[myVar]}
		}
		public function onTweenInitDropKo():void {
			TweenLite.to(this, 0.25, { x:_srcPos.x, y:_srcPos.y, onComplete: function() { _dropKoCB(_id);  _bSelected = false; }} );
		}
	
		
	}

}