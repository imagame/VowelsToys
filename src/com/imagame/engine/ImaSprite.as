package com.imagame.engine 
{
	import com.imagame.utils.ImaBitmapSheet;
	import flash.display.Bitmap;
	import flash.display.Sprite;
		import flash.events.MouseEvent;
		import flash.events.TouchEvent;
		import flash.geom.Matrix;	
	
	/**
	 * Imagame sprite (addchild(displayobj) must be created by subclass or outside class)
	 * @author imagame
	 */
	public class ImaSprite extends Sprite 
	{
		protected var _type: uint;
		protected var _id: uint;
		protected var _sts: uint;
		
		public static const TYPE_ICON: uint = 0;
		public static const TYPE_BUTTON: uint = 1
		public static const TYPE_ENTITY: uint = 2;
		public static const TYPE_GROUP: uint = 3; 
		public static const TYPE_DLG: uint = 4;
		public static const TYPE_FX: uint = 5;
		public static const TYPE_BAR: uint = 6;		
		public static const TYPE_SPRITE_FACE: uint = 10; //Sprite of type Face (Menu level selection)

		public static const POS_UPLE: uint = 0;
		public static const POS_UPRI: uint = 1;
		public static const POS_DOLE: uint = 2;
		public static const POS_DORI: uint = 3;		
		public static const POS_NOCENTRE: uint = 0;	
		public static const POS_CENTREX: uint = 1;		
		public static const POS_CENTREY: uint = 2;		
		
		public static const STS_CREATE:uint = 0; //creating object
		public static const STS_INIT:uint = 1;	//alive but initializing 
		public static const STS_ACTIVE:uint = 2;	//alive and active	=> Must be activated by a subclass
		public static const STS_FINISHED:uint = 3;	//alive, not active, but finished	=> Must be activated by a subclass
		public static const STS_DYING:uint = 4;	//alive but ending	=> Must be activated by a subclass
		public static const STS_DEAD:uint = 5; //not alive (not visible, not active)
		public static const STS_001:uint = 6; //Free state, to use and extend in subclasses
		
	
				
		protected var _grp: ImaSpriteGroup;	//group relationship (1 group: N sprites, 1 sprite: 1 group)
		
		//TODO Animation default variables
		protected var _bmp: Bitmap;         //sprite bitmap       
		protected var _tileSheet: ImaBitmapSheet; //graphics tilesheet 
		
		public function ImaSprite(type: uint, id: uint ) 
		{
			super();
			var tip: String = (type == 0)?" TYPE_ICON":(type == 1)?"TYPE_BUTTON":(type == 2)?"TYPE_ENTITY":(type == 3)?"TYPE_GROUP":(type == 4)?"TYPE_DLG":(type == 5)?"TYPE_FX":"noType";
			trace(">> ImaSprite() " + id + "  Tipo: "+tip);
			
			_type = type
			_id = id;
			//DUDA: Activar aquí, o despues de definir cada display object?
			this.cacheAsBitmap = true;
			this.cacheAsBitmapMatrix = new Matrix();
			
			_sts = STS_CREATE;
		}
		
		public function destroy():void  {
			_bmp = null;
			_tileSheet = null;
			_grp = null;
		}
		
		/**
		 * Init function called when moving from STS_CREATE to STS_INIT
		 */
		public function init():void {  
			var tip: String = (_type == 0)?" TYPE_ICON":(_type == 1)?"TYPE_BUTTON":(_type == 2)?"TYPE_ENTITY":(_type == 3)?"TYPE_GROUP":(_type == 4)?"TYPE_DLG":(_type == 5)?"TYPE_FX":"noType";			
			trace("ImaSprite->init()" + id + " Type: "+tip);
			//Default behavior: none. Move on active state
			_sts = STS_ACTIVE;
		} 
		 
		/**
		 * Exit function called when moving from STS_DYING to STS_DEAD
		 */
		public function exit():void { 
			visible = false;
		} 
       
		
		
		//***************************************************** Getters/Setters
		
		public function get type():uint {
			return _type;
		}
		
		public function get id():uint {
			return _id;
		}
				
		public function setGroup(grp: ImaSpriteGroup) {
			_grp = grp;
		}
		
		public function get grp(): ImaSpriteGroup {
			return _grp;
		}
		
		public function get state(): uint {
			return _sts;
		}
		
		public function isActive():Boolean {
			if (_sts == STS_FINISHED || _sts == STS_DYING || _sts == STS_DEAD || _sts == STS_CREATE)
				return false;
			else 
				return true;
		}
		
		/**
		 * Set z order within imaspritegroup
		 * @param	idx
		 */
		public function setZ(idx: int):void {
			if (grp != null) {
				if (idx == -1)
					grp.setChildIndex(this, grp.numChildren-1);
				else
					grp.setChildIndex(this, idx);			
			}
		}
		
		//*************************************** Interactive actions 
		
		public function doClick(localX:Number, localY:Number):void {
						
		}
		
		public function doStartDrag(e:MouseEvent):void {
		}
		
		public function doStopDrag(e:MouseEvent):void {
			
		}
		
		public function doTouchBegin(e:TouchEvent):void {  
			
		}
		
		public function doTouchEnd(e:TouchEvent):void {  
			
		}
		
		/**
		 * Update gameloop execution. To be overriden
		 */
		public function update():void {
			//Default standar state behavior (CREATE->INIT,DYING->DEAD)
			if (_sts == STS_CREATE) {
				trace("ImaSprite (STS_CREATE->STS_INIT): " + id);
				_sts = STS_INIT;
				init();				
			} else if (_sts == STS_DYING) {
				trace("ImaSprite (STS_DYING->STS_DEAD): " + id);
				_sts = STS_DEAD;
				exit();
			}		
			
		}
		
		
	}

}