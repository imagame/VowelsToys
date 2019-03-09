package com.imagame.game 
{
	import com.greensock.TweenLite;
	import com.imagame.engine.ImaButton;
	import com.imagame.engine.ImaHUDButton;
	import com.imagame.engine.ImaPanel;
	import com.imagame.engine.ImaTimer;
	import com.imagame.engine.Registry;
	import com.imagame.utils.ImaBitmapSheet;
	import com.imagame.utils.ImaCachedBitmap;
	import com.imagame.utils.ImaSubBitmapSheet;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author imagame
	 */
	public class PanelMenuFase2 extends ImaPanel 
	{
		public var signal: Signal; 

		private var _numLevels: uint;         
		private var _dlg: Bitmap; 
		private var _tileSheet: ImaBitmapSheet; //graphics tilesheet 
		private var _subtileSheet: ImaSubBitmapSheet; 
		private var _btLvl: Vector.<ImaButton>;

		private var _bTweenVowel: Boolean; //Indicates if any vowel Button tween is in progress;
		private var _idxTweenVowel:int; //idx of vowel (0:A,..4:U) if vowel button tween in progress
		private static var _idTween1: TweenLite = null;
		private static var _idTween2: TweenLite = null;
		private var _tweenTimer: ImaTimer;
		
		public function PanelMenuFase2(id:uint, gfxTitle:Class=null, bBack:Boolean=false) 
		{
			super(id, Assets.GfxTitFase, true); 
			_numLevels = Assets.GAM_NUM_LEVELS;
			
			_dlg = ImaCachedBitmap.instance.createBitmap(Assets.GfxDlgMenuPhase2); 
			_dlg.x = (uint)((Registry.gameRect.width - _dlg.width)* 0.5); //centered horz in screen                         
			_dlg.y = (uint)((Registry.gameRect.height - Registry.appUpOffset - 40 - _dlg.height)* 0.5) + Registry.appUpOffset + 40;     //centered vert between title and bottom                             
			addChild(_dlg);    
			
			
			//Level Buttons creation (in dialog) 
			_btLvl = new Vector.<ImaButton>(5* (_numLevels+1)); 
			_tileSheet = new ImaBitmapSheet(Assets.GfxButtonsPanelMenuFase2, Assets.BUTTON_LEVELVO_WIDTH, Assets.BUTTON_LEVELVO_HEIGHT); //frames sorted: from left to right, up to down, vowel an its levels. 
			var sepx: uint = 24;//horz space between two cols of buttons 
			var sepy: uint = 0; //vert space between two buttons (bottom of sup button, and top of inf button) 
			var inix: uint = _dlg.x + sepx*2; //init x for first buttons column 
			var iniy: uint = _dlg.y + _dlg.height - Assets.BUTTON_LEVELVO_HEIGHT + 4;//init bottom-y for first button in column

			var idx: uint = 0;			
			//Create vowels buttons
			for (var i:uint = 0; i < 5; i++) { //5 vowels 
				_btLvl[idx] = new ImaButton(idx, _tileSheet, i*4, i*4+2, i*4+1); 
				_btLvl[idx].x = inix + sepx * i + Assets.BUTTON_LEVELVO_WIDTH * i; 
				_btLvl[idx].y = iniy; 
				addChild(_btLvl[idx]); 
				idx += _numLevels+1; 				
			}
			
			//Create levels buttons (5 columns of _numLevels buttons, one colum per each vowel)
			_subtileSheet = new ImaSubBitmapSheet(Assets.GfxButtonsPanelMenuFase2, Assets.BUTTON_LEVELNO_WIDTH, Assets.BUTTON_LEVELNO_HEIGHT, 
													new Rectangle(0, Assets.BUTTON_LEVELVO_HEIGHT * 5, Assets.BUTTON_LEVELNO_WIDTH * 4, Assets.BUTTON_LEVELNO_HEIGHT * _numLevels));
			idx = 0;
			for(var i:uint = 0; i< 5; i++) { //5 vowels  
				idx++; 
				//Add difficulty level buttons for vowel 
				for(var j:uint = 0; j< _numLevels; j++){                                         
					_btLvl[idx] = new ImaHUDButton(idx,_subtileSheet, j, 4, 0, 0); //_btLvl[idx] = new ImaHUDButton(_subtileSheet, j, 4, 0, 0);
					_btLvl[idx].x = inix + sepx * i + Assets.BUTTON_LEVELVO_WIDTH * i + 4; 
					_btLvl[idx].y = (j == 0)?_btLvl[idx - 1].y - Assets.BUTTON_LEVELNO_HEIGHT - 6: _btLvl[idx - 1].y - Assets.BUTTON_LEVELNO_HEIGHT; 
					addChild(_btLvl[idx]); 				
					_btLvl[idx].disable();
					idx++; 
				}                                                                 
			} 
			
			//Enable buttons corresponding to BodyPart selection levels: init() function will be automatically called
			_tweenTimer = new ImaTimer();
			_bTweenVowel = false;
			_idxTweenVowel = 4; 
			_tweenTimer.start(1, 0, OnTweenButtonTimer); 
			
			//click signals 
			signal = new Signal(); 
		}
		
		override public function destroy():void { 
			for (var i:int = 0; i < _btLvl.length; i++){                         
				_btLvl[i].destroy(); 
				removeChild(_btLvl[i]); 
				_btLvl[i] = null; 
			} 
			_btLvl = null; 	
			
			if (_idTween1 != null)
				_idTween1.kill();
			if (_idTween2 != null)
				_idTween2.kill();
			
			_tweenTimer.destroy(); 
			_tweenTimer = null; 			
			signal.removeAll();
			signal = null;			
		}

		/**
		 * Init function called each time a panel is getting active (visible when switching panels in a menu panel-chain) 
		 */
		override public function init():void { 
			//Enable buttons corresponding to BodyPart selection levels 
			for (var i:uint = 0; i < 5; i++) { //5 vowelds 
				_btLvl[i*(_numLevels+1)].enable(onLevelClick); 
						
				//Enable buttons corresponding to open levels 
				var maxLvl:int = (Registry.gpMgr as PropManager).getLevelProgress(i+5); //get max Level reached for gamelevels 5..9 [a..u]
				for(var j:uint = 1; j<= _numLevels; j++) { 
					//[TEST]
					//if (true) {
					if(maxLvl >= j)  
						_btLvl[i*(_numLevels+1)+j].enable(onLevelClick);                                                 
					else	
						_btLvl[i * (_numLevels + 1) + j].disable(); 
				}         
			}     	
		}
		
		//--------------------------------------------------------- Signal handling and update control
			
		public function onLevelClick(event:MouseEvent):void { 
			var idval: uint = event.currentTarget.id; //0..5*(numLevels+1) => Total = 30 buttons (0..29) => 0:A, 1..5: A-levels, 6: B, 7..11: B-Levels,..., 24: U,25..29: U-Levels 
			if (idval % 6 == 0 )
				Assets.playSound("BtVowel");
			else
				Assets.playSound("BtLevel");
			signal.dispatch(idval); 
		}  
		
		
		public function OnTweenButtonTimer(timer: ImaTimer):void {
			if (!_bTweenVowel) {
				_bTweenVowel = true;
				_idxTweenVowel = (_idxTweenVowel + 1) % 5;
				onTweenButtonOn(_idxTweenVowel);
			}	
		}
		
		private function onTweenButtonOn(pidx: int):void { 
			var idx = pidx * (_numLevels + 1);	//vowel button idx in _btLvl[]
			var maxLvl:int = (Registry.gpMgr as PropManager).getLevelProgress(pidx+5);
			//Alt 1: fx in the max lvl of each vowel //idx += maxLvl;
			//Alt 2: fx in vowel, only if level 1 not open
			if (maxLvl != 0) {
				_bTweenVowel = false;
				return;
			}
			
			var srcX:Number = _btLvl[idx].x; 
			var srcY:Number = _btLvl[idx].y; 
			
			var dstX:Number = srcX - (((_btLvl[idx].width * 1.2)- _btLvl[idx].width)*0.5); 
			var dstY:Number = srcY - (((_btLvl[idx].height * 1.2)- _btLvl[idx].height)*0.5); 
			
			_idTween1 = TweenLite.to(_btLvl[idx], 0.2, 
				{ 
					x:dstX, 
					y:dstY, 
					scaleX:1.2, 
					scaleY:1.2 ,
					onComplete: function() { _idTween2 = TweenLite.to(_btLvl[idx], 0.2, 
															{ 	x:srcX, 
																y:srcY, 
																scaleX:1, 
																scaleY:1, 
																onComplete: _bTweenVowel = false 
															} ) 
											} 
				} );
		
		}  		
	}

}