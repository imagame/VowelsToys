package com.imagame.game 
{ 
        import com.imagame.engine.ImaPropManager; 
        import com.imagame.engine.Registry; 
        
        /** 
         * ... 
         * @author imagame 
         */ 
        public class PropManager extends ImaPropManager 
        { 
                
                private var levelProgress:Vector.<int>;        //Max Level arrived in <phase> (0 not started, 1: vowel character composed, 2: level 1 completed,...6: level5 completed) 
                //private var levelPuzzlePieces:Vector.<uint>;        //Piece id put on vowel image, from vowel 0 to 9 
                //private var levelPuzzlePos:Vector.<uint>;                //x,y pos of piece in corresponding pos within <levelPuzzlePieces> 
                private var levelPuzzlePieces:Vector.<Vector.<int>>;        //Piece id put on vowel image, from vowel 0 to 9 
                private var levelPuzzlePos:Vector.<Vector.<int>>; 
                
                
                public var levelTotal:uint;         //current total progress (summing up lower and uppercase vowels progress) 
                public static const MAXLEVEL:uint = 5;        //number of total levels per vowel 
                

                public function PropManager(soName:String) 
                { 
                        super(soName); 
                        levelProgress = new Vector.<int>(10);        //10 phases (vowels).         
                        //Opt0: 1-dim vector 
                        //levelPuzzlePieces = new Vector.<uint>(10*Assets.NUMTOBJ ); 
                        //levelPuzzlePos = new Vector.<uint>(10*Assets.NUMTOBJ *2); 
                        
                        //Opt1 
                        //levelPuzzlePieces = new Vector.<Vector.<uint>(Assets.NUMTOBJ)>(10); 
                        //levelPuzzlePos = new Vector.<Vector.<uint>(Assets.NUMTOBJ*2)>(10); 
                        
                        //Op2 
                        levelPuzzlePieces = new Vector.<Vector.<int>>(10); 
                        levelPuzzlePos = new Vector.<Vector.<int>>(10); 
                        for(var i:uint=0; i< 10; i++){ 
                                levelPuzzlePieces[i] = new Vector.<int>(Assets.NUMTOBJ); 
                                levelPuzzlePos[i] = new Vector.<int>(Assets.NUMTOBJ*2); 
                        } 
                        
                        initData();                                                     
                } 
                
        

                /** 
                * Advance the level <idLvl> for the vowel <idPhase> (called after finishing level <idLvl: 1..5>) 
                * @param idLvL Level id, value between 1 and maxLevel 
                */ 
                public function advanceLevel(inIdPhase:uint, inIdLvl:int = -1):void { 
                        if(levelProgress[inIdPhase] <= inIdLvl) { 
                                levelProgress[inIdPhase] = inIdLvl+1; 
                                levelTotal++; 
                        }                                 
                } 
                
                /** 
                * Advance initial level to level 1, and sets the vowel image with compounding bodyparts. 
                */ 
                public function advanceFirstLevel(inIdPhase:uint, inPieces: Vector.<int>, inPos: Vector.<int>):void { 
                        if(levelProgress[inIdPhase] == 0) 
                                levelProgress[inIdPhase] = 1; 
                                                                
						levelPuzzlePieces[inIdPhase] = inPieces.concat();                                 
                        levelPuzzlePos[inIdPhase] = inPos.concat();		
                        //levelPuzzlePieces[inIdPhase * Assets.NUMTOBJ ] = inPieces.concat();                                 
                        //levelPuzzlePos[inIdPhase  * Assets.NUMTOBJ * 2] = inPos.concat();                                                                               
                } 

		/** 
		*        Returns vector of body part pieces for vowel <inIdPhase> 
		*/ 
		public function getlevelPuzzlePieces(inIdPhase: uint):Vector.<int> { 
			return levelPuzzlePieces[inIdPhase]; 
		} 
		
		public function getlevelPuzzlePos(inIdPhase: uint):Vector.<int> { 
			return levelPuzzlePos[inIdPhase]; 
		} 
                
        public function getLevelProgress(inIdPhase: uint): uint { 
			return levelProgress[inIdPhase]; 
		} 
        
                
                //*************************************** Set operations 
                
        public function setGameProgress(inLvlPrg: Array):void { 
                        for (var i:uint = 0; i < 10; i++) { 
                                levelProgress[i] = inLvlPrg[i]; 
                                if (levelProgress[i] >= 1) { //create body parts selection 
										for (var j:uint = 0; j < Assets.NUMTOBJ ;j++)
											levelPuzzlePieces[i][j] = 0; //bodypart id para cada uno de los 5 typeObj                                                                        
                                } 
                        } 
                        //Set fixed pieces pos for each vowel, same x center-pos for all bodypart types, and same fixed y position for each bodypart type(based in Assets)   
                        //(TODO: Variable y position, depending on user drop position) 
     /*                   levelPuzzlePos[0].push( (uint)(Assets.IMG_VOWEL_WIDTH * 0.5), Assets.IMG_GFX_BODYPART_POSY[0], 
                                                                        (uint)(Assets.IMG_VOWEL_WIDTH * 0.5), Assets.IMG_GFX_BODYPART_POSY[1], 
                                                                        (uint)(Assets.IMG_VOWEL_WIDTH * 0.5), Assets.IMG_GFX_BODYPART_POSY[2], 
                                                                        (uint)(Assets.IMG_VOWEL_WIDTH * 0.5), Assets.IMG_GFX_BODYPART_POSY[3], 
                                                                        (uint)(Assets.IMG_VOWEL_WIDTH * 0.5), Assets.IMG_GFX_BODYPART_POSY[4]); //Vowel a 
       */                 for(var j:uint=0; j<10; j++) { 
                                //levelPuzzlePos[j] = levelPuzzlePos[0].concat();        //10 values: x,y pos for each bodypart 
                                for (var k:uint = 0; k < Assets.NUMTOBJ; k++) {
										levelPuzzlePos[j][k * 2] = (uint)(Assets.IMG_VOWEL_WIDTH * 0.5);	//fixed x for all bodyparts, in all vowels
 										levelPuzzlePos[j][k*2+1] = Assets.IMG_GFX_BODYPART_POSY[j * Assets.NUMTOBJ  + k];  //fixed y per bodypart, configured in each vowell
								}
                        } 
                        
                } 
                
                
                //********************* 
                
                /** 
                * Initialize game progress (for 1st game session) 
                */ 
                override protected function initData():void {                         
                        resetLevelProgress(); 
                        levelTotal = 0; 
                } 
                
                protected function resetLevelProgress():void { 
                        /* 
                        for (var i:uint = 0; i < 10; i++) { 
                                levelProgress[i] = 0;        //By default the first level (lvl 0) is the max level we have arrived 
                                for(var j:uint=0; j< Assets.NUMTOBJ; j++){ 
                                        levelPuzzlePieces[i *Assets.NUMTOBJ + j] = 0; 
                                        levelPuzzlePos[i *Assets.NUMTOBJ*2 + j * 2 ] = 0; 
                                        levelPuzzlePos[i *Assets.NUMTOBJ*2 + j * 2 +1] = 0; 
                                } 
                        } 
                        */                         
                        for (var i:uint = 0; i < 10; i++) { 
                                levelProgress[i] = 0;        //By default the first level (lvl 0) is the max level we have arrived 
                                for(var j:uint=0; j< Assets.NUMTOBJ; j++){ 
                                        levelPuzzlePieces[i][j]= 0; 
                                        levelPuzzlePos[i][j * 2 ] = 0; 
                                        levelPuzzlePos[i][j * 2 +1] = 0; 
                                } 
                        } 
                        
                } 

                
                        
                /** 
                 * Set "game" properties from a data Object, which has been obtained from saved data in a local store, or initialized data by the game 
                 * @param        data 
                 */ 
                                
                override protected function setData(data: Object):void { 
                        super.setData(data); 
                        //Preprocess data based in engine o game versions 
                        if(data.imaEngineVersion != Registry.IMAENGINE_VERSION) {
							trace("Data saved with old Engine version saved:"+data.ImaEngineVersion+" Reg: "+Registry.IMAENGINE_VERSION); 
                                        //TODO Conversion required 
						}
                        if(data.gameVersion != Registry.GAME_VERSION) 
                                        trace("Data saved with old Game version"); 
                                        //TODO Conversion required 
                                        
                        levelTotal = data.levelTotal;                         
						levelProgress = data.levelProgress;
						
						//levelPuzzlePieces = data.levelPuzzlePieces; 
						for (var i:int = 0; i < levelPuzzlePieces.length; i++) {
							levelPuzzlePieces[i] = data.levelPuzzlePieces[i]; // inPieces.concat();   
						}
						
					
                        //levelPuzzlePos = data.levelPuzzlePos; 
						for (var i:int = 0; i < levelPuzzlePos.length; i++) {
							levelPuzzlePos[i] = data.levelPuzzlePos[i]; // inPieces.concat();   
						}
                } 


                /** 
                 * Get "game" properties in data Object, to be saved in a local store. 
                 * @param        data 
                 */ 
                override protected function getData(data:Object):void { 
                        super.getData(data); 

                        data.levelTotal = levelTotal;         
                        data.levelProgress = levelProgress; 
                        data.levelPuzzlePieces = levelPuzzlePieces; 
                        data.levelPuzzlePos = levelPuzzlePos; 
                }                 
        } 

} 