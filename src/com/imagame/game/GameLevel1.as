package com.imagame.game 
{
	import com.greensock.easing.Circ;
	import com.greensock.loading.data.ImageLoaderVars;
	import com.greensock.TweenLite;
	import com.imagame.engine.ImaButton;
	import com.imagame.engine.ImaHUDButton;
	import com.imagame.engine.ImaIcon;
	import com.imagame.engine.ImaSprite;
	import com.imagame.engine.Registry;
	import com.imagame.fx.ImaFx;
	import com.imagame.utils.ImaBitmapSheet;
	import com.imagame.utils.ImaCachedBitmap;
	import com.imagame.utils.ImaUtils;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author imagame
	 */
	public class GameLevel1 extends GameState 
	{
		private var _btTObjList: Vector.<ImaHUDButton>;		//list of Body Object type buttons
		private var _numTObj: uint;	
		private var _idxSelTObj: uint = 0;        //0..NUMTOBJ
		private var _icoBoxOut: ImaIcon;
		
		public var signalTObjClick: Signal; 
		private static var _idTween1: TweenLite = null;
		private static var _idTween2: TweenLite = null;
		
		/**
		 * GameLevel 1 constructor
		 * @param	id			0(0: level bodypart selection)
		 * @param	idPhase		0..9 (0:A, 1:E, 2:I, 3:O, 4:U, 5:a, 6:e, 7:i, 8:o, 9:u)
		 * @param	numLevels	6 (1+5)Num of total levels for idPhase
		 */
		public function GameLevel1(id:uint, idPhase:uint, numLevels:uint) 
		{ 
			super(id, idPhase, numLevels); 
			trace("GAMESTATE >> GameLevel1() " + idPhase + "." + id + "(" + numLevels + ")"); 
			_numTObj = Assets.NUMTOBJ + 1; //"Random" type object added
			signalTObjClick = new Signal(); 
		} 

		/** 
		* Called once this state has been created, and after the old state has been destroyed 
		* Create gamestate components (hud buttons and background), show puzzle and box graphics, and init them 
		*/ 
		override public function create():void 
		{ 
			trace("GameLevel1->create() " + _idPhase + "." + id);
			
			//Create TypeObjects buttons
			var _bmpSheetTObj:ImaBitmapSheet = new ImaBitmapSheet(Assets.GfxBtnTObjImg, Assets.IMG_BTN_TOBJ_WIDTH, Assets.IMG_BTN_TOBJ_HEIGHT); 
			//min: 52 (8 sepy + 36 btMenu + 8 sepy), max=44+32 (32 sepy para vowel) 
			//Como min:52, si(upoffset + 32 > 52) upoffset+32, sino 52 (8+36+8) 
			//iniy = (Registry.appUpOffset + 32 > 52)? Registry.appUpOffset+32:52; 
			var iniy:uint = (Registry.appUpOffset > 20)? Registry.appUpOffset+32:52; 
			_btTObjList = new Vector.<ImaHUDButton>(_numTObj);	
			for(var i:uint=0; i< _numTObj; i++) {        //Set active buttons, depending on game progress 
				_btTObjList[i] = new ImaHUDButton(i, _bmpSheetTObj, i, 3, ImaSprite.POS_UPRI, 0, i, 8, iniy, 0,4, Assets.IMG_BTN_TOBJ_WIDTH, Assets.IMG_BTN_TOBJ_HEIGHT); // 1..3 tile id,4 states, 1: upri corner, pos: 0..2
				_btTObjList[i].enable(onHUDLevelClick); //enables and add the subscriber func to the signal                                                                                             
				_container.addChild(_btTObjList[i]);
			}           
			_idxSelTObj = 0; 
			_btTObjList[_idxSelTObj].selected = true; //Set selected button for the current level (by default selected is false) 

			//create out-box graphics
			//Dim: 112x272. Pos: 0,48
			_icoBoxOut = new ImaIcon(0, new ImaBitmapSheet(Assets.GfxBoxOutImg, Assets.IMG_ICO_BOXOUT_WIDTH, Assets.IMG_ICO_BOXOUT_HEIGHT), [0, 1, 2, 3, 4, 5]);
			_container.addChild(_icoBoxOut); 
			_icoBoxOut.x = 0;
			//_icoBoxOut.y = (Registry.appUpOffset > 20)? Registry.appUpOffset + 32:52;
			_icoBoxOut.y = Registry.appUpOffset + 40;	//8up + 36Hudbutton - 4 (to leave y-space 280 for box) => Tot: 320
			_icoBoxOut.setFrame(_idPhase%Assets.NUMTOBJ );
			
			//Create puzzle and box 
			_pieceCreator = new PieceCreator1(_idPhase); //Factory method creador de puzzle de piezas 
			
			_puzzle = _pieceCreator.createPuzzle();
			_box = new Box1(_idPhase, _pieceCreator.getPieces(), Assets.NUMBODYPART, Assets.NUMTOBJ);    //Sent number of piece categories

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
			
			//destroy TObj 
			for(var i:uint=0; i< _numTObj; i++){ 
				_container.removeChild(_btTObjList[i]); 
				_btTObjList[i].destroy(); 
				_btTObjList[i] = null; 
			} 
			_btTObjList = null; 
			
			signalTObjClick.removeAll(); 
			signalTObjClick = null; 
			
			if (_idTween1 != null)
				_idTween1.kill();
			if (_idTween2 != null)
				_idTween2.kill();
				
			super.destroy(); 
		}                 
		
		
		/**
		 * Put a random piece in each object type position in puzzle 
		 */
		private function randomPiecesInPuzzle():void {
			trace("randomPiecesInPuzzle");
			Assets.playSound("TObjRnd"); 
			
			for(var i:int=0; i<_numTObj-1; i++) {        //foreach object type (random objt type button is not selected) 
				//dejar libre la pos i, en caso de que este ocupada 
				var piece: Piece1 = ((Piece1)(_puzzle.retrieveByDstPosIdx(i))); 
				if(piece != null) //si hay piece en puz en pos i 
				{      
					piece.ActionMoveFromPuzzleToBox();
					//_puzzle.removePieceFromPuzzle(piece);  //quitar de puz                                 
					//_box.setPieceInBox(piece);        // y poner en box         
				} 
				
				//poner pieza aleatoria en pos i 
				var idx:int = ((int)(ImaUtils.randomize(1, Assets.NUMBODYPART+1)))-1; //elegir pieza de tipo i 
				piece = (_box as Box1).retrieveByCategoryIndex(i, idx); //identificar la pieza en box                 
				_box.removePieceFromBox(piece);  //piece.quitar de box 
				_puzzle.setPieceInPuzzlePos(piece, i); //piece.poner en puz 
				
			} 			
		}
		
		override protected function onNextClick(event:MouseEvent):void { 
			Assets.playSound("BtHud"); 
			                 
			//TODO - grabar en PropManager (Registry.gpMgr.advanceLevel1(pieceId: Vector.<uint>, posBodyPart: Vector.<Point>) 
			(Registry.gpMgr as PropManager).advanceFirstLevel(_idPhase, _puzzle.getIdPiecesList(), _puzzle.getPosPiecesList()); //ImaUtils.toVector(_members), ); 
			Registry.gpMgr.save();        //save to shared object   			
			
			goLevel(1);      
		}

		private function onHUDLevelClick(event:MouseEvent):void { 
			Assets.playSound("BtHud"); 

			_btTObjList[_idxSelTObj].selected = false;
			_idxSelTObj = event.currentTarget.id; // / 3;
			_btTObjList[_idxSelTObj].selected = true;
			
			//signalTObjClick.dispatch(_idxSelTObj);
			if(_idxSelTObj == _numTObj-1) 
				randomPiecesInPuzzle();
				
			signalTObjClick.dispatch(_idxSelTObj);
		} 
		
		override protected function createEndDialog():Boolean { 
			return false;
		}
		
		
		override public function update():void 
		{ 
			super.update(); 
			//If we are not in end state 
			if (_sts != STS_END) { 
				//Chk if final condition is met and update game progress status 
				
				if(_puzzle.state == ImaSprite.STS_FINISHED){ 
					_sts = STS_END; 
					//Enable Next button 
					_btnext.enable(onNextClick);
					onTweenButtonOn();
					
				} 								
			} 	        
		}    
		
		public function onTweenButtonOn():void { 
			//ImaFx.imaFxZoomIn(this, _btnext, 1.4, 0.5, true, onTweenButtonOn); 
			//TweenLite.to(_btnext, 0.5, {scaleX:1.6, scaleY:1.2, ease:Circ.easeOut, onComplete: onTweenButtonOnEnd } );  
			
			var srcX:int = _btnext.x; 
			var srcY:int = _btnext.y; 
			
			var dstX:int = srcX - (((_btnext.width * 1.2)- _btnext.width)*0.5); 
			var dstY:int = srcY - (((_btnext.height * 1.2)- _btnext.height)*0.5); 
			
			_idTween1 = TweenLite.to(_btnext, 0.7, 
				{ 
					x:dstX, 
					y:dstY, 
					scaleX:1.2, 
					scaleY:1.2 , 
					onComplete: function() { _idTween2 = TweenLite.to(_btnext, 0.3, { x:srcX, y:srcY, alpha:1, scaleX:1, scaleY:1, onComplete: onTweenButtonOn } )} 
				} );
		
		} 
		public function onTweenButtonOnEnd():void { 
			//TweenLite.to(_btnext, 0.25, { scaleX:1, scaleY:1, ease:Circ.easeIn } ); 
		} 
		
	}

}