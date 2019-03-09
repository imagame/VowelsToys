package com.imagame.game 
{
	import com.greensock.TweenLite;
	import com.imagame.engine.ImaDialog;
	import com.imagame.engine.ImaIcon;
	import com.imagame.engine.ImaSprite;
	import com.imagame.engine.ImaSpriteAnim;
	import com.imagame.engine.ImaState;
	import com.imagame.engine.Registry;
	import com.imagame.utils.ImaBitmapSheet;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * End Level Dialog
	 * Dialog shown when a level is complete
	 * @author imagame
	 */
	public class EndLevelDialog extends ImaDialog 
	{
		protected var _idPhase: uint; 	//Phase where the level is included. Values= [1..9]
		
		protected var _iconLvl: Vector.<ImaIcon>; // ImaSpriteAnim; 
		protected var _srcPos: Vector.<Point>;        //Source stars relative Position within _sprIcon sprite. (for each star in each _spricon frame) 
		protected var _idxPos: uint;	//Index on _srcPos (for the current start tweeening iteration)
		
		protected static const STS_EXECUTING:uint = 6; //Free state, to use and extend in subclasse   

		/**
		 * Dialog to manage the end of a vowel level for each phase
		 * - Shows star icon animation based on level finished and if it is the firs time is completed
		 * - Increments the game progress (when applies)
		 * @param	id	Idlevel for each phase. Values: 0,1,2
		 */
		public function EndLevelDialog(id:uint, phase: uint, parentRef:ImaState) 
		{
			super(id, 
				parentRef, 				
				new ImaBitmapSheet(Assets.GfxIconsEndLevelDlg, Assets.IMG_ICONLEVELDLG_WIDTH, Assets.IMG_ICONLEVELDLG_HEIGHT),
				[true, false, true]); 
			_idPhase = phase;
			visible = false;			
			
			//Set icon depending on current level-phase, and if it is the first time is completed
			_sprIcon.addAnimation("level1", _tileSheet, null, [4, 5]); //L1 achieved, current ok
			_sprIcon.addAnimation("level2", _tileSheet, null, [7, 8]);
			_sprIcon.addAnimation("level3", _tileSheet, null, [10,11]);
			_sprIcon.addAnimation("level4", _tileSheet, null, [13,14]);
			_sprIcon.addAnimation("level5", _tileSheet, null, [16,17]);
			
			_srcPos = new Vector.<Point>(Assets.GAM_NUM_LEVELS);        //5 levels (leup pivot point)
			_srcPos[0] = new Point(48,136); 	//level 1
			_srcPos[1] = new Point(144,128); 	//level 2
			_srcPos[2] = new Point(112,56);  	//level 3	
			_srcPos[3] = new Point(192,32); 	//level 4
			_srcPos[4] = new Point(232,120);  	//level 5	
			
			//Create achieved levels Number icons
			_iconLvl = new Vector.<ImaIcon>(Assets.GAM_NUM_LEVELS);
			for (var i:uint = 0; i < Assets.GAM_NUM_LEVELS; i++) {
				_iconLvl[i] = new ImaIcon(i, _tileSheet, [(i+1)*3+1]);
				_iconLvl[i].x = _srcPos[i].x; 
				_iconLvl[i].y = _srcPos[i].y; 
				addChild(_iconLvl[i]);        //add icon to container 
				_iconLvl[i].visible = false;
				this.setChildIndex(_iconLvl[i],2); //move to the bottom
			}			
		}
		
		override public function destroy():void {   
			for(var i:uint=0; i< _srcPos.length; i++){ 
					_srcPos[i] = null; 
			} 
			_srcPos = null; 			

			for (var i:uint = 0; i < _iconLvl.length; i++)  {
					_iconLvl[i].destroy();
					_iconLvl[i] = null;
			}
			_iconLvl = null;

			super.destroy(); 		
		}
		
		 /**
		 * Opening event where perform init actions, after each time the dialog is shown.
		 */
		override protected function open():void {
			Assets.playSound("EndLevel");
			
			
			//Check which levels are achieved and show achieved icon levels in its position				
			//var maxLvl:int = 6;// Assets.GAM_NUM_LEVELS + 1; //(Registry.gpMgr as PropManager).getLevelProgress(_idPhase); //Max Level arrived: 2 lvl-1 completed,.., 6 lvl-5 completed
			var maxLvl:int = (Registry.gpMgr as PropManager).getLevelProgress(_idPhase); //Max Level arrived: 2 lvl-1 completed,.., 6 lvl-5 completed
			
			//Show levels already achieved (by hiding those one not reached yet)
			for (var i:uint = 0; i < Assets.GAM_NUM_LEVELS; i++)
				if(i > (maxLvl-2))
					_iconLvl[i].visible = false;					
	
			//set the animation depending on the level and if it is completed the first time
			_sprIcon.x = _srcPos[_id-1].x; 
			_sprIcon.y = _srcPos[_id-1].y; 
			_sprIcon.playAnimation(String("level" + _id ));
			_sprIcon.setFrame(1); //set level achieved frame
			//Center frame
			_sprContainer.x = (uint) (_sprIcon.x + _sprIcon.width*0.5); 
			_sprContainer.y = (uint) (_sprIcon.y + _sprIcon.height*0.5);   
		}
		  
		
	}

}