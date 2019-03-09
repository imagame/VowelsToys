package com.imagame.engine 
{
	import com.imagame.utils.IImaBitmapSheet;
	import com.imagame.utils.ImaBitmapSheet;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * Animation support for ImaSpriteAnim
	 * @author imagame
	 */
	public class ImaAnim 
	{
		protected var _sprParent: ImaSpriteAnim;	//Ref to the ImaSpriteAnim parent
		protected var _animName: String;
		protected var _bs: IImaBitmapSheet;	//Foreground ImaBitmapSheet
		protected var _bsBkg: IImaBitmapSheet;	//Background ImaBitmapsheet
		protected var _frames: Array;
		protected var _frameRate: Number;        //If 0: Fixed frame if _frames array is not null, or only 1 call to _framesCB if exist. 
		protected var _bLoop: Boolean;        //True to continue after finishing _frames array, false to stop ç	
		protected var _framesCB:Function;
		protected var _afterFrameCB:Function;
		protected var _afterAnimCB:Function;
		
		protected var _curFrame: int;
		protected var _numFrames: uint;
		protected var _delayFrame: Number;        //1/_frameRate 
		protected var _frameTimer: Number; //counter for current frame change, when greater than _delay 		
		protected var _frameWidth: uint;
		protected var _frameHeight: uint;
		
		protected var _finished: Boolean;
		
		public function ImaAnim(anim: String, spr: ImaSpriteAnim, bs: IImaBitmapSheet, bsBkg: IImaBitmapSheet, frames: Array, framesCB: Function = null, frameRate: Number = 0, bLoop:Boolean=true, afterFrameCB: Function = null, afterAnimCB: Function=null) 
		{
			_animName = anim;
			_sprParent = spr;
			
			_bs = bs;
			_bsBkg = bsBkg;
			_frames = frames;
			_frameRate = frameRate;
			_bLoop = bLoop;
			_delayFrame = 0; 
			if(_frameRate !=0) 
				_delayFrame = 1.0/_frameRate; 
			_frameTimer = 0; 
			
			//callbacks
			_framesCB = framesCB;
			_afterFrameCB = afterFrameCB;
			_afterAnimCB = afterAnimCB;		
			
			_frameWidth = _bs.getTileWidth();
			_frameHeight = _bs.getTileHeight();
			
			
			_curFrame = -1;
			if (_frames != null)
				_numFrames = _frames.length;
			else
				_numFrames = 1;
			_finished = false;
		}
		
		public function destroy():void {
			//TODO
			_sprParent = null;
			_frames = null;
			_bs = null;
			_bsBkg = null;			
		}
		
		//------------------------------------------------------------ Getters/Setters 
		
		public function get animName():String {
			return _animName;
		}
		
		/**
		 * Get the current bitmapData frame, or the one located in idx tilesheet position
		 * @param	idx	Optional index among Frames array, instead of computed _curFrame (only applies to static frames array)
		 * @return
		 */
		public function getFrameImg(idx: int = -1):BitmapData {
			//Option A: direct frame from bs (_curframe already computed in updateAnimations, or startAnimation)
			if (idx != -1 && _framesCB == null)    {                                     
				_curFrame = idx; //FIX v1.0
				return _bs.getTile(_frames[idx]).bitmapData;                                 
			}else {
				if (_bsBkg == null){					
					//Option A: frame from bs					
					if (_framesCB != null) //_curFrame calculated from CB and obtained as a direct idx among _bs 
						return _bs.getTile(_curFrame).bitmapData; 
					else 
						return _bs.getTile(_frames[_curFrame]).bitmapData; 
				}
				else { 
					//Option B: composite frame from bkgbs and bs (_curFramebkg and _curFrame already computed, both from same idx)
					var bmd = new BitmapData(32,32,false,0xFFFFFFFF); 
					var bmp: Bitmap = new Bitmap(bmd);
					bmp.bitmapData.copyPixels(_bsBkg.getTile(_curFrame).bitmapData, new Rectangle(0, 0, 32, 32), new Point());
					bmp.bitmapData.copyPixels(_bs.getTile(_curFrame).bitmapData, new Rectangle(0, 0, 32, 32), new Point());				
					return bmp.bitmapData;			
				}
				//Option C: composite frame from bkgs and bs, with _curFrame indicadors computed from different idx
				//TODO: Future
			}
		}
		
		public function get frameWidth():uint {
			return _frameWidth;
		}
		
		public function get frameHeight():uint {
			return _frameHeight;
		}
		
		public function get curFrame():int {
			return _curFrame;
		}
		
		public function get finished():Boolean {
			return _finished;
		}
		//------------------------------------------------------------ Operations 

		
		/**
		 * Calculate the initial frame of the animation, for the starting o resuming o the animation
		 * Initial: A)from the beginning: start, or b) after pause: resuming
		 * Applies to both, fixed frame array animation, or calcualted frame animation through callback method
		 * @param	bStart	Start from the initial frame of the animation(if true, idx does not apply)
		 * @param	idx		Start from the idx frame of the animation. -1 to start/resume. (only applies when bStart is false)	
		 */
		public function startAnimation(bStart: Boolean, idx: int=-1):void {
			_frameTimer = 0; 
			_finished = false; 

			//Fixed frame array animation
			if (_framesCB == null) {
				if (bStart)
					_curFrame = 0; 
				else {
					if(idx == -1) //resuming
						_curFrame = (_curFrame +1) % _numFrames;
					else
						_curFrame = idx;
				}
			}
			//calculated frame animation
			else {
				_curFrame = _framesCB(_sprParent, _bs, idx); //traduce el idx (idx relativo) a idx absoluto sobre _bs 
				//TODO: Option B
			}
		}

		
		/**
		 * Stops or pause the animation 
		 * @param	bStop	True to stop animation, False to pause
		 * @param	framePause	Framenumber if pausing (-1 if pausing in current _curFrame)
		 */
		public function stopAnimation(bStop: Boolean = true, framePause: uint = -1):void { 
			_finished = true; 
			if(bStop) 
				_curFrame = -1; 
			else
				if (framePause != -1)
					_curFrame = framePause;
		}   		
		
		/**
		 * Calculates the next Frame of animation, if frameRate > 0 and timers values are met
		 * Computed from a fixed frame array animation, or from a callback function, or a combination of both
		 * @return
		 */		
		public function updateAnimation():Boolean {
			//Avoids playing paused/stopped animations 
			if (_finished) 
				return false; 
			
			if (_frameRate == 0) { //Avoid changing frame on a periodical basis 
				stopAnimation(); 
				return false; 
			} 
			else {
				 _frameTimer += Registry.elapsedTime; 
				
				//TODO: timers conditions check 
				if(_frameTimer < _delayFrame) { //timers conditions check 
				//if (false) {
					return false;
				}
				//Time condition met
				else { 
					 _frameTimer = 0; 
					//---------------------------------------------------------------- Case A - Fixed static anim sequence
					if (_framesCB == null) { 
						//Case A: Fixed static sequence _frames with _frameRate                                         
						//_curFrame = (_curFrame +1)%_numFrames;                                 
						
						if(_animName == "star2first") {								
							trace("Anim star2firs _curFrame "+ _curFrame);
						}
						
						_curFrame++; 
						if (_curFrame >= _frames.length) {        //end of frame sequence 
													
							//call end of anim CB if exist 
							if(_afterAnimCB != null) { 
								_afterAnimCB(_sprParent); 
							}
							
							//Continue if loop activated 
							if(_bLoop) { 
								_curFrame = 0;    
							}
							else{ 
								stopAnimation(false,_frames.length-1); //false: to stop in the last frame
								return false; 
							} 
						} 
						else { //next frame in sequence 
							if(_afterFrameCB!=null) 
								_afterFrameCB(_sprParent,_bs,_curFrame); 
						} 	
						return true;
					} 
					
					//------------------------------------------------------------------ Case B: calculated anim sequence
					else { 
						//Case B: _framesCB with _frameRate 
						//Case B.1: _framesCB with _frameRate and not bLoop 
						_curFrame = _framesCB(_sprParent, _bs, _curFrame); //continue sequence: Param idx gets the value of _curFrame 
						if(_curFrame == -1 ){ //En of frame sequence, to continue if bLoop is true 
							if(_bLoop){ //Case B.2: _framesCB with _frameRate and not bLoop 
								_curFrame = _framesCB(_sprParent, _bs, 0);        //start sequence with index=0 
							}
							else { 
								stopAnimation(); 
								return false; 
							}                                                         
						} //next frame in sequence 
						else { 
							if(_afterFrameCB!=null) {
								_afterFrameCB(_sprParent,_bs,_curFrame); 
							}
						} 
						return true; 
					} 
					
				}      
			}
			
		} 
			
                
         
		
	}

}