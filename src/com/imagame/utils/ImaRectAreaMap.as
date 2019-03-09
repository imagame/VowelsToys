package com.imagame.utils 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	/**
	 * Maps a rectangle object to a position in an Rect Area, meeting some criteria:
	 * - Rectangle object included/excluded partially/totally from zones (rect subareas within the total Rect Area) 
	 * - Rectangle object not overlapped with other rectangle objects
	 * @author imagame
	 */
	public class ImaRectAreaMap 
	{
		protected var _objects: Array;	//array de objects {type,id,posx,posy}
		protected var _areaW: uint;		//total area width
		protected var _areaH: uint; 	//total area height
		protected var _zones: Vector.<Rectangle>;	//list of (autocontent) zones (sorted by area size, big to small)
		
		protected var _auxPoint: Point = new Point();
		protected var _auxRectangle: Rectangle = new Rectangle();
		
		//Restriction types between object and zone
		public static const TYPE_INCLUDE_TOTAL = 0;
		public static const TYPE_INCLUDE_PARTIAL = 1;
		public static const TYPE_EXCLUDE_TOTAL = 2;
		public static const TYPE_EXCLUDE_PARTIAL = 3;
		
		/**
		 * Creates a RectArea Map with [w,h] dimensions
		 * @param	w
		 * @param	h
		 */
		public function ImaRectAreaMap(w: uint, h:uint) 
		{
			_areaW = w;
			_areaH = h;
			_objects = new Array();
			_zones = new Vector.<Rectangle>;
		}
		
		public function destroy():void {
			_objects = null;
			if (_zones != null) {
				for (var i:uint = 0; i < _zones.length; i++)
					_zones[i] = null;
				_zones = null;
			}
			
			//Aux vars
			_auxPoint = null;
			_auxRectangle = null;
		}
		
		public function addZone(zone: Rectangle):void {
			_zones.push(zone.clone());
		}
		
		/** 
		 * Put an object in the Map, with timer condition (1second): 
		 * Assigns x,y positions to the object meeting the posType restrictions and avoiding overlapping with other objects 
		 * @param        w 
		 * @param        h 
		 * @param        objectType   
		 * @param        objectId 
		 * @param        ...args                Array of zone inclusion/exclusion criterias (Pair of values: posType, posZone). If null the only criteria is to feet inside the global area 
		 * @return        Assigned local Map pos, or null if the object cannot be put (no space and time out)
		 */ 
		 public function put(size: Point, objectType:int = -1, objectId: int = -1, ...args):Point {                         
			var _auxRect2: Rectangle = new Rectangle(); 
			var _bOverlap:Boolean = true;                         
			
			//START TIMER: 
			var actTime:Number = getTimer(); 
			do { 
				//IF TIMER COMPLETE break; 
				if(getTimer() - actTime > 500) 
					break; 
			
				//Obtain random position (limited to global area) 
				_bOverlap = false; 
				_auxPoint.x = (uint) (ImaUtils.randomize(0, _areaW - size.x)); 
				_auxPoint.y = (uint) (ImaUtils.randomize(0, _areaH - size.y));                                                                 
				_auxRectangle.setTo(_auxPoint.x, _auxPoint.y, size.x, size.y); 
				
				//check zone inclusion/exclusion criteria conditions  (Assumes that all referenced _zones in args exist) 
				if(args!=null) { 
					var n:uint = args.length * 0.5; //number of zone conditions to check 
					while (n > 0) { 
						//Check if the zone exist
						if(args[(n-1)*2+1] < _zones.length) {
							if(!checkMeetCondition(_auxRectangle, args[(n-1)*2], _zones[args[(n-1)*2+1]])) { 
								_bOverlap = true;        //Does not meet condition. exit 
								n=0; 
							} 
							else 
								n--; 
						}
					} 
					if(_bOverlap) 
						continue; //Repeat random position assignment 
				} 
					
				//Check if there is overlapping with existing objects 
				for (var i:uint = 0; i < _objects.length; i++) { 
					_auxRect2.setTo(_objects[i].x, _objects[i].y, _objects[i].w, _objects[i].h); 
					if (_auxRectangle.intersects(_auxRect2))         
						_bOverlap = true; 
				} 
				
			} while (_bOverlap) 
			
			if(!_bOverlap) { 
				_objects.push( { id:objectId, type:objectType, x: _auxPoint.x, y: _auxPoint.y, w:size.x, h:size.y } ); 
				return _auxPoint; 
			} 
			else 
				return null; 
		} 
		
		
		/** 
		 * Put an object in the Map (without timer conditions) 
		 * Assigns x,y positions to the object meeting the posType restrictions and avoiding overlapping with other objects 
		 * @param        w 
		 * @param        h 
		 * @param        objectType   
		 * @param        objectId 
		 * @param        ...args                Array of zone inclusion/exclusion criterias (Pair of values: posType, posZone). If null the only criteria is to feet inside the global area 
		 * @return        Assigned local Map pos 
		 */ 
		public function put2(size: Point, objectType:int = -1, objectId: int = -1, ...args):Point {                         
			var _auxRect2: Rectangle = new Rectangle(); 
			var _bOverlap:Boolean = false;                         
			
			do { 
				//Obtain random position (limited to global area) 
				_bOverlap = false; 
				_auxPoint.x = (uint)(ImaUtils.randomize(0, _areaW - size.x)); 
				_auxPoint.y = (uint)(ImaUtils.randomize(0, _areaH - size.y));                                                                 
				_auxRectangle.setTo(_auxPoint.x, _auxPoint.y, size.x, size.y); 
				
				//check zone inclusion/exclusion criteria conditions  (Assumes that all referenced _zones in args exist) 
				if(args!=null) { 
					var n:uint = args.length * 0.5; //number of zone conditions to check 
					while (n > 0) { 
						//Check if the zone exist
						if(((n-1)*2+1) < _zones.length) {
							if(!checkMeetCondition(_auxRectangle, args[(n-1)*2], _zones[args[(n-1)*2+1]])) { 
								_bOverlap = true;        //Does not meet condition. exit 
								n=0; 
							} 
							else 
								n--; 
						}
					} 
					if(_bOverlap) 
						continue; //Repeat random position assignment 
				} 
				
				//Check if there is overlapping with existing objects 
				for (var i:uint = 0; i < _objects.length; i++) { 
					_auxRect2.setTo(_objects[i].x, _objects[i].y, _objects[i].w, _objects[i].h); 
					if (_auxRectangle.intersects(_auxRect2))         
						_bOverlap = true; 
				} 
			} while (_bOverlap) 
				
			_objects.push( { id:objectId, type:objectType, x: _auxPoint.x, y: _auxPoint.y, w:size.x, h:size.y } ); 
				
			return _auxPoint; 
		} 		
		
		/**
		 * 
		 * @param	obj
		 * @param	cond
		 * @param	zone
		 * @return
		 */
		function checkMeetCondition(obj: Rectangle, cond: uint, zone: Rectangle):Boolean { 
			switch(cond) { 
				case ImaRectAreaMap.TYPE_INCLUDE_TOTAL: return zone.containsRect(obj); 
						//return (!obj.intersects(zone) && obj.x > zone.x && obj.right < zone.right && obj.y > zone.y && obj.bottom < zone.bottom)                                         
				case ImaRectAreaMap.TYPE_INCLUDE_PARTIAL: return (zone.containsRect(obj) || obj.intersects(zone)); 
				case ImaRectAreaMap.TYPE_EXCLUDE_TOTAL: return !zone.containsRect(obj) && !obj.intersects(zone); 
				case ImaRectAreaMap.TYPE_EXCLUDE_PARTIAL: return !zone.containsRect(obj); // (!zone.containsRect(obj) || obj.intersects(zone)); 
			}
			return false;
		} 
                		
		/**
		 * Obtain the list of objects positioned in the correct zones, in array of objects format.
		 * @param	type
		 * @param	id
		 * @return
		 */
		public function getObjects(type: int = -1, id: int = -1):Array {
			return _objects;
		}
		
		/**
		 * Obtain the list of objects positioned in the correct zones, in array of ints format.
		 * @return	array (4 values for each object: x,y,type,id)
		 */
		public function getList(type: int = -1, id: int = -1):Vector.<uint> {
			var v:Vector.<uint> = new Vector.<uint>;
			
			//TODO filter search by type and id
			//return _objects.filter(filterType, type);
			for each (var o:Object in _objects) {
				v.push(o.x);
				v.push(o.y);
				v.push(o.type);
				v.push(o.id);
			}
			
			return v;
			
			
			/*
			var _array:Array =  new Array();
			_array.push({name:"Ben",Title:"Mr",location:"UK"});
			_array.push({name:"Brian",Title:"Mr",location:"USA"});
			_array.push({name:"Ben",Title:"Mr",location:"USA"});

			var searchQuery:Array = new Array();
			searchQuery.push("Ben");
			searchQuery.push("Mr");

			var resultArray:Array = _array.filter(ff); //The result.

			function ff(el:*,ind:int,arr:Array){//Filter Function
				for(var i:int=0;i<searchQuery.length;i++){//Everything in searchQuery array should in el object.
					var b:Boolean = false;
					for(var s:String in el){
						if(el[s]==searchQuery[i]){
							b=true; break;
						}
					}
					if(!b) return false; //no searchQuery[i] in el... :(
				}
				return true;
			}
			
			
			*/
		}
		
		
	}

}