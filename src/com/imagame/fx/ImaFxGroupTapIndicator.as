package com.imagame.fx 
{
	import com.imagame.engine.ImaSpriteAnim;
	import com.imagame.game.Assets;
	import com.imagame.utils.ImaBitmapSheet;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	/**
	 * Group Tap indicator FX
	 * Use guide:
	 * 1- Create FX passing _member vector of potential enabled members, params to define positions of members, and param to define duration of fx
	 * 2- 
	 * @author imagame
	 */
	public class ImaFxGroupTapIndicator extends ImaSpriteAnim implements IImaFX 
	{
		protected var _numLoops: uint;	//Number of Anim loops
		protected var _curLoop:uint;	//Number of current loop
		protected var _bOnFx: Boolean;        //True if FX started (or paused), false is stopped                 		
		protected var _bPauseFx: Boolean;	//True if FX paused (visible graphics and not animated)
		protected var _numW: uint;                //Number of horizontal members in the sprite grid         
		protected var _numH: uint;                //Number of vertical members in the sprite grid 
		
		protected var _numMembersFx: uint;
		protected var _members: Vector.<int>;	 //List o member fs status per potion=> -1: unused, 0: disabled, 1: enabled 
		protected var _sprList: Vector.<Sprite>;	//List of sprites, one for each potential member fx. (list wiht voids, where there is a unused pos)
		
		/**
		 * Constructor of ImaFxGroupTapIndicator
		 * @param	inMembers	List of potential active member FX
		 * @param	inLoops		Duration of Fx: Number of animated loops. If 0 it last forever.
		 * @param	inX
		 * @param	inY
		 * @return
		 */
		public function ImaFxGroupTapIndicator(inMembers: Vector.<int>, inNumW: uint, inNumH:uint, inLoops: uint = 0)  //TODO: with/height 		
		{
			super(TYPE_FX, 0);
			_bOnFx = _bPauseFx = false; 
			
			_numLoops = inLoops;
			_curLoop = 0;
			_numW = inNumW; 
			_numH = inNumH; 
			if(inMembers.length != _numW*_numH) 
				trace("ERROR! ImaFxGroupTapIndicator: Length not match"); 
			_numMembersFx = inMembers.length;
			_members = new Vector.<int>(_numMembersFx);
			_sprList = new Vector.<Sprite>(_numMembersFx);
			createMembersFx();				// create sprite members fx
			setMembersFx(inMembers);        //enable/disable _members fx
			
			mouseChildren = false;
			mouseEnabled = false;
			
			
			//var _bs: ImaBitmapSheetDirect = new ImaBitmapSheetDirect((Registry.game.getState() as ImaState).background.getImg(new Rectangle(posPuzX, posPuzY, _img.width, _img.height)), _pieceWidth, _pieceHeight);
	//		_bmp = new Bitmap(); //void bitmap by default
			removeChild(_bmp);	//it add to the display list by the superclass ImaSpriteAnim
	
			var _bs: ImaBitmapSheet = new ImaBitmapSheet(Assets.GfxFxTapIndicator, Assets.FX_TAPIND_WIDTH, Assets.FX_TAPIND_HEIGHT);
			//addAnimation("Tap", _bs, null, [0, 1, 2, 3, 4, 5, 6, 7, 7, 7, 7], null, 40, true, null, onFinishAnimCB); //[iOS]
			
			addAnimation("Tap", _bs, null, [0, 1,2, 3, 4, 5, 6, 7, 7, 7, 8,8,8,8,8], null, 30, true, null, onFinishAnimCB); //[Android]
			//_sts = STS_ACTIVE;
		}
		
		override public function destroy():void { 
			for(var i:uint=0; i< _numMembersFx; i++){ 
				if(_sprList[i] != null && getChildByName(_sprList[i].name)) { 
					removeChild(_sprList[i]);					
				} 
				_sprList[i] = null; 
			} 
			_members = null; 
			
			super.destroy(); 
		} 
		
		/**
		 *  Creates list of sprites based in _members array and position them in the grid structure defined by with/height vars
		 */
		protected function createMembersFx():void {			
			var posX: uint = 0;
			var posY: uint = 0;
			var col:uint = 0;
			var row:uint = 0;
			for (var i:uint = 0; i < _numMembersFx; i++) {
				if (_members[i] != -1){	//Create members sprites if different than unused
					_sprList[i] = new Sprite();		
					_sprList[i].x = posX;
					_sprList[i].y = posY;
					//[OPTIMIZE]
					_sprList[i].cacheAsBitmap = true; 
					_sprList[i].cacheAsBitmapMatrix = new Matrix();    				
					_sprList[i].mouseChildren = false;
					_sprList[i].mouseEnabled = false;
				}
				if (col++ >= _numW-1) { 
					col = 0;
					row++;
					posY += Assets.FX_TAPIND_HEIGHT; 
					posX = 0;
				}
				else {
					posX += Assets.FX_TAPIND_WIDTH;
				}				
			}
		}

		
	
		//------------------------------------------------------------------- Operations 
		/* INTERFACE com.imagame.fx.IImaFX */
		
		/**
		 * Starts/Resumes the FX, adding a bitmap to each sprite children
		 * @param	bStart	True to start from the beginning, Falst to resume after being pause
		 */
		public function startFx(bStart:Boolean = true):void 
		{							                                              
			if (bStart || (!bStart && !_bPauseFx)) {//forced start, or resume without having paused 
				_curLoop = 0; 
				playAnimation("Tap", true);        //starts animation and set current frame in _bmp                       
				addListBitmapMemberFx(); //Add bitmapdata to active membersFx 
			} 
			else {//resume                                                 
				playAnimation("Tap", false);        //starts animation and set current frame in _bmp                       
				updListBitmapMemberFx(); //Add bitmapdata to active membersFx                                 
			} 
			_bPauseFx = false;                         
			_bOnFx = true; 
		}

		/**
		 * Stops/Pauses the fX, deleting bitmaps from each sprite children
		 * @param	bStop	True stops the Fx and destroys sprite children, and False pauses the Fx (to resume -or reuse- later)
		 * @param	bVisible	True to keep it visible after pausing/stoping, False to hide it
		 */		
		public function stopFx(bStop:Boolean = true, bVisible:Boolean = false):void 
		{
			if(_curAnim != null) {        //if the FX has started before 
				//stop animation 
				if (bStop && _bOnFx){ 
					//Delete children sprites 
					for (var i:uint = 0; i < _numMembersFx; i++) { 
						if (_sprList[i] != null && _sprList[i].numChildren > 0 ) 
							delBitmapMemberFx(i); 
					} 
					_bOnFx = false;                                         
				} 
				//Pause animation 
				else { 
					_bPauseFx = true;         
					setVisibleListBitmapMemberFx(bVisible);                                                 
				} 
			} 
		}
				
		/**
		 * Enables a member in FX group 
		 * @param	idx	index o member
		 */
		public function disableMemberFx(idx: uint):void {
			if (_members[idx] == 1) {
				_members[idx] = 0; 
				delBitmapMemberFx(idx);
			}
		}
		
		/**
		 * Disables a member in FX group 
		 * @param	idx	index o member
		 */
		public function enableMemberFx(idx: uint):void {
			if (_members[idx] == 0) {
				_members[idx] = 1; 
				setFrame();        //refresh current anim bitmapdata 
				addBitmapMemberFx(idx); 
			}
		}
		
		//------------------------------------------------------------------- Getters/Setters
		/**
		 * Set the enabled/disable list of members fx (add or remove child from the display list)
		 * @param	inMembers
		 */
		public function setMembersFx(inMembers: Vector.<int>):void {
			_members = null;
			_members = inMembers.concat();	
			
			//remove all current sprites from the display list
			for (var i:uint = 0; i < _numMembersFx; i++) {
				if (_sprList[i] != null && getChildByName(_sprList[i].name))
					removeChild(_sprList[i]);
			}
			
			//add new sprites to the display list
			for (var i:uint = 0; i < _numMembersFx; i++) {
				//if (_members[i] == 1)
				if (_members[i] != -1){
					addChild(_sprList[i]);
					//_sprList[i].cacheAsBitmap = true;
					//_sprList[i].cacheAsBitmapMatrix = new Matrix();
				}
			}
		}

		//------------------------------------------------------------------- Internal

		
		protected function addBitmapMemberFx(idx: uint):void { 
			_sprList[idx].visible = true;
			_sprList[idx].addChild(new Bitmap(_bmp.bitmapData)); 			
		} 
		protected function updBitmapMemberFx(idx: uint):void { 
			_sprList[idx].visible =  true;
			(_sprList[idx].getChildAt(0) as Bitmap).bitmapData = _bmp.bitmapData;		
		} 
		protected function delBitmapMemberFx(idx: uint):void {
			_sprList[idx].removeChildAt(0);	
		}
	
		
		protected function addListBitmapMemberFx():void { 
			for(var i:uint=0; i<_numMembersFx; i++) { 
				if(_members[i] == 1) 
					addBitmapMemberFx(i); 
			} 
		} 
		
		protected function updListBitmapMemberFx():void { 
			for(var i:uint=0; i<_numMembersFx; i++) { 
				if(_members[i] == 1) 
					updBitmapMemberFx(i); 
			} 
		} 

		protected function setVisibleListBitmapMemberFx(bVisible:Boolean=true):void { 
			for(var i:uint=0; i<_numMembersFx; i++) { 
				if(_members[i] == 1) {
					_sprList[i].getChildAt(0).visible = bVisible;
				}
			} 
		} 		
		
		//------------------------------------------------------------------- Callbacks

		protected function onFinishAnimCB(spr: ImaSpriteAnim):void {
			_curLoop++;
			if(_numLoops > 0 && _curLoop > _numLoops)
				stopFx(false);
		}
		
		//Obtiene frame si ha cambiado
		override public function update():void {
			if (_bOnFx && !_bPauseFx) { 
				super.update();        //update anim (if timing is met)                                 
				//trace("Frame: " + _curAnim.curFrame); 
				
				//Update sprite members fx only if frame animation has changed 
				if(_bAnimFrameUpdated) 
					updListBitmapMemberFx();        //TODO: upd only if changed 
			} 
		} 
	}

}