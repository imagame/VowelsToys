package com.imagame.engine 
{
	/**
	 * Group of ImaSprite objects
	 * - add, remove operations 
	 * - status general operations (activate, deactivate) 
	 * - check group conditions (general checking: number, status,..) 
	 * - update (iterate among update() method of sprites contained within the group) 
	 * @author imagame
	 */
	public class ImaSpriteGroup extends ImaSprite 
	{
		protected var _members: Array; 
                
		public function ImaSpriteGroup(id: uint) 
		{ 
			super(TYPE_GROUP, id); 
			trace("IMASPRITE >> ImaSpriteGroup() " + id);
			
			_members = new Array(); 
		} 
		
		override public function destroy():void { 
			if (_members != null) {
				for (var i:int = _members.length-1; i >= 0; i--) {
					(_members[i] as ImaSprite).destroy();
					_members[i] = null;
				}
			}
			_members = null;
			super.destroy(); 
		} 
                
		
		
		//***************************************************** Getters/Setters
		
		
		public function add(spr: ImaSprite):void { 
			//TODO add element to group, replacing a null member first
			_members.push(spr); 
			addChild(spr); 
		} 
		
		public function remove(spr: ImaSprite):Boolean { 
			var index:int = _members.indexOf(spr); 
			if(index >= 0){ 
				_members.splice(index, 1); 
				removeChild(spr);
				return true;                                 
			}else                         
				return false; 
		} 
                      
		/**
		 * Retrieve the members matching the id passed by parameter
		 * @param	id
		 * @return	member if found or null
		 */
		public function retrieve(id: int): ImaSprite {
			for (var i:int = 0; i< _members.length; i++) {
				if (_members[i].id == id)
					return _members[i];
			}
			return null;
		}
		/*
		public function retrieve(id: int): ImaSprite {
			for (var i:int = _members.length - 1; i >= 0; i--) {
				if (_members[i].id == id)
					return _members[i];
			}
			return null;
		}
			*/	
		
		/** 
		 * Update group sprites execution. To be overriden 
		 */ 
		override public function update():void { 
			super.update();	//Call update method of imasprite to manage default fsm 
			
			//Para cada sprite de _members llama a update() 
			for (var i:int = _members.length-1; i >= 0; i--) {
				(_members[i] as ImaSprite).update();
			}
			//TODO opción de llamada a update() según lista ordenada
		} 
                
		
	}

}