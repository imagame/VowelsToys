package com.imagame.game 
{
import com.imagame.engine.ImaButton;
	import com.imagame.engine.ImaDialog;
	import com.imagame.engine.ImaIcon;
	import com.imagame.engine.ImaSprite;
	import com.imagame.engine.ImaState;
	import com.imagame.engine.Registry;
	import com.imagame.utils.ImaBitmapSheet;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Game configuration Dialog
	 * @author imagame
	 */
	public class ConfigDialog extends ImaDialog 
	{
		private var _bResetProgress: Boolean; //Updated when _btProgress is moved to the destination/source position
		private var _bSndEnabled: Boolean; //Updated when _btSnd is pressed
		private var _btProgress: ImaIcon; 
		private var _btSnd: ImaButton; 
		private var _xIniBtProgress:uint; 
		private var _xEndBtProgress:uint; 
		private var _rectDrag: Rectangle; 
		private var _auxPoint: Point = new Point();
		
		protected var _touching: Array;
		
		public function ConfigDialog(id:uint, parentRef:ImaState) 
		{
			super(id, parentRef, new ImaBitmapSheet(Assets.GfxIconsConfigDlg, Assets.IMG_ICONCONFIGDLG_WIDTH, Assets.IMG_ICONCONFIGDLG_HEIGHT), 
				[false, false, true], [Assets.GfxDlgConfig, null, null]); 
			visible = false; 
			//GfxIconsConfigDlg: Icon reset level progress: 4 frames (no-reset, move-bt, reset, bt-disabled,) 
			//GfxIconsConfigDlg: Icon enable/disable sound: 4 frames (Snd-enabled, Snd-disabled, Snd-enabled-over, Snd-disabled-over) 
			
			//Create config buttons: 
			//1- Reset level progress (moveable icon) 
			_btProgress = new ImaIcon(0, _tileSheet, [0, 1, 2]); 
			_xIniBtProgress = 32; 
			_xEndBtProgress = 180; 
			_btProgress.x = _xIniBtProgress; 
			_btProgress.y = 48;
			_rectDrag = new Rectangle(_xIniBtProgress, 48, _xEndBtProgress - _xIniBtProgress + Assets.IMG_ICONCONFIGDLG_WIDTH, 0);
			_btProgress.addDragBehaviour(_rectDrag, chkDropPosCB, dropOkCB, dropKoCB);
			addChild(_btProgress);
			_btProgress.visible = false; 
					
			//2- Sound 
			_btSnd = new ImaButton(1, _tileSheet, 4,6,4); //WEB: _btSnd = new ImaButton(1, _tileSheet, 4,5,7); 
			_btSnd.x = (uint)(_bmp.x + 32);        //to exactly adjust image button to background area graphic 
			_btSnd.y = (uint)(_bmp.y + 136); 
			_btSnd.cacheAsBitmap = true; 
			_btSnd.cacheAsBitmapMatrix = new Matrix(); 			
			addChild(_btSnd); 
			_btSnd.visible = false; 
			_btSnd.signalclick.add(onSndClick);        			
			
			_touching = [];
		}
		
		override public function destroy():void {   
			_btProgress.destroy(); 
			_btProgress = null; 
			_btSnd.destroy(); 
			_btSnd = null; 
			
			_rectDrag = null;
			_auxPoint = null;
			_touching = null;
			super.destroy();                 
		} 

		override protected function showEnd():void { 
			//Override to avoid parent behaviour: 
			// - avoid showing all children (frame and icon) 
			// - avoid starting a timer 
			
			_bResetProgress = false; 
			_btProgress.setFrame(0);			
	        _bSndEnabled = Registry.bSnd;         
			
			_btNext.visible = true;

			open(); 
		} 
                
		/** 
		 * Opening event where perform init actions, after each time the dialog is shown. 
		 */ 
		override protected function open():void { 
			selectBtSndGfx(); //Show btSnd gfx based on local var 
			_btProgress.visible = true; 
			_btSnd.visible = true; 
			visible = true;                                 
		}       
		
		protected function selectBtSndGfx():void { 
			if(_bSndEnabled) 
				_btSnd.loadGraphic(4,6, 4); //4,6  //_btSnd.loadGraphic(4,5,7);
			else 
				_btSnd.loadGraphic(6,4,6); //6,4 //_btSnd.loadGraphic(6,5,7); 
		} 
		
		//------------------------------ Icon movement handling
		
		              
		/**
		 * Check if x,y is a valid drop position, and return the adjusted position in case is ok.
		 * @param	x
		 * @param	y
		 * @return	Return final Pos if drop pos is valid. Return null is drop pos is not valid
		 */
		protected function chkDropPosCB(x:uint, y:uint):Point { 
			if (x >= _xEndBtProgress - 16)  {
				_auxPoint.setTo(_xEndBtProgress, y);
				return _auxPoint;
			}
			else 
				return null; 
		} 
		
		protected function dropOkCB(pid:uint):void { 
			_btProgress.setFrame(2);
			_bResetProgress = true;                         
		} 
		
		protected function dropKoCB(pid:uint):void { 
			_btProgress.setFrame(0);
			_bResetProgress = false;
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
		
		
		//---------------------------------------------------------------- Signal handling 
		protected function onSndClick(event:MouseEvent):void {                         
			_bSndEnabled = !_bSndEnabled; 
			selectBtSndGfx(); 
			Registry.bSnd = _bSndEnabled; 
		} 
		
		
		
		override protected function onNextClick(event:MouseEvent):void { 
			if (_bResetProgress) { 
				(Registry.gpMgr as PropManager).setGameProgress([0,0,0,0,0,0,0,0,0,0]); //Reset progress
			} 
			Registry.gpMgr.save(); //Save in all cases (perhaps other config button, affecting Registry has changed) 
			super.onNextClick(event);
		} 		
		
		override public function update():void {
			_btProgress.update();
			super.update();			
		}		
	}

}