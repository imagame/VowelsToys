package com.imagame.game 
{
	import com.imagame.engine.ImaBackground;
	import com.imagame.engine.ImaDialog;
	import com.imagame.engine.ImaPanel;
	import com.imagame.engine.ImaState;
	import com.imagame.engine.Registry;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author imagame
	 */
	public class MenuState extends ImaState 
	{
		protected var _arraypanel: Array = new Array(); 
		protected var _currentPanel: int;	//0..NUM_PANELS		
		protected var _dlgConfig: ImaDialog;
		protected var _dlgParentalGate: ImaDialog;

		public function MenuState(id:uint) 
		{
			super(id);
			trace("MENUSTATE >> MenuState()");
		}
		
		override public function create():void {
			trace("MenuState->create()");
			
			//Paint background
			_bkg = new ImaBackground(0,1,2); 
			_container.addChild(_bkg);

			//Panels creation
			//Panel 0: Main
			var panel:ImaPanel;
			panel = new PanelMenuMain(0);
			(panel as PanelMenuMain).signalUcVowels.add(onUcVowelsButton); 
			(panel as PanelMenuMain).signalLcVowels.add(onLcVowelsButton); 
			(panel as PanelMenuMain).signalconfig.add(onConfigButton);
			(panel as PanelMenuMain).signalstore.add(onStoreButton);
			_arraypanel.push(panel);
			
			//Panel 1: Menu Uppercase vowels  (Levels sel,A,E,I,O,U)
			panel = new PanelMenuFase1(1);
			panel.signalback.add(onBackButton); 
			_arraypanel.push(panel);
			(panel as PanelMenuFase1).signal.add(onUcVowelsLevel);
			
			//Panel 2: Menu Lowercase vowels (Levels sel,a,e,i,o,u)
			panel = new PanelMenuFase2(2);
			panel.signalback.add(onBackButton); 
			_arraypanel.push(panel);
			(panel as PanelMenuFase2).signal.add(onLcVowelsLevel);

			//Panels activation
			for each (var i:ImaPanel in _arraypanel){
				_container.addChild(i);
				i.visible = false;
			}			
			_currentPanel = -1; 
			switchPanel(0);			
			
			super.create(); 
			//_sbsts = SBSTS_END;//activa el estado Play			
		}
		
		/**
		 * Destroy de objects created in create() and other methods
		 */
		override public function destroy():void {
			trace("MenuState->destroy()");
			
			//Dispose background 
			_container.removeChild(_bkg);
			//Dispose panels
			for (var i:int = 0; i < _arraypanel.length; i++) {
				_arraypanel[i].destroy();
				_container.removeChild(_arraypanel[i]);	
				_arraypanel[i] = null;
			}
			_arraypanel = null;
					
			super.destroy();
		}

			
		public function switchPanel(panel: int):void {
			if (_currentPanel >= 0) {
				_arraypanel[_currentPanel].exit();
				_arraypanel[_currentPanel].visible = false;
			}
			_currentPanel = panel;
			_arraypanel[_currentPanel].visible = true;
			_arraypanel[_currentPanel].init(); 
		}
		
		override public function backState():void 
		{ 
			if (_currentPanel == 0)
				Registry.game.exitGame();
			else
				switchPanel(0);		
		}		
		
		private function onUcVowelsButton():void {
			Assets.playSound("BtGroupLevel");
			switchPanel(1);
		}
		
		private function onLcVowelsButton():void {
			Assets.playSound("BtGroupLevel");
			switchPanel(2);
		}

		private function onBackButton():void {
			switchPanel(0);
		}

		private function onConfigButton():void {
			Assets.playSound("BtHud");
			
			//Create ImaDialog with starts win 
			_dlgConfig = new ConfigDialog(id, this);
			_container.addChild(_dlgConfig);
			_dlgConfig.signalClick.add(onDlgConfigClick); 
			_dlgConfig.show();
			
			
			//Disable rest of buttons in screen
			_arraypanel[_currentPanel].enable(false);

		}		
		
		private function onStoreButton():void {
		//iOS
			//Requires Parental Gate
			//navigateToURL(new URLRequest("http://itunes.apple.com/app/id676863974"));
			//navigateToURL(new URLRequest("itms-apps://itunes.apple.com/app/id676863974"));	//iOS
			Assets.playSound("BtHud");
			
			//Create Parental Gate Dialog
			_dlgParentalGate = new ParentalGateDialog(id, this);
			_container.addChild(_dlgParentalGate);
			_dlgParentalGate.signalClick.add(onDlgParentalGateClick); 
			_dlgParentalGate.show();
			//Disable rest of buttons in screen
			_arraypanel[_currentPanel].enable(false);
			
		/*	
			//Android
			navigateToURL(new URLRequest("market://details?id=air.com.imagame.numberstoys"));	//Android
		*/
		}
		
		
		/**
		 * PanelMenuFase1 click signal callback 
		 * @param	idBt	Button identificator clicked in PanelMenuFase1 [0..6*5-1]
		 */
		private function onUcVowelsLevel(idBt: uint):void {		
			//Assets.playSound("NoA");
			var idVowel: uint = idBt / 6; //0: A, 1: E, 2:I, 3:O, 4:U 
			var idLvl: uint = idBt % 6; //0: bodypart select, 1..5: puzzle difficulty level
			if (idLvl == 0)
				Registry.game.switchState(new GameLevel1(idLvl, idVowel, Assets.GAM_NUM_LEVELS+1));   //level, vowel, numlevels+selectBodyParts 
			else
				Registry.game.switchState(new GameLevel2(idLvl, idVowel, Assets.GAM_NUM_LEVELS+1));   //level, vowel, numlevels+selectBodyParts 
		}
		
		/**
		 * PanelMenuFase1 click signal callback
		 * @param	idBt	Button identificator clicked in PanelMenuFase2 [0..6*5-1]
		 */
		private function onLcVowelsLevel(idBt: uint):void {		
			//Assets.playSound("NoA");
			var idVowel: uint = (idBt / 6)+ 5; //5: a, 6: e, 7:i, 8:o, 9:u 
			var idLvl: uint = idBt % 6; //0: bodypart select, 1..5: puzzle difficulty level 
			if (idLvl == 0) 
				Registry.game.switchState(new GameLevel1(idLvl, idVowel, Assets.GAM_NUM_LEVELS+1));   //level, vowel, numlevels+selectBodyParts 
			else 
				Registry.game.switchState(new GameLevel3(idLvl, idVowel, Assets.GAM_NUM_LEVELS+1));   //idphase param: 5..9 
		}

		
		/**
		 * Click Callback on EndLevelDialog
		 * @param	idBt	Button id in the dialog 0:Menu, 1:Repeat, 2: Menu 
		 */
		private function onDlgConfigClick(idBt: uint):void { 
			//Continue to the next level of the current Number of return to the menu if it is the last level
			if (idBt == 2) { //"NEXT" Button			
				
				//TODO: consequences in MenuState (if any)
				for (var i:int = 0; i < _arraypanel.length; i++) 
					//_arraypanel[i].update() //update panels (eg hud progress bar in main panel)
					_arraypanel[i].init(); //disable all the levels
				_arraypanel[_currentPanel].enable();
				
				//Enable buttons 
				_container.removeChild(_dlgConfig);
				_dlgConfig.destroy();
				_dlgConfig = null;
			}		
		} 
		
		
		/**
		 * Click Callback on ParentalGateDialog
		 * @param	idBt	Button id in the dialog 0:Menu, 2: Next 
		 */
		private function onDlgParentalGateClick(idBt: uint):void { 
			
			//Enable buttons and destroy dialog 
			_arraypanel[_currentPanel].enable();
			_container.removeChild(_dlgParentalGate);
			_dlgParentalGate.destroy();
			_dlgParentalGate = null;
			
			//Navigate to store if the dialog has been left with the correct answer
			if (idBt == 2) { //"NEXT" Button			
				//navigateToURL(new URLRequest("http://itunes.apple.com/app/id676863974"));	//PC
				navigateToURL(new URLRequest("itms-apps://itunes.apple.com/app/id676863974"));	//iOS				
			}		
		} 
		
		//-------------------------------------------------------- Touch handles 
		
		override protected function doTouchBegin(e:TouchEvent):void { 
			if (_dlgConfig != null)
				_dlgConfig.doTouchBegin(e);
			else if (_dlgParentalGate != null)
				_dlgParentalGate.doTouchBegin(e);		
			else
				_arraypanel[_currentPanel].doTouchBegin(e); 
		} 
        
		override protected function doTouchEnd(e:TouchEvent):void { 
			if (_dlgConfig != null)
				_dlgConfig.doTouchEnd(e);
			else if (_dlgParentalGate != null)
				_dlgParentalGate.doTouchEnd(e);				
			else
				_arraypanel[_currentPanel].doTouchEnd(e);
		}  
		
		override protected function doMouseDown(e:MouseEvent):void {
			if (_dlgConfig != null)
				_dlgConfig.doMouseDown(e);
			else if (_dlgParentalGate != null)
				_dlgParentalGate.doMouseDown(e);
			else
				_arraypanel[_currentPanel].doMouseDown(e); 			
		}

		override protected function doMouseUp(e:MouseEvent):void {
			if (_dlgConfig != null)
				_dlgConfig.doMouseUp(e);
			else if (_dlgParentalGate != null)
				_dlgParentalGate.doMouseUp(e);
			else
				_arraypanel[_currentPanel].doMouseUp(e); 			
		}


		
		//--------------------------------------------------------- State logic
		
				
		override public function update():void {
			super.update(); 
			
			if(_sts == STS_INIT) {
				if (_sbsts == SBSTS_CONT) //&& la condicion de fin de init se cumple
					_sbsts = SBSTS_END;
			}
			else {				
				if (_dlgConfig != null)
					_dlgConfig.update();
				if (_dlgParentalGate != null) {
					_dlgParentalGate.update();
				}
				(_arraypanel[_currentPanel] as ImaPanel).update();
			}
		}
	}

}