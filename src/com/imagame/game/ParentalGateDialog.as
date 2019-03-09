package com.imagame.game 
{
	import com.imagame.engine.ImaDialog;
	import com.imagame.engine.ImaIcon;
	import com.imagame.engine.ImaSprite;
	import com.imagame.engine.ImaState;
	import com.imagame.utils.ImaBitmapSheet;
	import com.imagame.utils.ImaCachedBitmap;
	import com.imagame.utils.ImaUtils;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Parental Gate dialog: Drag de correct shape to the destination position
	 * @author imagame
	 */
	public class ParentalGateDialog extends ImaDialog 
	{
		private static const NUM_SHAPES: uint = 3;
		
		private var _btShape: Vector.<ImaIcon>; //draggable buttons
		private var _aShape:Vector.<int>; //shape ids, for each one of the shapes shown in the dialog
		
		private static const XINI: uint = 32; 
		private static const XEND: uint = 180; 
		private static const YINI: uint = 58;
		private static const YSEP: uint = 16+Assets.IMG_ICONPARENTALDLG_HEIGHT;
		private var _rectDrag: Rectangle = new Rectangle(); 
		private var _auxPoint: Point = new Point();

		private var _shapeTxt: ImaIcon; //Shape goal text
		private var _bSetShape: Boolean; //Has a shape been dragged?
		private var _bShapeCorrect: Boolean;	//Was the dragged shape correct?
		private var _idxShapeGoal: int;	//Idx of correct shape to be dragged [0..NUM_SHAPES-1]
		
		protected var _touching: Array;
		
		public function ParentalGateDialog(id:uint, parentRef:ImaState) 
		{
			super(id, parentRef, 
				new ImaBitmapSheet(Assets.GfxIconsParentalGateDlg, Assets.IMG_ICONPARENTALDLG_WIDTH, Assets.IMG_ICONPARENTALDLG_HEIGHT), 
				[true, false, false], 
				[Assets.GfxDlgParentalGate, null, null]); 
			visible = false; 
			
			_aShape = new Vector.<int>(NUM_SHAPES);
			_aShape = getRandomShapes(NUM_SHAPES, Assets.NUM_SHAPEPARENTALDLG);//selecte NUM_SHAPES random number between 1..9, not repeateable
			
			_btShape = new Vector.<ImaIcon>(NUM_SHAPES);
			//Create shape buttons: 
			for (var i:int; i < NUM_SHAPES; i++) {
				_btShape[i] = new ImaIcon(i, _tileSheet, [_aShape[i]*4, _aShape[i]*4+1, _aShape[i]*4+2]); 
				_btShape[i].x = XINI; 
				_btShape[i].y = YINI+YSEP*i;
				_rectDrag.setTo(XINI, _btShape[i].y, XEND - XINI + Assets.IMG_ICONPARENTALDLG_WIDTH, 0);
				_btShape[i].addDragBehaviour(_rectDrag, chkDropPosCB, dropOkCB, dropKoCB);
				addChild(_btShape[i]);
				_btShape[i].visible = false; 
				
			}
			
			//Create Shape description goal
			_idxShapeGoal = Math.floor(ImaUtils.randomize(1, NUM_SHAPES + 1)) - 1; //RND between 0 and NUMSHAPES-1

			_shapeTxt = new ImaIcon(0,
									new ImaBitmapSheet(Assets.GfxShapesParentalGateDlg, Assets.IMG_SHAPEPARENTALDLG_WIDTH, Assets.IMG_SHAPEPARENTALDLG_HEIGHT),
									[_aShape[_idxShapeGoal]]);
			_shapeTxt.x = 142;
			_shapeTxt.y = 32;
			addChild(_shapeTxt);      
			
			_bSetShape = false;
			
			_touching = [];
		}

		override public function destroy():void {   
			for (var i:uint = 0; i < NUM_SHAPES; i++) {
				_btShape[i].destroy();
				_btShape[i] = null;
			}
			
			_rectDrag = null;
			_auxPoint = null;
			_touching = null;
			super.destroy();                 
		} 
		
		override protected function showEnd():void { 
			//Override to avoid parent behaviour: 
			// - avoid showing all children (frame and icon) 
			// - avoid starting a timer 
			
			for (var i:uint = 0; i < NUM_SHAPES; i++)
				_btShape[i].setFrame(0);		
			
			_btMenu.visible = true;
			open(); 
		} 
		/** 
		 * Opening event where perform init actions, after each time the dialog is shown. 
		 */ 
		override protected function open():void { 
			//Show TEXT based in random value
			//TODO

			for (var i:uint = 0; i < NUM_SHAPES; i++)
				_btShape[i].visible = true; 

			visible = true;                                 
		}    	
		
		private function getRandomShapes(numSel: uint, numTot: uint): Vector.<int>
		{
			var v:Vector.<int> = new Vector.<int>(numSel);
			var idx:int = 0;
			while (idx < numSel) {
				var n:int = Math.floor(Math.random() * numTot);
				if (v.indexOf(n) == -1) {
					v[idx] = n;
					idx++;
				}				
			}
			
			return v;
		}
		
		//------------------------------ Icon movement handling
		
		              
		/**
		 * Check if x,y is a valid drop position, and return the adjusted position in case is ok.
		 * @param	x
		 * @param	y
		 * @return	Return final Pos if drop pos is valid. Return null is drop pos is not valid
		 */
		protected function chkDropPosCB(x:uint, y:uint):Point { 
			if (x >= XEND - 16)  {
				_auxPoint.setTo(XEND, y);
				return _auxPoint;
			}
			else 
				return null; 
		} 
		
		protected function dropOkCB(pid:uint):void { 
			_btShape[pid].setFrame(2);			
			_bSetShape = true;
			if (pid == _idxShapeGoal)
				_bShapeCorrect = true;
			else 
				_bShapeCorrect = false;			
		} 
		
		protected function dropKoCB(pid:uint):void { 
			_btShape[pid].setFrame(0);
		} 
		
		//-------------------------------------------- Interaction
		
		override public function doMouseDown(e:MouseEvent):void {
			var spr: ImaSprite = e.target as ImaSprite; 
			if (spr != null){ // && !spr.isSelected()) {
				//trace("MouseDown Config Srpite Id: " + spr.grp.id + "." + spr.id+" => "+spr.isSelected()+"  TYPEOF: "+typeof(e.target));
				_touching[0] = spr; 
				spr.doStartDrag(e);  
			}
		}
		
		override public function doMouseUp(e:MouseEvent):void {
			if (_touching[0] != null) {
				(_touching[0] as ImaSprite).doStopDrag(e);
				_touching[0] = null;
			}
		}
		
		override public function doTouchBegin(e:TouchEvent):void { 
			var spr: ImaSprite = e.target as ImaSprite; 
			if (spr != null && spr != this) { //&& !spr.isSelected()) {
				_touching[e.touchPointID] = spr;
				spr.doTouchBegin(e);
			}
		} 
		
		override public function doTouchEnd(e:TouchEvent):void {
			var spr: ImaSprite = _touching[e.touchPointID]; 			
			if (spr != null) {
				//TODO asegurar que _touching[e.touchPointID] == spr (debería, pero vamos..¨)
				delete _touching[e.touchPointID];
				_touching[e.touchPointID] = null;
				spr.doTouchEnd(e);
			}			
		}
		
		//---------------------------------------------------- Signal Handling
		
		
		override public function update():void {
			super.update();
			trace("_bSetShape: " + _bSetShape);
			if (_bSetShape) {
				//TODO salir del dialog con el id adecuado (shape correcto o no)
				if (_bShapeCorrect)
					close(2);
				else	
					close(0);
			}
		}
	}

}