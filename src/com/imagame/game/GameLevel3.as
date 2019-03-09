package com.imagame.game 
{
	import com.imagame.engine.ImaSprite;
	import com.imagame.engine.Registry;
	import com.imagame.utils.ImaBitmapSheet;
	import com.imagame.utils.ImaCachedBitmap;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * Jigsaw puzzle with different shape-groups pieces
	 * @author imagame
	 */
	public class GameLevel3 extends GameState 
	{
		
		/**
		 * Constructor
		 * @param	id			Current level of difficulty (1..numLevels)
		 * @param	idPhase		0..4 (a,e,i,o,u)
		 * @param	numLevels	Number of difficulty levels in this phase (5)
		 */
		public function GameLevel3(id:uint, idPhase:uint, numLevels:uint) 
		{
			super(id, idPhase, numLevels);		
			trace("GAMESTATE >> GameLevel3() " + idPhase + "." + id + "(" + numLevels + ")"); 

		}
		
		/** 
		* Called once this state has been created, and after the old state has been destroyed 
		* Create gamestate components (hud buttons and background), show puzzle and box graphics, and init them 
		*/ 
		override public function create():void 
		{ 
			trace("GameLevel3->create() " + _idPhase + "." + id);
			
			//Create puzzle and box 
			var _bmpSheet:ImaBitmapSheet = new ImaBitmapSheet(Assets.vowelImages[_idPhase], Assets.IMG_VOWEL_WIDTH, Assets.IMG_VOWEL_HEIGHT); 			
			
			var bmp:Bitmap = _bkg.getImg();						
		/*	bmp.bitmapData.copyPixels(
				_bmpSheet.getTile(1).bitmapData, 
				new Rectangle(0, 0, Assets.IMG_VOWEL_WIDTH, Assets.IMG_VOWEL_HEIGHT), 
				new Point((uint)((Registry.gameRect.width - Assets.IMG_VOWEL_WIDTH) * 0.5), 
				(uint)(Registry.appUpOffset + 16)),
				null,null,true);
			*/
			_pieceCreator = new PieceCreator3(_id, 
											_idPhase,
											_bmpSheet.getTile(1), 
											ImaCachedBitmap.instance.createBitmapFromSheetDirect(bmp, 0, 0, Registry.gameRect.width, Registry.gameRect.height),
											this,
											(Registry.gpMgr as PropManager).getlevelPuzzlePieces(_idPhase), 
											(Registry.gpMgr as PropManager).getlevelPuzzlePos(_idPhase)
											); //Factory method creador de puzzle de piezas 
											
			
			_puzzle = _pieceCreator.createPuzzle();
			_box = new Box3(_idPhase, _pieceCreator.getPieces(), getPlayableRect());    //Sent number of piece categories

			_puzzle.setRefBox(_box); 
			_box.setRefPuzzle(_puzzle); 
  			
			_container.addChild(_puzzle);         
			_container.addChild(_box); 

			super.create();        //create hud buttons, and set STS to STS_PLAY 
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
					//goLevel( -1); //ERR: not possible to reach here if next butto disabled in last level. Anyway forced to return to menu
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
				//_sbsts = SBSTS_INIT; 
				
			} 			        
		}    
		
	}

}