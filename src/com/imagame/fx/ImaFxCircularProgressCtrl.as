package com.imagame.fx 
{
	import com.imagame.engine.ImaTimer;
	import com.imagame.utils.ImaUtils;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author imagame
	 */
	public class ImaFxCircularProgressCtrl extends Sprite implements IImaFX
	{				
		protected var _radius: Number;
		protected var _color: Number;
		protected var _lineThickness: Number;
		protected var _freq: Number;
		protected var _dur: Number;
		protected var _ctrlTimer: ImaTimer;        //Timer to control piece selection timeframe 
		protected var _endCB: Function;
		protected var _numLoops: uint;
		
		//support
		protected var POINT0:Point = new Point();

		public function ImaFxCircularProgressCtrl(inRadius:Number, inColor:Number, inLineThickness:Number, inCtrlFreq: Number, inCtrlDur: Number, inEndCB: Function ) 
		{
			_radius = inRadius;
			_color = inColor;
			_lineThickness = inLineThickness;
			_freq = inCtrlFreq;
			_dur = inCtrlDur;
			_endCB = inEndCB;
			
			//init			
			init();
			
		
			_ctrlTimer = new ImaTimer();
		}		

		public function destroy():void {
			_ctrlTimer.destroy();
			_ctrlTimer = null;
		}
		
		public function init():void {
			this.graphics.clear();
			_numLoops = _dur / _freq;
			this.graphics.lineStyle(_lineThickness, _color, 0.7, false, LineScaleMode.NORMAL, CapsStyle.ROUND, JointStyle.BEVEL);
		}
		
		/**
		 * 
		 * @param	bStart	True to continue (resume) , false to start from scratch
		 */
		public function startFx(bStart: Boolean=false):void {
			if (!bStart)
				init();		
			visible = true;
			_ctrlTimer.start(_freq, _numLoops, onControlTimer);
		}
		
		public function stopFx(bPause: Boolean = true, bVisible: Boolean = false):void {
			//TODO: Que stop siempre sea una pausa, y que start de la opción de reanudar (si había pausa previa) o empezar de 0
			visible = bVisible;
			_ctrlTimer.stop();
		}
		
		
		/**
		 * Paint the time per piece progress
		 * @param	progress	Value between 0..1 (0: init, 1: finish)
		 */
		
		protected function paintFx(progress: Number ):void {
			ImaFx.drawCircleSegment(this.graphics, POINT0, 0, ImaUtils.TWOPI * progress, _radius);
		}
		
		
		//------------------------------------------------------------------- Callbacks
		
		protected function onControlTimer(timer: ImaTimer):void {
			//trace("TIMER: "+timer.progress+ "  Left: " + timer.timeLeft);
			if (timer.finished){
				_endCB(); 
			}
			else { 
				paintFx((_numLoops - timer.loopsLeft)/_numLoops);	//param: progress value between 0..1
			} 
		} 
		
		
		
	}

}