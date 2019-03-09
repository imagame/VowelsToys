package com.imagame.game 
{
	import com.imagame.engine.Registry;
	import flash.display.Bitmap;
	import flash.media.Sound; 
    import flash.utils.Dictionary; 
	
	/**
	 * ...
	 * @author imagame
	 */
	public class Assets 
	{
		private static var sSounds:Dictionary = new Dictionary(); 

		// sounds         
		[Embed(source = "../../../../assets/sfx/btHud.mp3")]  private static const sndBtHud:Class;
		[Embed(source = "../../../../assets/sfx/btGroupLevel.mp3")]  private static const sndBtGroupLevel:Class;
		[Embed(source = "../../../../assets/sfx/btVowel.mp3")]  private static const sndBtVowel:Class;
		[Embed(source = "../../../../assets/sfx/btLevel.mp3")]  private static const sndBtLevel:Class;
		[Embed(source = "../../../../assets/sfx/tobj_rnd.mp3")]  private static const sndTObjRnd:Class;
		[Embed(source = "../../../../assets/sfx/piece1_sel.mp3")]  private static const sndPiece1sel:Class;
		[Embed(source = "../../../../assets/sfx/piece1_ok.mp3")]  private static const sndPiece1ok:Class;
		[Embed(source = "../../../../assets/sfx/piece1_ko.mp3")]  private static const sndPiece1ko:Class;
		[Embed(source = "../../../../assets/sfx/piece2_sel.mp3")]  private static const sndPiece2sel:Class;
		[Embed(source = "../../../../assets/sfx/piece2_ok.mp3")]  private static const sndPiece2ok:Class;
		[Embed(source = "../../../../assets/sfx/piece2_ko.mp3")]  private static const sndPiece2ko:Class;
		[Embed(source = "../../../../assets/sfx/piece3_sel.mp3")]  private static const sndPiece3sel:Class;
		[Embed(source = "../../../../assets/sfx/piece3_ok.mp3")]  private static const sndPiece3ok:Class;
		[Embed(source = "../../../../assets/sfx/piece3_ko.mp3")]  private static const sndPiece3ko:Class;
		[Embed(source = "../../../../assets/sfx/end_level.mp3")]  private static const sndEndLevel:Class
		//TODO: Add sounds
        
		
		//Dialogs		
		[Embed(source = "../../../../assets/gfx/dlg0.png")] public static var GfxDlg0: Class; 	//320x256
		[Embed(source = "../../../../assets/gfx/fx_frmico_dlg.png")] public static var GfxFxFrmIconDlg:Class;	//fx
		[Embed(source = "../../../../assets/gfx/dlgConfig.png")] public static var GfxDlgConfig: Class; 
		[Embed(source = "../../../../assets/gfx/dlgParentalGate.png")] public static var GfxDlgParentalGate: Class; 
		[Embed(source = "../../../../assets/gfx/dlgMenuFase1.png")] public static var GfxDlgMenuPhase1: Class; 
		[Embed(source = "../../../../assets/gfx/dlgMenuFase2.png")] public static var GfxDlgMenuPhase2: Class; 
		
		//Background images
		[Embed(source = "../../../../assets/gfx/bkg480x320_main.png")] public static var GfxBkgImg0: Class;
		[Embed(source = "../../../../assets/gfx/bkg480x320_mainexth.jpg")] public static var GfxBkgImg1: Class;
		[Embed(source = "../../../../assets/gfx/bkg480x320_mainextv.jpg")] public static var GfxBkgImg2: Class;
		[Embed(source = "../../../../assets/gfx/bkg480x320_1.jpg")] public static var GfxBkgImg3: Class;	//1-Amarillo-verdoso(estrellas)	
		[Embed(source = "../../../../assets/gfx/bkg480x320_2.jpg")] public static var GfxBkgImg4: Class;	//2-Rosado (Mantel) //Gris Rosado (figuras)
		[Embed(source = "../../../../assets/gfx/bkg480x320_3.jpg")] public static var GfxBkgImg5: Class;	//3-Verde Metal (cajas) 
		[Embed(source = "../../../../assets/gfx/bkg480x320_4.jpg")] public static var GfxBkgImg6: Class;	//4-gris (baldositas) //4-Azul (círculos lentes) 
		[Embed(source = "../../../../assets/gfx/bkg480x320_5.jpg")] public static var GfxBkgImg7: Class;	//5-naranja (pildoras) 
		[Embed(source = "../../../../assets/gfx/bkg480x320_6.jpg")] public static var GfxBkgImg8: Class;	//6-granate-rosa (bolitas)
		[Embed(source = "../../../../assets/gfx/bkg480x320_7.jpg")] public static var GfxBkgImg9: Class;	//7-marron clarito (tablas) //amarillo (abanicos) //naranja (rombos pequeños) 
		[Embed(source = "../../../../assets/gfx/bkg480x320_8.jpg")] public static var GfxBkgImg10: Class;	//8-azul (franjas diagonal) 
		[Embed(source = "../../../../assets/gfx/bkg480x320_9.jpg")] public static var GfxBkgImg11: Class;	//9-azul (cristalera) //gris (jap flag) 
		[Embed(source = "../../../../assets/gfx/bkg480x320_10.jpg")] public static var GfxBkgImg12: Class;	//10-verde-blanco (cuadrados circulares diagon) //gris (jap flag) 
		//extensions
		[Embed(source = "../../../../assets/gfx/bkg480x320_8exth.jpg")] public static var GfxBkgImg13: Class;	//8extH-azul (franjas diagonal) 	
		[Embed(source = "../../../../assets/gfx/bkg480x320_8extv.jpg")] public static var GfxBkgImg14: Class;	//8extV-azul (franjas diagonal) 	
		[Embed(source = "../../../../assets/gfx/bkg480x320_9exth.jpg")] public static var GfxBkgImg15: Class;	//8extH-azul (franjas diagonal) 	
		[Embed(source = "../../../../assets/gfx/bkg480x320_9extv.jpg")] public static var GfxBkgImg16: Class;	//8extV-azul (franjas diagonal) 	
		[Embed(source = "../../../../assets/gfx/bkg480x320_10exth.jpg")] public static var GfxBkgImg17: Class;	//8extH-azul (franjas diagonal) 	
		[Embed(source = "../../../../assets/gfx/bkg480x320_10extv.jpg")] public static var GfxBkgImg18: Class;	//8extV-azul (franjas diagonal) 	
		
 		public static var bkgImages: Array = [GfxBkgImg0, GfxBkgImg1, GfxBkgImg2, GfxBkgImg3, GfxBkgImg4, 
												GfxBkgImg5, GfxBkgImg6, GfxBkgImg7, GfxBkgImg8, GfxBkgImg9, 
												GfxBkgImg10, GfxBkgImg11, GfxBkgImg12, GfxBkgImg13, GfxBkgImg14,
												GfxBkgImg15, GfxBkgImg16, GfxBkgImg17, GfxBkgImg18];		//this definition must be after embedded classes

		//Text and titles
		[Embed(source = "../../../../assets/gfx/logoimagame.png")] public static var GfxLogo: Class; //176x24
		[Embed(source = "../../../../assets/gfx/title.png")] public static var GfxTitle: Class;	//352x96
		[Embed(source = "../../../../assets/gfx/titFase.png")] public static var GfxTitFase: Class; //200x56
		
		//Menu images
		//TODO		
		static public const NUMTOBJ: uint = 5; 
		static public const NUMBODYPART: uint = 5; 
		
		[Embed(source = "../../../../assets/gfx/ts_icoBoxOut.png")]  public static var GfxBoxOutImg: Class;
		public static const IMG_ICO_BOXOUT_WIDTH:uint = 112;
		//public static const IMG_ICO_BOXOUT_HEIGHT: uint = 272;
		public static const IMG_ICO_BOXOUT_HEIGHT: uint = 280;
		//Tilesheet Buttons GameLevel1
		[Embed(source = "../../../../assets/gfx/ts_btTObj.png")] public static var GfxBtnTObjImg: Class; //4state ObjectTypes
		public static const IMG_BTN_TOBJ_WIDTH:uint = 80;
		public static const IMG_BTN_TOBJ_HEIGHT: uint = 40;
		[Embed(source = "../../../../assets/gfx/ts_btBodyPart.png")] public static var GfxIconBodyPart: Class; //Void+disabled+enabled inBox piece
		public static const IMG_ICON_BODYPART_WIDTH:uint = 96;
		public static const IMG_ICON_BODYPART_HEIGHT: uint = 48;
		[Embed(source = "../../../../assets/gfx/ts_btObj.png")] public static var GfxPieceBodyPart: Class;  //InPuzzle body parts (size function on TObj)
		//public static var IMG_GFX_BODYPART_WIDTH: Array = 	[96, 96, 128, 240, 240]; //bodypart width for each Object type (NUMTOBJ items).
		//public static var IMG_GFX_BODYPART_HEIGHT: Array = 	[40, 40,  48,  52, 60];
		public static var IMG_GFX_BODYPART_WIDTH: Array = 	[96, 96, 128, 240, 240]; //bodypart width for each Object type (NUMTOBJ items).
		public static var IMG_GFX_BODYPART_HEIGHT: Array = 	[40, 40,  80,  80, 96];	
		public static var IMG_GFX_BODYPART_POSY: Array = [ 	
													28, 60, 120, 148, 212, //Vowel A, bodypart-y type 0, type 1, type 2, type 3, type 4 
													28, 60, 120, 148, 212, //Vowel E 
													28, 60, 120, 148, 212, //Vowel I 
													28, 60, 120, 148, 212, //Vowel O 
													28, 60, 120, 148, 212, //Vowel U 
													28, 60, 120, 148, 212, //Vowel a 
													28, 60, 120, 148, 212, //Vowel e 
													28, 60, 120, 148, 212, //Vowel i 
													28, 60, 120, 148, 212, //Vowel o 
													28, 60, 120, 148, 212];//Vowel u 
		
													
		
		//mouth: 104x80
		//hand: 240x72
		//feet: 240x96  (left leg-x: 80, right leg-x: 176) leg-y: 208
													
		//Tilesheet Vowels images
		[Embed(source = "../../../../assets/gfx/vowel_A.png")] public static var GfxVowelAImg: Class;
		[Embed(source = "../../../../assets/gfx/vowel_E.png")] public static var GfxVowelEImg: Class;
		[Embed(source = "../../../../assets/gfx/vowel_I.png")] public static var GfxVowelIImg: Class;
		[Embed(source = "../../../../assets/gfx/vowel_O.png")] public static var GfxVowelOImg: Class;
		[Embed(source = "../../../../assets/gfx/vowel_U.png")] public static var GfxVowelUImg: Class;
		[Embed(source = "../../../../assets/gfx/vowel_al.png")] public static var GfxVowelaImg: Class;
		[Embed(source = "../../../../assets/gfx/vowel_el.png")] public static var GfxVoweleImg: Class;
		[Embed(source = "../../../../assets/gfx/vowel_il.png")] public static var GfxVoweliImg: Class;
		[Embed(source = "../../../../assets/gfx/vowel_ol.png")] public static var GfxVoweloImg: Class;
		[Embed(source = "../../../../assets/gfx/vowel_ul.png")] public static var GfxVoweluImg: Class;
		// ...
		public static const IMG_VOWEL_WIDTH:uint = 256;
		public static const IMG_VOWEL_HEIGHT: uint = 256
		public static var vowelImages: Array = [GfxVowelAImg, GfxVowelEImg, GfxVowelIImg, GfxVowelOImg, GfxVowelUImg, 
												GfxVowelaImg, GfxVoweleImg, GfxVoweliImg, GfxVoweloImg, GfxVoweluImg];		//this definition must be after embedded classes
		
		//Tilesheet icon Config dialog
		[Embed(source = "../../../../assets/gfx/IconSheetConfigDlg.png")] public static var GfxIconsConfigDlg: Class; 
		public static const IMG_ICONCONFIGDLG_WIDTH:uint = 44; 
		public static const IMG_ICONCONFIGDLG_HEIGHT: uint = 44; 

		
		//Tilesheet icon Parental Gate dialog
		[Embed(source = "../../../../assets/gfx/ts_shapeParentalGateDlg.png")] public static var GfxShapesParentalGateDlg: Class;
		public static const IMG_SHAPEPARENTALDLG_WIDTH:uint = 54; 
		public static const IMG_SHAPEPARENTALDLG_HEIGHT: uint = 18; 
		public static const NUM_SHAPEPARENTALDLG: uint = 8; 
		[Embed(source = "../../../../assets/gfx/IconSheetParentalGateDlg.png")] public static var GfxIconsParentalGateDlg: Class; 
		public static const IMG_ICONPARENTALDLG_WIDTH:uint = 44; 
		public static const IMG_ICONPARENTALDLG_HEIGHT: uint = 44; 
		

		
		//Tilesheet icon End Level dialog
		[Embed(source = "../../../../assets/gfx/ts_icoNumberLvl.png")] public static var GfxIconsEndLevelDlg: Class;
		public static const IMG_ICONLEVELDLG_WIDTH:uint = 48; 
		public static const IMG_ICONLEVELDLG_HEIGHT: uint = 48; 
		
		//Tilesheet buttons
		[Embed(source = "../../../../assets/gfx/btHUD.png")] public static var GfxButtonsHUD: Class;
		public static const BUTTON_HUD_WIDTH:uint = 36;
		public static const BUTTON_HUD_HEIGHT: uint = 36;		
		public static const BUTTON_HUD_SEPX: uint = 8;
		public static const BUTTON_HUD_SEPY: uint = 8;
		public static const BUTTON_HUD_SEPINX: uint = 4;
		public static const BUTTON_HUD_SEPINY: uint = 4;		
		[Embed(source = "../../../../assets/gfx/btDlg.png")] public static var GfxButtonsDlg: Class; 
		public static const BUTTON_DLG_WIDTH:uint = 36; 
		public static const BUTTON_DLG_HEIGHT: uint = 36;  
		[Embed(source="../../../../assets/gfx/btPanelMenuMain.png")] public static var GfxButtonsPanelMenuMain: Class;
		public static const BUTTON_MENU_WIDTH:uint = 200;
		public static const BUTTON_MENU_HEIGHT:uint = 200;
		[Embed(source="../../../../assets/gfx/btLinkStore.png")] public static var GfxButtonsLinkStore: Class;
		public static const BUTTON_STORE_WIDTH:uint = 96;
		public static const BUTTON_STORE_HEIGHT:uint = 96;
		
		[Embed(source = "../../../../assets/gfx/ts_btMenuLevel.png")] public static var GfxButtonsPanelMenuFase1: Class;
		[Embed(source = "../../../../assets/gfx/ts_btMenuLevel2.png")] public static var GfxButtonsPanelMenuFase2: Class;
		public static const BUTTON_LEVELVO_WIDTH:uint = 48;
		public static const BUTTON_LEVELVO_HEIGHT:uint = 48;
		
		public static const BUTTON_LEVELNO_WIDTH:uint = 40;
		public static const BUTTON_LEVELNO_HEIGHT:uint = 40;
		

				

		//fx engine
		[Embed(source = "../../../../assets/gfx/fx_frm116.png")] public static var GfxFxFrmBtn:Class;
		public static const FX_FRMBTN_WIDTH:uint = 116;
		public static const FX_FRMBTN_HEIGHT:uint = 116;		
		[Embed(source = "../../../../assets/gfx/fx_tapIndicator.png")] public static var GfxFxTapIndicator: Class;
		public static const FX_TAPIND_WIDTH:uint = 32;
		public static const FX_TAPIND_HEIGHT:uint = 32;
		
		//fx game
		[Embed(source = "../../../../assets/gfx/fx_piece3PreInBox.png")] public static var GfxFxPiecePreInBox: Class;
		public static const FX_PIECE3_WIDTH:uint = 48;
		public static const FX_PIECE3_HEIGHT:uint = 48;
		
		//Sprites
		//Sprites Puzzle 1
		//[Embed(source = "../../../../assets/gfx/pieceBox1.png")] public static var GfxSpritePieceBox1: Class;
		//public static const SPRITE_PIECEBOX1_WIDTH:uint = 44;
		//public static const SPRITE_PIECEBOX1_HEIGHT:uint = 44;
		//Sprites Puzzle 3
		[Embed(source = "../../../../assets/gfx/mskFigures.png")] public static var GfxSpritePieceShape: Class;
		public static const SPRITE_PIECESHAPE3_WIDTH: uint = 48;
		public static const SPRITE_PIECESHAPE3_HEIGHT: uint = 48;
		//From 0..8: numbers
		//From 9..15 alone pieces
		//From 15..xx simple connectable pieces
		//From xx..xxcomplex connectable pieces
		

		
		//Constantes colores
		public static const COL_BUT:uint = 0xffffaa66; // 0xffA1A7B7;
		public static const COL_TITBUT:uint = 0xffffeeee;

		//Game configuration definitions 
		public static const GAM_NUM_LEVELS:uint = 5; //5 levels in each vowel (+1 taking into account character selection level)
		//-- GameState subclass for each game level 
		public static var gameStates: Array = 
			[GameLevel1, GameLevel2, GameLevel2, GameLevel2, GameLevel2, GameLevel2,	//A: Menu, level-1,...level-5
			GameLevel1, GameLevel2, GameLevel2, GameLevel2, GameLevel2, GameLevel2,
			GameLevel1, GameLevel2, GameLevel2, GameLevel2, GameLevel2,  GameLevel2,
			GameLevel1, GameLevel2, GameLevel2, GameLevel2, GameLevel2, GameLevel2,
			GameLevel1, GameLevel2, GameLevel2, GameLevel2, GameLevel2,  GameLevel2,
			GameLevel1, GameLevel3, GameLevel3, GameLevel3, GameLevel3, GameLevel3,		//a: Menu, level-1, ..., level-5 
			GameLevel1, GameLevel3, GameLevel3, GameLevel3, GameLevel3, GameLevel3, 
			GameLevel1, GameLevel3, GameLevel3, GameLevel3, GameLevel3, GameLevel3, 
			GameLevel1, GameLevel3, GameLevel3, GameLevel3, GameLevel3, GameLevel3, 
			GameLevel1, GameLevel3, GameLevel3, GameLevel3, GameLevel3, GameLevel3]; 
		//-- Background image and extension img (W and H) for each game level 
		public static var gameIdBkg: Array = 
			[3, 0, 0, 3, 0, 0, 3, 0, 0, 3, 0, 0, 3, 0, 0, 3, 0, 0, 	//A: Blue => Bkg Orange+(yellow+green) 
			 5, 0, 0, 5, 0, 0, 5, 0, 0, 5, 0, 0, 5, 0, 0, 5, 0, 0,	//E: Red  => ! Bkg Green (squares)
			 6, 0, 0, 6, 0, 0, 6, 0, 0, 6, 0, 0, 6, 0, 0, 6, 0, 0,	//I: Orange => Bkg Gray (tiles) 
			 7, 0, 0, 7, 0, 0, 7, 0, 0, 7, 0, 0, 7, 0, 0, 7, 0, 0,	//O: Purple => Bkg  orange+white (pills)
			 8, 0, 0, 8, 0, 0, 8, 0, 0, 8, 0, 0, 8, 0, 0, 8, 0, 0,	//U: Green => Bkg Red+(pink+white) (circles)
			 9, 0, 0, 9, 0, 0, 9, 0, 0, 9, 0, 0, 9, 0, 0, 9, 0, 0, 		//a: Blue => Bkg Brown (wood)
			10, 13, 14, 10, 13, 14, 10, 13, 14, 10, 13, 14, 10, 13, 14, 10, 13, 14, //e: Red =>  Blue (sea)			
			11, 15, 16, 11, 15, 16, 11, 15, 16, 11, 15, 16, 11, 15, 16, 11, 15, 16, //i: Orange => Blue (mosaic)
			12, 17, 18, 12, 17, 18, 12, 17, 18, 12, 17, 18, 12, 17, 18, 12, 17, 18, //o: Green => green-white (squared circles)
			4, 0, 0, 4, 0, 0, 4, 0, 0, 4, 0, 0, 4, 0, 0, 4, 0, 0		//u: Green => red (tablecloth)
			];  
		
		public function Assets() 
		{	
			
		}
		
		
		////////////////////////////////////////////////////////////////////////// Sound
		
		
		public static function playSound(name:String,t:Number=0):void {
			if(Registry.bSnd)
				(sSounds[name] as Sound).play(t);
		}
		
		public static function getSound(name:String):Sound 
        { 
            var sound:Sound = sSounds[name] as Sound; 
            if (sound) return sound; 
            else throw new ArgumentError("Sound not found: " + name); 
        } 


		public static function prepareSounds():void 
        { 
            sSounds["BtHud"] = new sndBtHud();
			sSounds["BtGroupLevel"] = new sndBtGroupLevel();
			sSounds["BtVowel"] = new sndBtVowel()
			sSounds["BtLevel"] = new sndBtLevel()
			sSounds["TObjRnd"] = new sndTObjRnd(); 
			
			sSounds["Piece1sel"] = new sndPiece1sel(); 
			sSounds["Piece1ok"] = new sndPiece1ok(); 
			sSounds["Piece1ko"] = new sndPiece1ko();
			
			sSounds["Piece2sel"] = new sndPiece2sel(); 			
			sSounds["Piece2ok"] = new sndPiece2ok();
			sSounds["Piece2ko"] = new sndPiece2ko();	
			
			sSounds["Piece3sel"] = new sndPiece3sel(); 		
			sSounds["Piece3ok"] = new sndPiece3ok();
			sSounds["Piece3ko"] = new sndPiece3ko();
			
			sSounds["EndLevel"] = new sndEndLevel();
		/*
			sSounds["BtGroupLevel"] = new sndBtGroupLevel();
			sSounds["Faceok"] = new sndFaceok();
			sSounds["FaceGroupok"] = new sndFaceGroupok();
 

			
			sSounds["EndLevel"] = new sndEndLevel();
			sSounds["EndRound"] = new sndEndRound();
			sSounds["Star"] = new sndStar();
			sSounds["No1"] = new sndNo1();
			sSounds["No2"] = new sndNo2();
			sSounds["No3"] = new sndNo3();
			sSounds["No4"] = new sndNo4();
			sSounds["No5"] = new sndNo5();
			sSounds["No6"] = new sndNo6();
			sSounds["No7"] = new sndNo7();
			sSounds["No8"] = new sndNo8();
			sSounds["No9"] = new sndNo9();
			*/
        } 
		
		
		////////////////////////////////////////////////////////////////////////// Assets ImaEngine
		//Icons
		[Embed(source = "../../../../assets/gfx/icon_back_32x32.png")] public static var GfxIcon0: Class;
				
	}
	
	//AREA (vertical disposition DST 1)
	//sep: 16 (4 border)
	//number: 100
	//sep: 16
	//dst1: 32
	//sep: 16 (4 border)
	//h-area: 180
	
	//DOWNAREA: 76 
	//        16 
	//        44 
	//        16 
	
	
	//AREA (vertical disposition DST2)
	//sep: 16 (4 border)
	//number: 100
	//sep: 4
	//dst2: 24
	//sep: 4
	//dst2: 24
	//sep:8 (4 border)
	//h-area: 180
	
	//DOWNAREA: 76 
	//        4 
	//        32 
	//        4 
	//        32 
	//        4 
		
	//AREA (vertical disposition DST 3)
	//sep: 16 (4 border)
	//number: 100
	//sep: 8
	//dst2: 20
	//sep: 8
	//dst2: 20
	//sep:8 (4 border)
	//h-area: 180
 
	//DOWNAREA: 76 
	//        8 
	//        24 
	//        12 
	//        24 
	//        8 
	
}

