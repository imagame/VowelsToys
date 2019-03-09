package com.imagame.game 
{
	import com.greensock.TweenLite;
	import com.imagame.engine.ImaBackground;
	import com.imagame.engine.ImaButton;
	import com.imagame.engine.ImaDialog;
	import com.imagame.engine.ImaHUDBar;
	import com.imagame.engine.ImaHUDButton;
	import com.imagame.engine.ImaSprite;
	import com.imagame.engine.ImaState;
	import com.imagame.engine.Registry;
	import com.imagame.utils.ImaBitmapSheet;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	//Option-0
	//import so.cuo.anes.admob.AdEvent;
	//Option-1
	import so.cuo.platform.admob.AdmobEvent;
	//Option-3
	//import com.codealchemy.ane.admobane.AdMobEvent;
	
	
	/** 
	 * Game state base class 
	 * Includes menu back button and navigation buttos to all the puzzle game states for the current level 
	 * Manage pause and resume state (if needed) 
	 * Handles level progress, checking the final level condition and acting accordingly 
	 * @author imagame 
	 */ 
	public class GameState extends ImaState 
	{ 
		protected var _idPhase: uint; 	//Phase where the level is included. Values= [1..9]
		protected var _numLevels: uint;       //number of levels in current state phase 
		
		protected var _btmenu: ImaHUDButton;
		protected var _btnext: ImaHUDButton; 
		protected var _touching: Array;
		
		//puzzle game objects
		protected var _pieceCreator: IPieceCreator; 
		protected var _puzzle: AbstractPuzzle; 
		protected var _box: AbstractBox; 
		
		protected var _dlgEndLevelState: ImaDialog;
		//private var _bAdIntClosed: Boolean;
		
		/**
		 * Vowels Toys Game State 
		 * @param	id			id of the button within the phase [0..numLevels-1]
		 * @param	idPhase		[1..9]
		 * @param	numLevels	Number of levels within the phase
		 */
		public function GameState(id: uint, idPhase: uint, numLevels: uint) 
		{ 
			super(id); 
			trace("IMASTATE >> GameState() "+ idPhase+"."+id+"("+numLevels+")"); 
			_idPhase = idPhase; 
			_numLevels = numLevels; 
			_touching = [];	
			
			_bkg = new ImaBackground(Assets.gameIdBkg[getGlobalLevel()*3], Assets.gameIdBkg[getGlobalLevel()*3+1],Assets.gameIdBkg[getGlobalLevel()*3+2] ); 
			_container.addChild(_bkg);
		} 

	
		// override this 
		override public function create():void 
		{ 
			trace("GameState->create()"); 
			
			//Create HUD menu button    
			var _bmpSheet:ImaBitmapSheet = new ImaBitmapSheet(Assets.GfxButtonsHUD, Assets.BUTTON_HUD_WIDTH, Assets.BUTTON_HUD_HEIGHT); 
			_btmenu = new ImaHUDButton(0, _bmpSheet, 0, 4, ImaSprite.POS_UPLE, 0,0, 8, 8); 
			_btmenu.enable(onMenuClick);
 			_container.addChild(_btmenu);
			
			//Create HUD Next button     
			_btnext = new ImaHUDButton(1, _bmpSheet, 1, 4, ImaSprite.POS_UPRI, 0,0, 8, 8); 
			_btnext.disable(); 
			_container.addChild(_btnext);      		
		
			//Create ad banner
			if(Registry.bAd){
				Registry.adMgr.initAds(onAdEvent, onAdIntEvent, onAdIntEndEvent);
				//_bAdIntClosed = false; //Interstitial not closed
			}
		
			
			super.create();                         
		} 

		
		// override this 
		override public function destroy():void 
		{                         
			trace("GameState->destroy()"); 

			if (_dlgEndLevelState != null) {
				_container.removeChild(_dlgEndLevelState);
				_dlgEndLevelState.destroy();
				_dlgEndLevelState = null;
			}
			
			_touching = null;
			//destroy HUD navigation buttos 
			_btmenu.destroy();
			_container.removeChild(_btmenu);
			_btmenu = null;
			_btnext.destroy();
			_container.removeChild(_btnext);
			_btnext = null;
				
			
			//Destroy ads
			if (Registry.bAd)
				Registry.adMgr.endAds(onAdEvent, onAdIntEvent, onAdIntEndEvent);
			
			_container.removeChild(_bkg);
			//Release and destroy signals 
			//TODO 
			
			super.destroy(); 
		} 
		
		//***************************************************** Getters/Setters 
		
		public function get puzzle():AbstractPuzzle {
			return _puzzle;
		}
		public function get box():AbstractBox {
			return _box;			
		}
		public function get phase():uint {
			return _idPhase;
		}
		public function get numLevels():uint {
			return _numLevels;
		}
  
		/**
		* Return the global level idx of the leve <idLvl> in the current phase 
		* @param	idLvl	-1 for the current id level, (0.._numlevels-1) for other level
		* @return	global idx: 0..N-1
		*/
		public function getGlobalLevel(idLvl:int = -1): uint { 
			if(idLvl == -1) 
				return (id+(_idPhase)*_numLevels); 
			else 
				return (idLvl+(_idPhase)*_numLevels); 
		} 		
		
	
		/**
		 * Get the rectangles around all the HUD icons/set of icons
		 * @return
		 */
		public function getHUDRects():Array {
			var aRect: Array = new Array();
			
			aRect.push(new Rectangle(8, 8, Assets.BUTTON_HUD_WIDTH, Assets.BUTTON_HUD_HEIGHT));
			aRect.push(new Rectangle(Registry.gameRect.width-8-_numLevels*Assets.BUTTON_HUD_WIDTH-(_numLevels-1)*4, 8, _numLevels*Assets.BUTTON_HUD_WIDTH+(_numLevels-1)*4, Assets.BUTTON_HUD_HEIGHT)); //TODO: a pelo, porque conozco la ubicación. Debería devolverlo ImaHudButton para independizarlo de ubicación
			//If Ad Banner is active define a new area wiht the ad height and complete screen width
			if (Registry.bAd)
			
				//aRect.push(new Rectangle(0, Registry.gameRect.height - Registry.adMgr.getSize().y, Registry.gameRect.width, Registry.adMgr.getSize().y));
				aRect.push(new Rectangle(0, Registry.gameRect.height-32 , Registry.gameRect.width, 32)); //ADMOB Option 3
			return aRect;
		}

		/**
		 * Get the maximum playable rectangle area, with or without HUD elements area
		 * @return
		 */
		public function getPlayableRect(noHUD:Boolean = false):Rectangle { 
			if(noHUD)
				return new Rectangle(0, 8 + Assets.BUTTON_HUD_HEIGHT, Registry.gameRect.width, Registry.gameRect.height - 8 - Assets.BUTTON_HUD_HEIGHT); 
			else {
				//We decided to manage the extra-space occupid by Ads in each of the classes that use getPlayableRect.
				//if(Registry.bAd) //remove ad banner space from the playable area
				//	return new Rectangle(0, 0, Registry.gameRect.width, Registry.gameRect.height-Registry.adMgr.getSize().y); 
				//else
					return new Rectangle(0, 0, Registry.gameRect.width, Registry.gameRect.height); 
			}
		} 

		
		//*************************************** Interactive actions 
		
		override protected function doMouseDown(e:MouseEvent):void {
			var spr: Piece = e.target as Piece; 
			if (spr != null && !spr.isSelected() &&  spr.isActive()) {
				_touching[0] = spr; 
				spr.doStartDrag(e);  
			}
			var spr2: AbstractPuzzle = e.target as AbstractPuzzle;
			if (spr2 != null) {
				spr2.doClick(e.localX,e.localY);
				//trace("Click en puzzle " + spr2.id + " pos: " + e.localX, "," + e.localY);
			}
			
		}

		override protected function doMouseUp(e:MouseEvent):void {
			if (_touching[0] != null) {
				(_touching[0] as Piece).doStopDrag(e);
				_touching[0] = null;
			}
		}
		
		override protected function doTouchBegin(e:TouchEvent):void { 

			var spr: Piece = e.target as Piece; 
			if (spr != null && !spr.isSelected() &&  spr.isActive()) {
				_touching[e.touchPointID] = spr;  
				spr.doTouchBegin(e);  
			}
			var spr2: AbstractPuzzle = e.target as AbstractPuzzle;
			if (spr2 != null) {
				spr2.doClick(e.localX,e.localY);
				//trace("Click en puzzle " + spr2.id + " pos: " + e.localX, "," + e.localY);
			}
		}
		
		override protected function doTouchEnd(e:TouchEvent):void {
			var spr: Piece = _touching[e.touchPointID]; 			
			if (spr != null) {
				//TODO asegurar que _touching[e.touchPointID] == spr (debería, pero vamos..¨)
				delete _touching[e.touchPointID];
				_touching[e.touchPointID] = null;
				spr.doTouchEnd(e);
			}			
		}
		
		override public function backState():void 
		{ 
			Assets.playSound("BtHud");
			goLevel( -1); 
		}
		
		//---------------------------------------------------------  Signal button callbacks 
					
	
		/**
		 * Click Callback on EndLevelDialog
		 * @param	idBt	Button id in the dialog 0:Menu, 1:Repeat, 2: Menu 
		 */
		protected function onDlgEndLevelClick(idBt: uint):void { 
			//Continue to the next level of the current Number of return to the menu if it is the last level
			if(idBt == 2) { //"NEXT" Button
				if (id < _numLevels - 1) {
					goLevel(id + 1); //switch to a new level state, the next to the current level, 
				} 
				else {
					//goLevel( -1); //or the menu if we are in the last level in phase  
					if (Registry.bAd) {
						Registry.adMgr.showInterstitial();  //el CB de fin de interstitial llamará a función que ejecutará goLevel(-1)
						_sts = STS_END;
						_sts = SBSTS_CONT;	
					}
					else
						goLevel(-1); 
				}
			}
			//Completed the round
			else if (idBt == 0) { //"MENU" Button after finishing the last level of the round
				//goLevel( -1);
				if (Registry.bAd) {
					Registry.adMgr.showInterstitial();  //el CB de fin de interstitial llamará a función que ejecutará goLevel(-1)
					_sts = STS_END;
					_sts = SBSTS_CONT;	
				}
				else
					goLevel(-1); 
			}				
		} 
		
												
		private function onMenuClick(event:MouseEvent):void { 
			Assets.playSound("BtHud");
			//_bAdIntClosed = false;
			if (Registry.bAd) {
				Registry.adMgr.hideBanner(); //oculta banner para no solapar banner sobre interstitial	 //Cambio ANE:admob 6.12.2								
				Registry.adMgr.showInterstitial();  //el CB de fin de interstitial llamará a función que ejecutará goLevel(-1)
				//Cambio ANE:admob 6.12.2
				//_sts = STS_END;	
				//_sts = SBSTS_CONT;	
				goLevel(-1); //Cambio ANE:admob 6.12.2
			}
			else
				goLevel(-1); 
		} 
		
		protected function onNextClick(event:MouseEvent):void { 
			Assets.playSound("BtHud"); 
			goLevel(_id+1);                       
		} 

		/**
		 * Switch to a new level state indicated by the relative level idLvl 
		 * @param	idLvl	(-1:menu, 0..2: levels in phase) 
		 */
		protected function goLevel(idLvl: int):void { 
			if(idLvl == -1) 
				Registry.game.switchState(new MenuState(0)); 
			else { 
				var idGlobalLvl:int = getGlobalLevel(idLvl); //bt: [1.._idPhase*_numLevels] id sequence of the button within all phases                                   
	//[TEST]
	//idGlobalLvl = 35; idLvl = 1; _idPhase = 0; _numLevels = 1;		
				var classReference:Class = getDefinitionByName(getQualifiedClassName(Assets.gameStates[idGlobalLvl])) as Class; 
				Registry.game.switchState(new classReference(idLvl, _idPhase, _numLevels)); 
			} 
		} 
		
		       
		private function onDrawComplete():void { 
			_btmenu.enable(onNextClick); 
		}
		
		protected function createEndDialog():Boolean { 
			//Create ImaDialog with starts win 
			_dlgEndLevelState = new EndLevelDialog(id, _idPhase, this); 
			_container.addChild(_dlgEndLevelState); 
			_dlgEndLevelState.signalClick.add(onDlgEndLevelClick); 
			_dlgEndLevelState.show(1.2); //0.8 
			return true;                 
		} 
						
		override public function update():void 
		{ 
			//super.update(); 
			
			//Control to move from STS_INIT to STS_PLAY
			if(_sts == STS_INIT) {
				if (_sbsts != SBSTS_END) { //_sbsts == SBSTS_CONT){ //&& la condicion de fin de init se cumple
					_sts = STS_PLAY;
					_sbsts = SBSTS_INIT;
			/*		
					if (Registry.bAd) {//check if condition to start imaSprite init states has been met: condition, interstitial removed
						if (_bAdIntClosed) {
							_sts = STS_PLAY;
							_sbsts = SBSTS_INIT;
							//_sbsts = SBSTS_END;
						}
					}else {
						_sts = STS_PLAY;
						_sbsts = SBSTS_INIT;					
						//_sbsts = SBSTS_END;
					}
					*/
				}

			}
			//Chk if final condition is just met and show reward dialog
			else if (_sts == STS_END) { 
				if (_sbsts == SBSTS_INIT) { 
					if (_dlgEndLevelState == null){ 
						
						//Create ImaDialog with starts win 
						if (createEndDialog()) { 
							//Hide ad banner
							if (Registry.bAd)
								Registry.adMgr.hideBanner();
									
							//disable HUD buttons in state
							_btmenu.disable();
							_btnext.disable();
						}

					}
					else {	
						_dlgEndLevelState.update();
					}
				}
				/*else if (_sbsts == SBSTS_CONT) {
					if (_bAdIntClosed)
						goLevel( -1);
					//_sbsts = SBSTS_END;
				}*/
			}      
			//Tratamiento STS_PLAY
			else { 
				//Important: keep this order. Puzzle has to be init() before box() (signals dependencies)
				_puzzle.update();
				_box.update(); 
			}         
		
		} 
		

		override public function pauseState():void {
			super.pauseState(); 	// _sts = STS_PAUSE;
		}
		

		override public function resumeState():void {
			//Sacar ventana si no se está en dialogo?? es decir si se está en juego
			super.resumeState();	// _sts = STS_PLAY;
		}
			
		//----------------------------------------------- Ad support callbacks
		
		private function onAdEvent(event:AdmobEvent):void
		{		
			/*
			//var adsize:AdSize = Registry.adMgr.admob.getAdSize();
			var adsize:Point = Registry.adMgr.getSize();

			//var x:uint = (uint)((Registry.gameRect.width - adsize.x) * 0.5);  	//[iOS]
			//Registry.adMgr.admob.addToStage(0,x);	//Y,X: bottom-left corner = 0,0 //[iOS]
	
			//var x:uint = (uint)((Registry.deviceRect.width - adsize.x * Registry.appScale) * 0.5);
			var x:uint = (uint)((Registry.deviceRect.width - 320 * Registry.appScale) * 0.5);
			//var y:uint = (uint)(Registry.deviceRect.height - adsize.y*Registry.appScale - 4);
			var y:uint = (uint)(Registry.deviceRect.height - 50 * Registry.appScale);
			
			Registry.adMgr.showBanner(x, y); 
			*/
			
			//Option 3
			//Registry.adMgr.showBanner();
			//e.data:String = Banner unique ID
			
		}
		
		private function onAdIntEvent(event:AdmobEvent):void
		{		
			//Option 3
			//Registry.adMgr.showInterstitial();			
		}
		
		/**
		 * Callback for INTERSTITIAL_LEFT_APPLICATION Admob Event 
		 * The Interstitial has been remove from the application (especially useful for listen when the user close the Interstitial)
		 * @param	event
		 */
		private function onAdIntEndEvent(event:AdmobEvent):void
		{		
			//Option 3
			goLevel( -1);
			//_bAdIntClosed = true; //Permite Cambiar de substeado init a subestado end;
			//Registry.adMgr.hideInterstitial();
		}
		
		
		//----------------------------------------------- Debugging support
		public function dbgInit():void {
			_dbgGfx.clear();
		}
		public function dbgDrawRect(x:uint, y: uint, w: uint, h: uint):void {			
			_dbgGfx.moveTo(x, y);
			_dbgGfx.lineStyle(1,0xFF0000,0.5); 
            _dbgGfx.lineTo(x + w, y);
			_dbgGfx.lineTo(x + w, y + h);
			_dbgGfx.lineTo(x, y + h);
			_dbgGfx.lineTo(x, y);			
		}
	} 



}