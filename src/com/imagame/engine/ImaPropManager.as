package com.imagame.engine 
{
	import flash.net.SharedObject;
	/**
	 * Game Properties manager
	 * @author imagame
	 */
	public class ImaPropManager 
	{
		protected var _soName: String; 
		
		public function ImaPropManager(soName:String) 
		{                         
				_soName = soName; 
		}                 
		
		public function save():void{ 
			var so:SharedObject = SharedObject.getLocal(_soName); 
			getData(so.data); //Get data from prop mgr subclass 
			so.flush(); 
		} 
		
		public function load():void{ 
			var so:SharedObject = SharedObject.getLocal(_soName); 
			//if(true){
			if(so.data.imaEngineVersion == null){ //solo se producirá la primera vez que se ejecute la app --la primera vez que se intente cargar los datos grabados-- 
				//Init prop data with 
				// a) initial values 
				// b) current valued 
				so.data.imaEngineVersion = Registry.IMAENGINE_VERSION; 
				so.data.gameVersion = Registry.GAME_VERSION; 
				initData(); //set initial game property data 
			} 
			else { 
				setData(so.data); //set game property data sent by param 
			}                         
		} 
		
		//To be overriden 
		protected function initData():void { 
		} 
		
		/**
		 * Set "game" properties from a data Object, which has been obtained from saved data in a local store, or initialized data by the game 
		 * @param	data
		 */
		protected function setData(data: Object):void { 
			Registry.bSnd = data.bSnd; 
			//To be overriden
		} 

		/**
		 * Get "game" properties in data Object, to be saved in a local store. 
		 * @param	data
		 */
		protected function getData(data:Object):void { 
			//versions
			data.imaEngineVersion = Registry.IMAENGINE_VERSION; 
			data.gameVersion = Registry.GAME_VERSION; 
			//config data 
			data.bSnd = Registry.bSnd; 
			//Rest: To be overriden
		} 		
		
			
	}

}