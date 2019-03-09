package com.imagame.engine 
{
	import flash.events.EventDispatcher;
	import flash.geom.Point;

	//Ane Extension Imports (ADMOB option 0: admob_android.ane)
	/*
	import so.cuo.anes.admob.Admob;	
	import so.cuo.anes.admob.AdSize;
	import so.cuo.anes.admob.AdEvent;
	*/
	
	// Ane Extension Imports (ADMOB option 1: AdMob for Flash)
	import so.cuo.platform.admob.Admob;
	import so.cuo.platform.admob.AdmobSize;	
	import so.cuo.platform.admob.AdmobPosition;
	import so.cuo.platform.admob.AdmobEvent;
	
	// Ane Extension Imports (ADMOB option 3: AdMobANE)
	/*
	import com.codealchemy.ane.admobane.AdMobManager;
	import com.codealchemy.ane.admobane.AdMobPosition;
	import com.codealchemy.ane.admobane.AdMobSize;
	import com.codealchemy.ane.admobane.AdMobEvent;
	*/
	
	/**
	 * Advertisement Manager
	 * @author imagame
	 */
	public class ImaAdManager 
	{
		public var bAdProvider: Boolean = false;	//if AdProvider is supported
		//public var admob:Admob;	//Option-0
		public var admob: Admob;	//Option-1
		//public var admob:AdMobManager; //Option-3
		 
		
		private var id:String;
		private var id_ban:String;	
		private var id_int:String;	
		private var bVisible: Boolean;
		
		public function ImaAdManager() 			
		{						
			//AdMob id
			//id = "a1517f033bb0ea5"; //IOS Admon Id
			//id = "a151f1ae2e40e53"; //ANDROID NT Admob Id	
			//id = "a153ccd28d15e50" //ANDROID VT Admob Id	
			//id_ban = "ca-app-pub-3497215250736989/8915250129";	//id del bloque de anuncios banner VT-Android
			//id_int = "ca-app-pub-3497215250736989/3309368526";  //id del bloque de anuncios intersticial VT-Android
			id_ban = "ca-app-pub-3497215250736989/9744982928";	//id del bloque de anuncios banner VT-iOS
			id_int = "ca-app-pub-3497215250736989/2221716128";  //id del bloque de anuncios intersticial VT-iOS			

			//admob = Admob.getInstance();	//Option-0
			admob = Admob.getInstance();	//Option-1
			//admob = AdMobManager.manager; //Option-3
			
			//if (admob.isSupported) { Option-0, Option-3
			if (admob.supportDevice) { //Option-1
				trace("AdMob supported!!");
				bAdProvider = true;
				bVisible = false;
				
				//option 1
				admob.setKeys(id_ban, id_int);
				admob.enableTrace = false;
				
				//option 3
				/*
				admob.verbose = true;
				admob.operationMode = AdMobManager.TEST_MODE;
				admob.bannersAdMobId = id_ban;
				admob.interstitialAdMobId = id_int;
				*/
			}
		}
		
		public function initAds(funcBanCB: Function, funcIntCB: Function, funcIntEndCB: Function):void {
			/* Option 0
			if (bAdProvider) 
			{
				admob.dispatcher.addEventListener(AdEvent.onReceiveAd, funcCB);
				admob.setIsLandscape(true);
				admob.createADView(AdSize.BANNER, id); 
				admob.addToStage(0, 0); // ad to displaylist position 0,0
				//showBanner(0, 0);
				
				admob.load(false); // send a ad request.  //[CONFIG] true= testing
			}			
			*/
			
			//Option-1
			if (bAdProvider) {
				admob.addEventListener(AdmobEvent.onBannerReceive, funcBanCB);
				admob.addEventListener(AdmobEvent.onInterstitialReceive, funcIntCB);	
				admob.addEventListener(AdmobEvent.onInterstitialLeaveApplication, funcIntEndCB);
				admob.addEventListener(AdmobEvent.onInterstitialDismiss, funcIntEndCB); //Se llama al cerrar el interstitial

				admob.cacheInterstitial();
				if (admob.getScreenSize().width >= 1200)
				//if(Registry.gameRect.width >= 1200)
					admob.showBanner( Admob.IAB_BANNER, AdmobPosition.BOTTOM_CENTER); 
				else
					admob.showBanner( Admob.BANNER, AdmobPosition.BOTTOM_CENTER); //Banner para Pantalla 800x600
				
				
			}
			
			//Option 3
			/*
			if (bAdProvider) {
				//admob.createBanner(AdMobSize.BANNER, AdMobPosition.BOTTOM_CENTER); // , id_int, null, true);
				//admob.createBanner(AdMobSize.SMART_BANNER, AdMobPosition.BOTTOM_CENTER); //Ancho pantalla
				admob.createBanner(AdMobSize.FULL_BANNER, AdMobPosition.BOTTOM_CENTER, null,id_ban, false); //Ancho pantalla
				//admob.createInterstitial(id_int, false);
				admob.cacheInterstitial();

				if (!dispatcher.hasEventListener(AdMobEvent.BANNER_LOADED))
					dispatcher.addEventListener(AdMobEvent.BANNER_LOADED, funcBanCB);
				if (!dispatcher.hasEventListener(AdMobEvent.INTERSTITIAL_LOADED))
					dispatcher.addEventListener(AdMobEvent.INTERSTITIAL_LOADED, funcIntCB);
				if (!dispatcher.hasEventListener(AdMobEvent.INTERSTITIAL_LEFT_APPLICATION)) //Se llama cuando un usuario está a punto de volver a la aplicación después de hacer clic en un anuncio
					dispatcher.addEventListener(AdMobEvent.INTERSTITIAL_LEFT_APPLICATION, funcIntEndCB);
					if (!dispatcher.hasEventListener(AdMobEvent.INTERSTITIAL_AD_CLOSED)) //Se llama cuando un usuario está a punto de volver a la aplicación después de hacer clic en un anuncio.
					dispatcher.addEventListener(AdMobEvent.INTERSTITIAL_AD_CLOSED, funcIntEndCB);
			}
			*/
		}
		
		public function endAds(funcBanCB: Function, funcIntCB: Function, funcIntEndCB: Function):void {
			/* Option 0
			if (bAdProvider) 
			{
				if(bVisible){ 
					admob.dispatcher.removeEventListener(AdEvent.onReceiveAd, funcCB); //Casca si ya he realizado el removeFromStage
					admob.removeFromStage();
				}
				admob.destroyADView();				
			}
			*/
			//Option-1
			if (bAdProvider) 
			{
				admob.hideBanner();
				if (admob.hasEventListener(AdmobEvent.onBannerReceive))
					admob.removeEventListener(AdmobEvent.onBannerReceive, funcBanCB);
				if (admob.hasEventListener(AdmobEvent.onInterstitialReceive))
					admob.removeEventListener(AdmobEvent.onInterstitialReceive, funcIntCB);
				if (admob.hasEventListener(AdmobEvent.onInterstitialLeaveApplication))
					admob.removeEventListener(AdmobEvent.onInterstitialLeaveApplication, funcIntEndCB);	
				if (admob.hasEventListener(AdmobEvent.onInterstitialDismiss))
					admob.removeEventListener(AdmobEvent.onInterstitialDismiss, funcIntEndCB);	
			}
			
			//Option 3
			/*
			if (bAdProvider) 
			{
				admob.removeInterstitial();
			
				admob.hideAllBanner();
				if (dispatcher.hasEventListener(AdMobEvent.BANNER_LOADED))
					dispatcher.removeEventListener(AdMobEvent.BANNER_LOADED, funcBanCB);
				if (dispatcher.hasEventListener(AdMobEvent.INTERSTITIAL_LOADED))
					dispatcher.removeEventListener(AdMobEvent.INTERSTITIAL_LOADED, funcIntCB);
				if (dispatcher.hasEventListener(AdMobEvent.INTERSTITIAL_LEFT_APPLICATION))
					dispatcher.removeEventListener(AdMobEvent.INTERSTITIAL_LEFT_APPLICATION, funcIntEndCB);
				if (dispatcher.hasEventListener(AdMobEvent.INTERSTITIAL_AD_CLOSED))
					dispatcher.removeEventListener(AdMobEvent.INTERSTITIAL_AD_CLOSED, funcIntEndCB);
			}
			*/
		}

		
		/* Option 0
		public function getSize():Point {
			return new Point((uint) (admob.getAdSize().width), (uint) (admob.getAdSize().height));
		}
		
		public function getScrSize():Point {
			return new Point((uint) (admob.getScreenSize().width), (uint) (admob.getScreenSize().height));
		}
		
		public function showBanner(x:uint, y:uint):void {
			//admob.addToStage(y, x); //Important: x,y interchanged pos //[iOS]
			admob.addToStage(x, y); //Important: x,y interchanged pos
			
			bVisible = true;
		}
		
		public function hideBanner():void {
			admob.removeFromStage();
			bVisible = false;
		}
		*/
		
		
		//Option-1
		public function showBanner():void {
			var adsize:AdmobSize;
			//toDo: Select adsize dependint on screen size (admob.getScreenSize())
            adsize = Admob.BANNER;
			//admob.showBanner(adsize, AdmobPosition.BOTTOM_CENTER);
			bVisible = true;
		}
		public function hideBanner():void {
			admob.hideBanner();	
			bVisible = false;
		}
		public function showInterstitial():void {
			if(admob.isInterstitialReady()){
				admob.showInterstitial();
			}else{
				admob.cacheInterstitial();
			}			
		}
		public function hideInterstitial():void {
			
		}
		
		//Option-3
		/*
		public function showBanner():void {
			admob.showAllBanner();	
			//admob.showBanner(id_ban);
			bVisible = true;
		}
		public function hideBanner():void {
			admob.hideAllBanner();
			bVisible = false;
		}
		
		public function showInterstitial():void {
			if (admob.isInterstitialLoaded()) {
				admob.showInterstitial();
			} else {
				admob.cacheInterstitial();
			}			
		}		
		public function hideInterstitial():void {
			admob.removeInterstitial();
		}
		public function get dispatcher():EventDispatcher
		{
			// Return the extension dispatcher
			return AdMobManager.manager.dispatcher;
			//return admob.dispatcher;
		}

		*/
	}

}