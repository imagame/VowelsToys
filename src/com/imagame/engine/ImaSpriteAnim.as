package com.imagame.engine 
{
	import com.imagame.utils.IImaBitmapSheet;
	import com.imagame.utils.ImaBitmapSheet;
	import flash.display.Bitmap;

	/** 
	 * Animated ImaSprite 
	 * Use: First add animations (AddAnimations), and then play selected animation (PlayAnimation) 
	 *      Optionally setFrame() if you want to change animation predefined frame update 
	 * @author imagame 
	 */ 
	public class ImaSpriteAnim extends ImaSprite 
	{ 
		protected var _animations: Vector.<ImaAnim>;        //List of animations to be applied to the sprite 
		protected var _curAnim: ImaAnim;  uint        //Index on _animations to indicate the current selected animation 
		protected var _bAnimFrameUpdated: Boolean;        //Updated frame flag 
		
		public function ImaSpriteAnim(type:uint, id:uint) 
		{ 
			super(type, id);         
			_animations = new Vector.<ImaAnim>;
			_curAnim = null; 
			_bAnimFrameUpdated = false; 
			
			//Permite uso directo de ImaSpriteAnim, sin necesidad de extender la clase
			_bmp = new Bitmap(); //void bitmap by default
			addChild(_bmp); 		
		} 
		
		override public function destroy():void  { 
			_curAnim = null;
			if(_animations){
				for(var i:uint = 0; i < _animations.length; i++) { 
						_animations[i].destroy(); 
						_animations[i] = null; 
				} 
				_animations = null; 
			}
			super.destroy();      
			
			if (_bmp != null)
				removeChild(_bmp);
		} 
		
		//------------------------------------------------------------ Getters/Setters 
		
		protected function getAnimByName(anim: String): ImaAnim { 
			for(var i:uint=0; i < _animations.length; i++){ 
				if(_animations[i].animName == anim) 
					return _animations[i]; 
			} 
			return null; 
		} 

		public function getWidth(): uint {
			if (_curAnim == null)
				return 0;
			else
				return _curAnim.frameWidth;
		}
		
		public function getHeight(): uint {
			if (_curAnim == null)
				return 0;
			else
				return _curAnim.frameHeight;
		}
		
		//--------------------------------------------------- Animation methods 
		
		/**
		 * 
		 * @param	anim			Name
		 * @param	bs				front bitmapsheet
		 * @param	bsBkg			back bitmapsheet
		 * @param	frames			array of fixed frame sequence. (optional if framesCB not null)
		 * @param	framesCB		Callback to calculate framenumber
		 * @param	frameRate		Frame rate in seconds
		 * @param	bLoop			True if frame sequence repeats for ever
		 * @param	afterFrameCB	Callback after every frame change
		 * @param	afterAnimCB		Callback after frame sequence
		 */
		public function addAnimation(anim: String, bs: IImaBitmapSheet, bsBkg: IImaBitmapSheet, frames: Array, framesCB: Function = null, frameRate: Number = 0, bLoop:Boolean=false, afterFrameCB: Function = null, afterAnimCB: Function=null):void { 
			_animations.push(new ImaAnim(anim, this, bs, bsBkg, frames, framesCB, frameRate, bLoop, afterFrameCB, afterAnimCB)); 
		} 
		
				
		/**
		 * Plays an animation. Options: 
		 * 1- Starts an animation: from the beginning
		 * 2- Resumes a paused animation: from the point it was pause, or from the idx passed by param
		 * @param	anim
		 * @param	bStart	True to start of false to continue (from latest point, or from idx if first time)
		 * @param	idx
		 */
		public function playAnimation(anim: String, bStart: Boolean=false, idx: int=-1):void { 
			if(getAnimByName(anim) != _curAnim) {  //New (or first) animation 
				if(_curAnim != null) 
					_curAnim.stopAnimation(); 
				
				_curAnim = getAnimByName(anim); 
				_curAnim.startAnimation(bStart, idx); 				
			} 
			else{ //Continue with current animation, from the beginningo or not depending on bStart     
				_curAnim.startAnimation(bStart, idx); 
			} 
			_bAnimFrameUpdated = true;
			setFrame(idx); 
		} 
		
		/**
		 * Pause current animation, if any.  
		 */
		public function pauseAnimation():void{ 
			if(_curAnim != null) 
				_curAnim.stopAnimation(false);                                 
		} 
		
		//--------------------------- Current Animation control 
		
		/** 
		*(Assumes there is at leas one Animation and it is active -playing-) 
		*/ 
		public function setFrame(idx: int=-1):void {                         
			if (idx != -1) 
				_bmp.bitmapData = _curAnim.getFrameImg(idx) 
			else 
				_bmp.bitmapData = _curAnim.getFrameImg();                                 
		} 

		//--------------------------------------------------- Updating and finishing 
		
		/** 
		* Method called when an animation is finished(to be overriden) 
		* Additionally if the anim has a "afterAnimCB" then it is automatically called before this method 
		*/ 
		protected function onFinishedAnimation(anim: String):void { 
			trace("Anim "+anim+" finished."); 
		} 

		
		override public function update():void {
			if (_curAnim) { //if there is an active animation
				if(_curAnim.updateAnimation()){        //returns true if current frame changed 
					_bAnimFrameUpdated = true; 
					setFrame();        //refresh frame 					
				} 
				else { 
					_bAnimFrameUpdated = false; 
				/* desactivado: Se llama en cada frame tras haber finalizado, no solo en el frame de finalizar
					if(_curAnim.finished) { 
						onFinishedAnimation(_curAnim.animName); 
						//posibilidad de llamar desde aqui a "afterAnimCB" por si fuera necesario enviarle parametros de este scope   
					} 
				*/
				} 
			}					
			super.update(); 
		} 
	} 
	
}