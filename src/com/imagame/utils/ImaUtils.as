package com.imagame.utils 
{
	import flash.display.Graphics;
	import flash.geom.Point;
	/**
	 * ...
	 * @author imagame
	 */
	public class ImaUtils 
	{
		public static const TWOPI:Number = 2 * Math.PI;
		
		static public function randomize(min:Number, max:Number):Number 
		{
			return (Math.random()*(max - min) + min);
		}
		static public function toRadians (inDegrees:Number):Number
		{
			return (inDegrees * Math.PI / 180);
		}
		static public function toDegrees (inRadians:Number):Number
		{
			return (inRadians * 180 / Math.PI);
		}

		//-----------------------
		public static function toArray(myVector: Vector.<Object>):Array {
			var myArray:Array = new Array(myVector.length);
			for (var i:uint = 0; i < myVector.length; i++) {
				myArray[i] = myVector[i];
			}			
			return myArray;
		}
		
		public static function toVector(myArray: Array): Vector.<Object> {
			var myVector:Vector.<Object> = Vector.<Object>(myArray);
			return myVector;
		
			/*			
			var myVector:Vector.<Piece> = new Vector.<Piece>(myArray.length);
			var i:int=myArray.length;
			while (i--) {
				myVector[i] = myArray[i];
			}
			return myVector;
			*/
		}	
		
			/** 
			 * Shuffles the items of the given Vector. AS3COMMONS.COLLECTIONS
			 * 
			 * <p>Modern version of the Fisher-Yates algorithm.</p> 
			 * 
			 * @param array The array to shuffle. 
			 * @return <code>true</code> if the array has more than 1 item. 
			 */ 
			public static function shuffle(v : Vector.<int>) : Boolean { 
					var i : uint = v.length; 

					if (i < 2) return false; 
					
					var j : uint; 
					var o : *; 
					while (--i) { 
							j = Math.floor(Math.random() * (i + 1)); 
							o = v[i]; 
							v[i] = v[j]; 
							v[j] = o; 
					} 
					
					return true; 
			} 		
	}

}