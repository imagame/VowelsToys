
package com.imagame.game 
{ 
	import com.imagame.engine.ImaSprite; 
	import com.imagame.engine.Registry; 
	import com.imagame.utils.ImaBitmapSheet; 
	import com.imagame.utils.ImaCachedBitmap; 
	import flash.display.Bitmap; 
	import flash.events.MouseEvent;
	
	/** 
	 * Jigsaw Puzzle on vowel characters with selected bodyparts 
	 * @author imagame 
	 */ 
	public class GameLevel2 extends GameState 
	{ 
		/** 
		 * 
		 * @param        id               Current difficulty level: 1..5 
		 * @param        idPhase          0..4	(A,E,I,O,U) 
		 * @param        numLevels        Number of difficulty levels of this phase, plus initial bodypart selection level (Total= 1+ currVer(5) = 6) 
		 */ 
		public function GameLevel2(id:uint, idPhase:uint, numLevels:uint) 
		{ 
			super(id, idPhase, numLevels); 
			trace("GAMESTATE >> GameLevel2() " + idPhase + "." + id + "(" + numLevels + ")"); 
		} 

		/** 
		* Called once this state has been created, and after the old state has been destroyed 
		* Create gamestate components (hud buttons and background), show puzzle and box graphics, and init them 
		*/ 
		override public function create():void 
		{ 
			trace("GameLevel2->create() " + _idPhase + "." + id); 
			
			//Create puzzle and box 
			var _bmpSheet:ImaBitmapSheet = new ImaBitmapSheet(Assets.vowelImages[_idPhase], Assets.IMG_VOWEL_WIDTH, Assets.IMG_VOWEL_HEIGHT); 
			var bmp:Bitmap = _bmpSheet.getTile(_id); 
			_pieceCreator = new PieceCreator2(	_id, 
												_idPhase, 
												_bmpSheet.getTile(1), //bmp
												(Registry.gpMgr as PropManager).getlevelPuzzlePieces(_idPhase), 
												(Registry.gpMgr as PropManager).getlevelPuzzlePos(_idPhase)); //Factory method creador de puzzle de piezas 
			
			_puzzle = _pieceCreator.createPuzzle(); 
			_box = new Box2(0, _pieceCreator.getPieces(), getPlayableRect());    //Sent number of piece categories 

			_puzzle.setRefBox(_box); 
			_box.setRefPuzzle(_puzzle); 
			  
			_container.addChild(_puzzle);         
			_container.addChild(_box); 

			super.create();        //create hud buttons, and set STS to STS_PLAY 
			
			//Enable Next HUD button if current level already achieved and is not the last level
			if(_id < Assets.GAM_NUM_LEVELS && (Registry.gpMgr as PropManager).getLevelProgress(_idPhase) > _id) //id: from 1 to 5, Progress: from 2 if lvl-1 achieved, to 6 if lvl-5 achieved
				_btnext.enable(onNextClick); 
		} 
		
		
		override public function destroy():void 
		{                         
				trace("GameLevel1->destroy() " + _idPhase + "." + id); 
				
				//destroy puzzle components 
				_box.destroy(); 
				_container.removeChild(_box); 
				_box = null; 
				_puzzle.destroy(); 
				_container.removeChild(_puzzle); 
				_puzzle = null; 
				_pieceCreator.destroy(); 
				_pieceCreator = null; 
				
				super.destroy(); 
		}                 

	
		/**
		 * Click Callback on EndLevelDialog
		 * @param	idBt	Button id in the dialog 0:Menu, 1:Repeat, 2: Menu 
		 */
		override protected function onDlgEndLevelClick(idBt: uint):void { 
			//Save level progress
			(Registry.gpMgr as PropManager).advanceLevel(_idPhase, _id); //advance current lvl 
			Registry.gpMgr.save();      
						
			//Continue to the next level of the current Number of return to the menu if it is the last level
			if(idBt == 2) { //"NEXT" Button
				if (id < _numLevels - 1) {
					goLevel(id + 1); //switch to a new level state, the next to the current level, 				
				} 
				else {
					//goLevel( -1); //ERR: not possible to reach here if next button disabled in last level. Anyway forced to return to menu
					if (Registry.bAd) {
						Registry.adMgr.showInterstitial();  //el CB de fin de interstitial llamará a función que ejecutará goLevel(-1)
						//Cambio ANE:admob 6.12.2
						//_sts = STS_END;
						//_sts = SBSTS_CONT;	
						goLevel(-1); //Cambio ANE:admob 6.12.2
					}
					else
						goLevel(-1); 
				}
			}
			//Completed the round
			else if (idBt == 0) { //"Menu" Button after finishing the last level of the roundT; 
				//goLevel( -1);
				if (Registry.bAd) {
					Registry.adMgr.showInterstitial();  //el CB de fin de interstitial llamará a función que ejecutará goLevel(-1)
					//Cambio ANE:admob 6.12.2
					//_sts = STS_END;
					//_sts = SBSTS_CONT;	
					goLevel(-1); //Cambio ANE:admob 6.12.2
				}
				else
					goLevel(-1); 
			}				
		} 
		
		
		override public function update():void 
		{ 
				super.update(); 
				//Chk if final condition is met and update game progress status 
				if (_box.state == ImaSprite.STS_FINISHED && _sts != STS_END){ 
						_sts = STS_END; 
						_sbsts = SBSTS_INIT; 
				} 
						
		}                                 
			
	} 

} 