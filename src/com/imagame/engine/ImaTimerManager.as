package com.imagame.engine 
{
	/**
	 * ...
	 * @author imagame
	 */
	public class ImaTimerManager 
	{
		protected var _timers:Array; 
               
        public function ImaTimerManager() { 
			_timers = new Array(); 
		} 
		
		public function destroy():void { 
			clear(); 
			_timers = null; 
		} 
                
		/** 
		 * Called by <code>Main.update()</code> before the game state has been updated. 
		 * Cycles through timers and calls <code>update()</code> on each one. 
		 */ 
		public function update():void { 
			var i:int = _timers.length-1; 
			var timer:ImaTimer; 
			while(i >= 0) { 
				timer = _timers[i--] as ImaTimer; 
				if((timer != null) && !timer.paused && !timer.finished && (timer.time > 0)) 
					timer.update(); 
			} 
		} 
                
		/** 
		 * Add a new timer to the timer manager. 
		 * Usually called automatically by <code>ImaTimer</code>'s constructor. 
		 * 
		 * @param        Timer        The <code>ImaTimer</code> you want to add to the manager. 
		 */ 
		public function add(timer:ImaTimer):void { 
			_timers.push(timer); 
		} 
                
		/** 
		 * Remove a timer from the timer manager. 
		 * Usually called automatically by <code>ImaTimer</code>'s <code>stop()</code> function. 
		 * 
		 * @param        timer        The <code>ImaTimer</code> you want to remove from the manager. 
		 */ 
		public function remove(timer:ImaTimer):void { 
			var index:int = _timers.indexOf(timer); 
			if(index >= 0) 
				_timers.splice(index,1); 
		} 
                
		/** 
		 * Removes all the timers from the timer manager. 
		 */ 
		public function clear():void { 
			var i:int = _timers.length-1; 
			var timer:ImaTimer; 
			while(i >= 0) { 
				timer = _timers[i--] as ImaTimer; 
				if(timer != null) 
					timer.destroy(); 
			} 
			_timers.length = 0; 
		} 


	}

}