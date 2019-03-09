package com.imagame.game 
{
	import com.imagame.engine.ImaSpriteAnim;
	import com.imagame.engine.ImaState;
	import com.imagame.engine.Registry;
	import com.imagame.utils.ImaBitmapSheet;
	import com.imagame.utils.ImaBitmapSheetDirect;
	import com.imagame.utils.ImaCompositeImage;
	import com.imagame.utils.ImaRectAreaMap;
	import com.imagame.utils.ImaSubBitmapSheet;
	import com.imagame.utils.ImaUtils;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.BevelFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Creator of pieces with the following features:
	 * - Square pieces with same width and height and an color attribute 
	 * A puzzle to be created requires:
	 * - Create list of pieces
	 * - Create Destination positions for the pieces (relative positions)
	 * - Map each piece to every posible destination (a Map function for every position accepting a list of pieces --or kind of pieces--)
	 * @author imagame
	 */
	public class PieceCreator3 implements IPieceCreator 
	{
		private var _pieces: Vector.<Piece>;
		private var _dstPos: Vector.<Point>;	//Destination local positions (local pos within _img puzzle image)
		private var _dstMapPiece: Vector.<uint>;	//list of id figures to let check which piece/s map to each dst position
		
		private var _numPieces: uint;	//Number of pieces in puzzle (length of list _pieces)

		private var _id: uint;			//id level within phase (1..5)
		private var _idPhase: uint;		//Phase id-> (0:a, 1:e, 2:i, 3:o, 4:u)         
		private var _img: Bitmap;		//Bmp background image ----with the vowel images (without bodyparts) 
		private var _imgVowel: Bitmap;	//Bmp (rendered vowel without bodyparts) 
		private var _bmp: Bitmap;		//Bmp (rendered vowel with bodyparts)
		
		private var _gameState: ImaState;	//GameState that creates this object
		
		
		//specific piece creator variables
		private static const NUM_SHAPES: uint = 15+ 64; //Number of different shapes (mask pieces)
		private static const IDX_SHAPE_CONNECT: uint = 15; //Idx of the first connectable shape
		private var _shapeSize: Vector.<Point>;
		private var _shapeGroup: Array; //array of arrays to store definition of group of shapes (definition: piece shape and relative pos in group)
		private var _shapeGroupNumber: Vector.<uint>;	//number of shapes in each shapeGroup
		
		private var _auxPoint: Point = new Point();
		private var _auxPoint2: Point = new Point();
		private var _auxRect: Rectangle = new Rectangle(); 
	
		//Define the groups of pieces for each level number 
		var _groups: Vector.<uint> = new Vector.<uint>; 	//4 vals for each group: x,y, groupType, group_id within group type 

		private var _imgComp: ImaCompositeImage; //Composite image (_img with bodyparts on it)         	
		private var _piecesList: Vector.<int>;        //List of pieces id corresponding to the 5 bodyparts of the vowel 
		private var _posList: Vector.<int>; //Local center x,y pos within _img area where _pieceList pieces are located 
		
		
		/**
		 * Creator of Puzzle-3
		 * @param	id			Current level of difficulty (1..numLevels)	
		 * @param	imgVowel	Base image composed of background + centered vowel img (required to obtain the pieces content) => img corresponding to the required idPhase
		 * @param	img			background image 
		 * @param	gameState
		 */
		public function PieceCreator3(id: uint, idPhase: uint, imgVowel: Bitmap, img: Bitmap, gameState: ImaState, piecesList: Vector.<int>, posList: Vector.<int>)  
		{
			trace("IPIECECREATOR >> PieceCreator3()");
			
			_id = id;
			_idPhase = idPhase;
			_imgVowel = imgVowel;
			_img = img;
			
			_gameState = gameState;
			_piecesList = piecesList.concat(); 
			_posList = posList.concat(); 
			
			//Define size of shapes 
			_shapeSize = new Vector.<Point>(NUM_SHAPES);
			for(var i:uint=0; i< NUM_SHAPES; i++) 
				_shapeSize[i] = new Point(Assets.SPRITE_PIECESHAPE3_WIDTH, Assets.SPRITE_PIECESHAPE3_HEIGHT);				
				
			//Shape groups definition
			_shapeGroup = new Array(9); //9 numbers 
			for(var i:uint=0; i< 9; i++) 
				_shapeGroup[i] = new Array(); 
			
			//Group Type 0: Groups of 1 shape => 3 groups	
			for (var i:uint = 0; i<NUM_SHAPES; i ++)
				_shapeGroup[0].push(i, 0, 0); //shapeId, relative pos x, relative pos y
				
			//Group Type 1: Groups of 2 shapes => 3 groups
			_shapeGroup[1].push(34,0,0, 40,0,16, 46,0,0, 60,0,16, 14,0,0, 4,0,16, 49,0,0, 51,0,16, 62,0,0, 44,0,16, 21,0,0, 23,0,16); //[3x4C] (groups of 2 shapes) 
			_shapeGroup[1].push(5,0,0, 15,16,0, 49,0,0, 59,16,0, 21,0,0, 23,16,0, 45,0,0, 63,16,0, 41,0,0, 35,16,0, 62,0,0, 60,16,0);//[4x3C] 
			_shapeGroup[1].push(25,0,0, 23,0,16, 14,0,0, 60,0,16);//[3x4NC] 
			_shapeGroup[1].push(33,0,0, 47,16,0, 24,0,0, 26,16,0);//[4x3NC] 
			_shapeGroup[1].push(10,0,0, 16,0,32, 36,0,0, 8,0,32);//[3x5C] 
			_shapeGroup[1].push(39,0,0, 11,32,0, 9,0,0, 19,32,0);//[5x3C] 
			_shapeGroup[1].push(2,0,0, 20,0,32, 18,0,0, 53,0,32, 10,0,0, 12,0,32);//[3x5NC] 
			_shapeGroup[1].push(16,0,0, 46,32,0, 3,0,0, 52,32,0, 29,0,0, 11,32,0);//[5x3NC] 
			_shapeGroup[1].push(28,0,0, 23,16,16, 21,0,0, 3,16,16, 34,16,0, 3,0,16, 24,16,0, 20,0,16);//[4x4NC] 
			_shapeGroup[1].push(27,0,0, 16,16,32, 25,16,0, 27,0,32);//[4x5NC] 
			_shapeGroup[1].push(24,32,0, 28,0,16, 29,0,16, 31,32,0);//[5x4NC] 
			_shapeGroup[1].push(47,32,0, 58,0,32, 1,0,0, 34,32,32);//[5x5NC] 

			//Group Type 2: Groups of 3 shapes                                                                 
			_shapeGroup[2].push(40,0,0, 24,32,0, 22,48,0, 20,0,0, 26,16,0, 42,48,0, 21,0,0, 27,0,16, 43,0,48, 41,0,0, 25,0,32, 23,0,48);        //[3x6,6x3C]//3rd group of 3 shapes 
			_shapeGroup[2].push(9,0,0, 1,32,0, 11,64,0, 54,0,0, 3,32,0, 52,64,0, 62,0,0, 60,16,0, 0,64,0);//[3x7C] 
			_shapeGroup[2].push(10,0,0, 1,0,32, 8,0,64, 55,0,0, 29,0,32, 8,0,64, 0,0,0, 62,0,48, 56,0,64);//[7x3C] 
			_shapeGroup[2].push(19,0,0, 13,0,32, 3,0,64, 14,0,0, 35,0,16, 19,0,64, 21,0,0, 30,0,32, 8,0,64, 18,0,0, 57,0,32, 43,0,64, 29,0,0, 13,0,32, 19,0,64);//[3x7NC] 
			_shapeGroup[2].push(54,0,0, 44,32,0, 19,64,0, 40,0,0, 31,32,0, 46,64,0, 18,0,0, 12,32,0, 58,64,0, 18,0,0, 12,32,0, 50,64,0, 44,0,0, 24,32,0, 47,64,0);//[7x3NC]                         
			_shapeGroup[2].push(15,0,0, 2,0,32, 11,0,80, 40,0,0, 34,32,0, 50,80,0);//[3x8,8x3NC] 
			_shapeGroup[2].push(5,16,0, 32,0,16, 34,32,0, 16,0,0, 34,32,0, 12,32,16, 63,16,0, 33,0,16, 56,0,32, 2,0,0, 13,0,32, 35,16,32);//[4x5,5x4NC] 
			_shapeGroup[2].push(9,0,0, 30,32,0, 43,32,32, 29,32,0, 9,0,32, 15,32,32, 9,32,0, 32,16,16, 32,0,32, 26,32,0, 30,0,16, 31,32,32);//[5x5NC] 
			_shapeGroup[2].push(35,16,0, 49,0,16, 30,16,48, 21,0,0, 16,16,16, 53,0,48, 49,0,0, 26,16,16, 17,16,48, 18,16,0, 24,0,16, 16,48,16);//[4x6,6x4NC] 
			_shapeGroup[2].push(3,0,0, 24,32,32, 20,16,48, 63,0,0, 29,48,0, 44,32,32, 10,16,0, 8,0,32, 3,48,32, 28,0,0, 47,48,0, 45,32,32);//[5x6,6x5NC] 
			_shapeGroup[2].push(36,0,0, 3,16,32, 38,32,64, 30,32,0, 1,16,32, 28,0,64);//[5x7,7x5NC] 
					
			//Group Type 3: Groups of 4 shapes                                                                 
			_shapeGroup[3].push(23,0,0, 20,48,0, 22,0,48, 21,48,64); //[sr-1] 1st group of 4 shapes 
			_shapeGroup[3].push(29,16,0, 30,48,16, 28,0,32, 31,32,48); //[sr-2] 
			_shapeGroup[3].push(46,0,0, 58,48,0, 48,0,16, 60,48,16); //[sr-3] 
			_shapeGroup[3].push(28,0,0, 14,32,0, 31,64,0, 8,32,32); //[sav-1] 
			_shapeGroup[3].push(36,32,0, 39,0,16, 37,64,16, 14,32,48); //[sav-2] 
			_shapeGroup[3].push(54,16,0, 32,0,16, 42,48,16, 35,16,32); //[sah-1] 
			_shapeGroup[3].push(30,48,0, 6,16,32, 4,32,48, 28,0,80); //[sao-1] 
			_shapeGroup[3].push(1,0,0, 27,16,16, 27,32,32, 23,48,48); //[sao-2] 
			_shapeGroup[3].push(46,0,0, 45,48,0, 47,0,32, 44,48,32); //[sao-3] 
			_shapeGroup[3].push(33,0,0, 6,16,16, 32,32,32, 51,48,48); //[ns-1] 
			_shapeGroup[3].push(21,0,0, 50,48,0, 1,16,16, 12,48,16); //[ns-2] 
			_shapeGroup[3].push(36,32,0, 21,0,32, 25,16,48, 37,48,48); //[ns-3] 
			_shapeGroup[3].push(40,32,0, 28,0,32, 37,64,32, 31,32,48); //[ns-4] 
			_shapeGroup[3].push(51,16,0, 49,0,16, 63,32,48, 61,32,64); //[ns-5] 
			_shapeGroup[3].push(21,0,0, 30,32,0, 29,16,32, 8,16,64); //[ns-6] 
			_shapeGroup[3].push(2,48,0, 9,16,32, 32,0,48, 11,48,48); //[ns-7] 

			//Group Type 4: Groups of 5 shapes                                                                                 
			_shapeGroup[4].push(36, 16, 0, 37, 64, 16, 1, 32, 32, 39, 0, 48, 38, 48, 64); //[sr-1] 1st group of 5 shapes 			
			_shapeGroup[4].push(3,0,0, 2,64,0, 0,32,32, 2,0,64, 3,64,64 ); //[sr-2] 
			_shapeGroup[4].push(46,0,0, 58,64,0, 32,0,16, 1, 32,16, 35,64,16);//[sav-1] 
			_shapeGroup[4].push(40,0,0, 2,32,0, 14,64,0, 16,96,0, 42,128,0);//[sav-2] 
			_shapeGroup[4].push(36,32,0, 8,32,32, 39,0,64, 37,64,64, 16,32,80);//[sav-3] 
			_shapeGroup[4].push(49,0,0, 2,48,0, 26,16,16, 35,64,16, 53,32,48);//[ns-1] 
			_shapeGroup[4].push(18,0,0, 24,48,0, 3,16,32, 32,0,48, 3,48,48);//[ns-2] 
			_shapeGroup[4].push(21,0,0, 30,32,0, 2,16,32, 28,0,64, 23,32,64);//[ns-3] 

			//Group Type 5: Groups of 6 shapes                                                                 
			_shapeGroup[5].push(33,0,0, 55,48,0, 29,16,16, 23,32,32, 40,0,48, 35,48,48); //[sr-1] 1st group of 6 shapes 
			_shapeGroup[5].push(21,0,0, 34,48,0, 34,32,16, 0,16,32, 32,0,48, 23,48,48);//[sr-2] 
			_shapeGroup[5].push(32,32,0, 1,64,32, 11,96,32, 9,0,48, 1,32,48, 34,64,80);//[sao-1] 
			_shapeGroup[5].push(30,48,0, 33,0,16, 6,16,32, 4,32,48, 35,48,64, 28,0,80);//[sao-2] 
			_shapeGroup[5].push(30,48,0, 9,0,32, 1,32,32, 9,80,32, 37,112,32, 31,48,64);//[sah-1] 
			_shapeGroup[5].push(1,32,0, 45,0,16, 59,64,16, 28,0,48, 14,32,48, 31,64,48);//[sav-1] 
			_shapeGroup[5].push(39,0,0, 14,32,0, 25,64,0, 24,32,32, 37,64,32, 53,32,64);//[ns-1] 
			_shapeGroup[5].push(2,48,0, 3,0,16, 1,32,32, 37,80,32, 50,0,64, 3,48,64);//[ns-2] 
               														
			//Group Type 6: Groups of 7 shapes                                                                 
			_shapeGroup[6].push(1,16,0, 1,64,0, 26,0,32, 2,48,32, 24,96,32, 1,32,64, 1,80,64);        //[sr-1] 1st group of 7 shapes => OK-m 
			_shapeGroup[6].push(18,32,0, 45,0,16, 59,64,16, 28,0,48, 14,32,48, 31,64,48, 8,32,80); //[sav-1] 
			_shapeGroup[6].push(25,16,0, 36,64,0, 13,0,32, 11,32,32, 19,80,32, 24,16,64, 38,64,64); //[sah-1] 
			_shapeGroup[6].push(29,0,0, 30,80,0, 1,16,32, 11,48,32, 19,96,32, 28,0,64, 31,80,64);//[sah-2] 
			_shapeGroup[6].push(3,16,0, 2,80,0, 35,96,16, 0,48,32, 33,0,48, 2,16,64, 3,80,64); //[sr-2] 
			_shapeGroup[6].push(29,16,0, 11,64,16, 25,32,32, 27,80,48, 39,0,64, 33,48,64, 60,32,80); //[ns-1] 
			_shapeGroup[6].push(21,32,0, 30,48,16, 9,0,48, 1,32,48, 9,80,48, 37,112,48, 31,48,80); //[ns-2] 
			_shapeGroup[6].push(63,80,0, 51,48,32, 33,32,48, 35,64,48, 61,112,48, 56,0,80, 57,48,80); //[ns-3] 			
                        
			//Group Type 7: Groups of 8 shapes                                                                                         
			_shapeGroup[7].push(36,80,0, 35,48,32, 39,0,48, 32,96,48, 34,32,80, 37,128,80, 33,80,96, 38,48,128); //[sr-1] 1st group of 8 shapes => OK-f 
			_shapeGroup[7].push(12,48,0, 15,0,48, 0,48,48, 13,96,48, 20,16,80, 23,80,80, 14,48,96, 8,48,128); //[sav-1] 
			_shapeGroup[7].push(21,32,0, 30,48,16, 9,0,48, 1,32,48, 9,80,48, 37,112,48, 31,48,80, 20,32,96);//[sah-1] 
			_shapeGroup[7].push(36,64,0, 36,112,0, 39,0,32, 11,32,32, 19,80,32, 19,128,32, 38,64,64, 38,112,64);//[sah-2] 
			_shapeGroup[7].push(36,48,0, 17,32,32, 42,80,32, 44,64,48, 39,0,64, 28,32,80, 43,80,80, 38,48,112);//[sah-3] 
			_shapeGroup[7].push(25,32,0, 23,32,16, 24,0,64, 22,16,64, 20,64,64, 26,80,64, 21,32,112, 27,48,112);//[ns-1] 
			_shapeGroup[7].push(30,80,0, 33,32,16, 3,112,16, 6,48,32, 2,0,48, 4,64,48, 35,80,64, 28,32,80); //[ns-2] 
			_shapeGroup[7].push(49,0,0, 58,48,0, 59,80,0, 26,16,16, 29,80,32, 9,0,48, 47,32,48, 8,80,64); //[ns-3]
					
			//Group Type 8: Groups of 9 shapes								
			_shapeGroup[8].push(12,48,0, 21, 16,16, 22,80,16, 15,0,48, 0,48,48, 13,96,48, 20,16,80, 14,48,96, 23,80,80 );        //[sr-1] 1st group of 9 shapes => OK-med-fac 
			_shapeGroup[8].push(14, 48,0, 3, 16,16, 2, 80,16, 13, 0,48, 0, 48,48, 15, 96,48, 2, 16, 80, 3, 80, 80, 12, 48,96 ); //[sr-2] OK->m 
			_shapeGroup[8].push(1, 16, 0, 3, 32, 32, 2, 96, 32, 1, 128, 16, 0, 64, 64, 1, 0, 112, 2, 32, 96, 3, 96, 96, 1, 112, 128); //[sr-3]2nd group of 9 shapes => OK-f 
			_shapeGroup[8].push(25,0,0, 36,48,0, 36,96,0, 11,16,32, 19,64,32, 1,112,32, 24,0,64, 38,48,64, 38,96,64); //[sah-1] 
			_shapeGroup[8].push(36,64,0, 35,32,32, 56,64,48, 39,0,64, 58,112,64, 37,144,64, 57,48,80, 59,80,96, 38,80,128); //[ns-1] 			
			_shapeGroup[8].push(59,0,0, 2,0,32, 62,48,48, 33,96,48, 25,128,48, 57,0,64, 35,32,64, 60,80,64, 23,128,64); //[ns-2] 
			_shapeGroup[8].push(62, 0, 0, 12, 0, 16, 22, 32, 32, 33, 0, 64, 38, 32, 64, 32, 0, 112, 36, 32, 112, 47, 32, 144, 17, 0, 160); //[ns-3] 
			_shapeGroup[8].push(33,0,0, 51,32,0, 63,96,0, 33,16,16, 35,48,16, 61,96,16, 57,32,48, 3,64,64, 56,96,64);//[ns-4] 

			
			//Adjust correct id shapes
			for (var i:uint = 1; i < _shapeGroup.length; i++) {
				for (var j:uint = 0; j < _shapeGroup[i].length; j+=3) {
					_shapeGroup[i][j] += IDX_SHAPE_CONNECT;
				}
			}
								
			//Calculates number of shapes in each shapeGroup
			_shapeGroupNumber = new Vector.<uint>(9);			
			for(var i:uint=0; i< 9; i++) 
				_shapeGroupNumber[i] = _shapeGroup[i].length / (3 * (i + 1)); //3: (pieceId,xpos,ypos)
									
			setGroupsPieces();	//Define the groups of pieces (_groups vector) to set in the puzzle 
			createCompositeImage(); //creates and sets _bmp
			//copy composite image on bkg
			//var _bmpSheet: ImaBitmapSheet = new ImaBitmapSheet(Assets.vowelImages[_idPhase], Assets.IMG_VOWEL_WIDTH, Assets.IMG_VOWEL_HEIGHT); 
			_img.bitmapData.copyPixels(
				_bmp.bitmapData,
				new Rectangle(0, 0, Assets.IMG_VOWEL_WIDTH, Assets.IMG_VOWEL_HEIGHT), 
				new Point((uint)((Registry.gameRect.width - Assets.IMG_VOWEL_WIDTH) * 0.5), 
				(uint)(Registry.appUpOffset + 16)),
				null, null, true);
				
			createPieces();		//Creates the list of pieces (_pieces vector) based on groups definition 				
			createDstPositions();			
		}
		
		
		public function destroy():void {
			for (var i:int = 0; i < _pieces.length; i++)
				_pieces[i].destroy();
			_pieces = null;
			for (var i:int = 0; i < _dstPos.length; i++)
				_dstPos[i] = null;
			_dstPos = null;
			_dstMapPiece = null;
			
			//delete shape structures
			for (var i:int = 0; i < NUM_SHAPES; i++)
				_shapeSize[i] = null;
			_shapeSize = null;

			for (var i:int = 0; i < _shapeGroup.length; i++)
				_shapeGroup[i] = null;
			_shapeGroup = null;
			
			_shapeGroupNumber = null;
			_auxPoint = null;
			_auxPoint2 = null;
			_auxRect = null;
			
			_groups = null;
			_gameState = null;
		}
			
	
		/**
		 * Get total size of a group of shapes (takes into account all pieces within the group)
		 * @param	groupType	Group type= Number of pieces in group. Values 0..8 (number of pieces -1)
		 * @param	groupIdx	Group idx in group _shapeGroup[groupPieces]
		 * @return	Point: Width, height of group
		 */
		protected function getSizeGroup(groupType: uint, groupIdx: uint):Point {
			var w:uint = 0;
			var h: uint = 0;
			
			var inc:uint = 3 * (groupType + 1);	
			var idx:uint = groupIdx * inc;
			var xini: uint = _shapeGroup[groupType][idx + 1];	//_shapeGroup[type][] = shapeId, relative pos x, relative pos y
			var yini: uint = _shapeGroup[groupType][idx + 2];
			
			//for each shape in the group 
			for (var i:uint = 0; i < (groupType + 1); i++) {
				//Detect min initial pos
				if (_shapeGroup[groupType][idx + 1] < xini)	
					xini = _shapeGroup[groupType][idx + 1];
				if (_shapeGroup[groupType][idx + 2] < yini)	
					yini = _shapeGroup[groupType][idx + 2];
					
				//Detect max width
				//if x-relative_pos + piece_width is greater than max_width
				if (_shapeGroup[groupType][idx + 1] + _shapeSize[_shapeGroup[groupType][idx]].x > w)	
					w = _shapeGroup[groupType][idx + 1] + _shapeSize[_shapeGroup[groupType][idx]].x;
				//if y-relative_pos + piece_height is greater than max_height
				if (_shapeGroup[groupType][idx + 2] + _shapeSize[_shapeGroup[groupType][idx]].y > h)	
					h = _shapeGroup[groupType][idx + 2] + _shapeSize[_shapeGroup[groupType][idx]].y;	
				
				idx += 3; //idx += inc;
			}
			
			//final size: lower pos_x of pice  + bigger piece pos_x+width value //same for height
			w -= xini;
			h -= yini;
			
			_auxPoint.setTo(w, h);
			return _auxPoint;
		}
		
		/**
		 * Get id of shape, calculated from pieceGroup idx and idx of group 
		 * @param	groupType		id of the group (0..8 group sets)
		 * @param	groupIdx		set idx within the group (N groups in each group set)
		 * @param	pieceIdx		piece idx within the set (groupPiecesId+1 pieces in each group)
		 * @return	Idx of shape (0..NUM_SHAPES-1)
		 * */
		protected function getShapeId(groupType: uint, groupIdx: uint, shapeIdx:uint):uint {
			return _shapeGroup[groupType][groupIdx * 3 * (groupType + 1) + shapeIdx*3];
		}
		

		/** 
		 * Create a list of groups <_groups> distributed on the image without overlaping, and based on configuration rules 
		 */         
		protected function setGroupsPieces():void { 
			
			//Option 1: Fixed definition for each level. ///DISCARDED
			/*
			switch(_id) { 
				//global x and y not adjusted (within default game-rect coords: 480x320) 
				case 1:     //_groups.push(32, 0, 0, 0,  64, 96, 0, 1,   32, 160, 0, 2);        //x,y, group_id, figure_id 
							_groups.push(280,120,0,1,  280, 200, 1, 1,  130, 80, 2, 0   ); 								
							break; 
				case 2:     _groups.push(280,120,0,1,  280, 200, 1, 1,  130, 80, 2, 0   ); 
							break; 
			} 
			*/
				
			//Option 2: Group parametrized definiton 
			//Description: Variable definition, based in a set of parameters depending of each number phase (_id) 
			//For example: for _id=0 creates 4 groups of only 1 piece 
			//For example: for _id=1 creates 2 groups of only 1 piece, and 1 group of 2 pieces 
			//For example: for _id=2 creates 3 groups of only 1 piece, and 1 group of 3 pieces 
			//For example: for _id=3 creates 1 groups of only 1 piece, 2 groups of 2 pieces, and 1 group of 4 pieces 
			//For example: for _id=3 creates 2 groups of only 1 piece, 2 groups of 2 pieces, and 1 group of 5 pieces 
			//For example: for _id=3 creates 2 groups of only 1 piece, 2 groups of 3 pieces, and 1 group of 6 pieces 
						
			var numGroupsByLevel: Array; 
			numGroupsByLevel = new Array(9); 
			for (var i:uint = 0; i < numGroupsByLevel.length; i++)
				numGroupsByLevel[i] = new Vector.<uint>;
							
			var lvl:uint = _id - 1; 			
			switch(lvl){
				case 0: //difficulty level
					numGroupsByLevel[0].push(1, 0, 0, 0, 0, 0, 0, 0, 0); //Num groups de nivel a
					numGroupsByLevel[1].push(2, 0, 0, 0, 0, 0, 0, 0, 0); //Num groups de nivel e
					numGroupsByLevel[2].push(3, 0, 0, 0, 0, 0, 0, 0, 0); //Num groups de nivel i
					numGroupsByLevel[3].push(4, 0, 0, 0, 0, 0, 0, 0, 0); //Num groups de nivel o
					numGroupsByLevel[4].push(4, 0, 0, 0, 0, 0, 0, 0, 0); //Num groups de nivel u
					break;
				case 1:
					numGroupsByLevel[0].push(0, 1, 0, 0, 0, 0, 0, 0, 0); //Num groups de nivel a
					numGroupsByLevel[1].push(1, 1, 0, 0, 0, 0, 0, 0, 0); //Num groups de nivel e
					numGroupsByLevel[2].push(0, 0, 1, 0, 0, 0, 0, 0, 0); //Num groups de nivel i
					numGroupsByLevel[3].push(0, 1, 1, 0, 0, 0, 0, 0, 0); //Num groups de nivel o
					numGroupsByLevel[4].push(0, 1, 0, 1, 0, 0, 0, 0, 0); //Num groups de nivel u
					break;					
				case 2:
					numGroupsByLevel[0].push(0, 1, 1, 0, 0, 0, 0, 0, 0); //Num groups de nivel 1
					numGroupsByLevel[1].push(1, 0, 0, 1, 0, 0, 0, 0, 0); //Num groups de nivel 2
					numGroupsByLevel[2].push(1, 1, 0, 1, 0, 0, 0, 0, 0); //Num groups de nivel 3
					numGroupsByLevel[3].push(0, 1, 0, 0, 1, 0, 0, 0, 0); //Num groups de nivel 4
					numGroupsByLevel[4].push(0, 0, 1, 0, 0, 1, 0, 0, 0); //Num groups de nivel 5
					break;					
				case 3:
					numGroupsByLevel[0].push(1, 0, 0, 0, 1, 0, 0, 0, 0); //Num groups de nivel 1
					numGroupsByLevel[1].push(1, 0, 0, 0, 0, 1, 0, 0, 0); //Num groups de nivel 2
					numGroupsByLevel[2].push(0, 1, 0, 0, 0, 1, 0, 0, 0); //Num groups de nivel 3
					numGroupsByLevel[3].push(0, 0, 1, 0, 0, 0, 1, 0, 0); //Num groups de nivel 4
					numGroupsByLevel[4].push(0, 0, 0, 1, 0, 0, 0, 1, 0); //Num groups de nivel 5
					break;					
				case 4:
					numGroupsByLevel[0].push(0, 0, 1, 0, 0, 1, 0, 0, 0); //Num groups de nivel 1
					numGroupsByLevel[1].push(0, 2, 0, 0, 0, 0, 1, 0, 0); //Num groups de nivel 2
					numGroupsByLevel[2].push(1, 0, 1, 0, 0, 0, 1, 0, 0); //Num groups de nivel 3
					numGroupsByLevel[3].push(0, 1, 0, 1, 0, 0, 0, 1, 0); //Num groups de nivel 4
					numGroupsByLevel[4].push(0, 1, 2, 0, 0, 0, 0, 0, 1); //Num groups de nivel 5
					break;					
				default: //rounds >=4
					trace("<<ERR>>: PieceCreator3.setGroupsPieces  (difficulty level not valid)");
			}
			
			
				//var g:Graphics = _gameState.dbgCanvas().graphics; //DEBUG
				//g.lineStyle(1,0x00ff00); //DEBUG
		
		
			//create rectAreaMap and zones within it
			var grpMap: ImaRectAreaMap = new ImaRectAreaMap(Registry.gameDefaultRect.width,Registry.gameDefaultRect.height); //320x240
			var zx:uint = (uint)((Registry.gameDefaultRect.width - Assets.IMG_VOWEL_WIDTH) * 0.5);	//480-192=288 / 2 = 144
			var zy:uint = (uint)(Registry.appUpOffset + 16); //				
			_auxRect.setTo(zx - 48, zy - 16, Registry.gameDefaultRect.width - (zx - 48) * 2, Assets.IMG_VOWEL_HEIGHT +  16 + 32); //96,24 288x272 
			grpMap.addZone(_auxRect); //w:60+120+60, h:20+200+20	//Zone 0
			//	g.drawRect(_auxRect.x + Registry.appLeftOffset, _auxRect.y, _auxRect.width, _auxRect.height);	//DEBUG draw rect before normalization
			_auxRect.setTo(zx, zy, Registry.gameDefaultRect.width - zx * 2, Assets.IMG_VOWEL_HEIGHT); //144,48 192x224			
			grpMap.addZone(_auxRect); //Zone 1
			//	g.drawRect(_auxRect.x+ Registry.appLeftOffset, _auxRect.y, _auxRect.width, _auxRect.height);	//DEBUG draw rect before normalization
	
			//add HUD elements zones (Zones 2 and 3 for HUD elements, and 4 if Ads enabled)
			var aHud: Array = ((GameState)(_gameState)).getHUDRects(); 
			for each(var r:Rectangle in aHud) { //r: global Rectangle. Have to be adjusted to local gameDefaultRect dimensios
				//8,8 36x36 // 409,8 116x36
				//g.drawRect(r.x, r.y, r.width, r.height); //DEBUG draw rect before normalization				
				Registry.gameRect2gameDefaultRect(r); //0,8 17x36 //382,8 98x36
				grpMap.addZone(r);									
			}
				
			
			//ASSING PIECES to the map area
			var val:uint = 0; 
			var idphase:uint = _idPhase-5;

			
			//In all levels: put 2 pieces corresponding to the current vowel (one uppercase, and one lowercase)
			grpMap.put(getSizeGroup(0,idphase*2),0,idphase*2,ImaRectAreaMap.TYPE_EXCLUDE_TOTAL,0,ImaRectAreaMap.TYPE_EXCLUDE_TOTAL,1,ImaRectAreaMap.TYPE_EXCLUDE_TOTAL,2, ImaRectAreaMap.TYPE_EXCLUDE_TOTAL, 3);
			grpMap.put(getSizeGroup(0,idphase*2+1),0,idphase*2+1,ImaRectAreaMap.TYPE_EXCLUDE_TOTAL,0,ImaRectAreaMap.TYPE_EXCLUDE_TOTAL,1,ImaRectAreaMap.TYPE_EXCLUDE_TOTAL,2, ImaRectAreaMap.TYPE_EXCLUDE_TOTAL, 3);
				
			//put groups of 1 piece, limited to geometric figures (not vowels)
			for (var j:uint = 0; j < numGroupsByLevel[idphase][0]; j++) {					
				val = ImaUtils.randomize(10, IDX_SHAPE_CONNECT - 1);
				grpMap.put(getSizeGroup(0, val), 0, val, ImaRectAreaMap.TYPE_EXCLUDE_TOTAL, 2, ImaRectAreaMap.TYPE_EXCLUDE_TOTAL, 3);					
				//grpMap.put(getSizeGroup(0, val), 0, val, ImaRectAreaMap.TYPE_EXCLUDE_TOTAL, 2, ImaRectAreaMap.TYPE_EXCLUDE_TOTAL, 3 , ImaRectAreaMap.TYPE_EXCLUDE_TOTAL, 4); //with Ads	
			} 		
			
			//For the rest of groups (2 pieces to 9 pieces), put the number of groups indicated in numGroupsByLevel[vowel-id]
			for (var i:uint = 8; i >= 1; i--) {
				var n:uint = numGroupsByLevel[idphase][i]; //Number of groups of type <i> to put in the map 
				for (var j:uint = 1; j <= n; j++) {  //For each group of type <i> 
					val = ImaUtils.randomize(0, _shapeGroupNumber[i]); //select a random shapeGroup id for the group type <i> 
					grpMap.put(getSizeGroup(i,val),i,val,ImaRectAreaMap.TYPE_INCLUDE_PARTIAL,0,ImaRectAreaMap.TYPE_EXCLUDE_TOTAL,2,ImaRectAreaMap.TYPE_EXCLUDE_TOTAL,3);              
					//grpMap.put(getSizeGroup(i,val),i,val,ImaRectAreaMap.TYPE_INCLUDE_PARTIAL,0,ImaRectAreaMap.TYPE_EXCLUDE_TOTAL,2,ImaRectAreaMap.TYPE_EXCLUDE_TOTAL,3, ImaRectAreaMap.TYPE_EXCLUDE_TOTAL, 4);       //con Ads
				}
			}
					
		
			
			_groups = grpMap.getList(); //get all group types, and all group ids within them 
			grpMap.destroy();
			
			//Adjust x,y group pos to global corrected pos 
			for (var i:uint = 0; i < _groups.length; i+=4) { 
					_groups[i] += Registry.appLeftOffset; 
					_groups[i + 1] += Registry.appUpOffset; 
			}                 
		} 
						
		/** 
		 * Create the image composing of a vowel and a set of bodyparts, from which the pieces will be created. 
		 */ 
		private function createCompositeImage():void {                 
			//Define bmpSheets to contain all Bodypart pieces 
			var bmpSheetPiece: Vector.<ImaSubBitmapSheet> = new Vector.<ImaSubBitmapSheet>(Assets.NUMTOBJ);                                         
			var idxCat:uint = 0; 
			_auxRect.x = _auxRect.y = 0; 
			for(var i:uint=0; i< Assets.NUMTOBJ; i++) {                                         
					_auxRect.width = Assets.IMG_GFX_BODYPART_WIDTH[idxCat]*Assets.NUMBODYPART; //2*num_bodypart 
					_auxRect.height = Assets.IMG_GFX_BODYPART_HEIGHT[idxCat];       
					bmpSheetPiece[i] = new ImaSubBitmapSheet(Assets.GfxPieceBodyPart, Assets.IMG_GFX_BODYPART_WIDTH[idxCat], Assets.IMG_GFX_BODYPART_HEIGHT[idxCat], _auxRect);                 
					_auxRect.y += Assets.IMG_GFX_BODYPART_HEIGHT[idxCat]; 
					idxCat++; 
			} 
			
			//Compose bkg img(256x26) with additional N images copied in local positions (reg centered) on the base img 
			_imgComp = new ImaCompositeImage(_imgVowel, 0,0, _imgVowel.width, _imgVowel.height); //256x256 
			
			for (var i:uint=0; i < _piecesList.length; i++ ) {  
					var id = _piecesList[i];
					var idxCat = id/Assets.NUMBODYPART; 
					var idxInCat = id%Assets.NUMBODYPART; 
					var wimg:int = bmpSheetPiece[idxCat].getTileWidth(); 
					var himg:int = bmpSheetPiece[idxCat].getTileHeight(); 
					var ximg:int = _posList[i*2]- wimg *0.5; 
					var yimg:int = _posList[i*2+1] - himg *0.5; 
					_imgComp.addBmd( bmpSheetPiece[idxCat].getTile(idxInCat).bitmapData, ximg, yimg); 
			}                         
			_bmp = _imgComp.getBmp(); 
									
			//release resources 
			bmpSheetPiece = null;                         
		} 	
		
		/**
		 * Create a list of pieces <_pieces> from an image <_img>
		 */
		protected function createPieces():void
		{			
			//Create the defined pieces 
			var abmpShapes:Bitmap = new Assets.GfxSpritePieceShape(); 
			var numShapeCols:uint = abmpShapes.width / Assets.SPRITE_PIECESHAPE3_WIDTH; 
			_auxPoint.setTo(0, 0); 
			
			//tilesheet for fx at initializing Piece (same tilesheet for all pieces) 
			var _bmpSheetFxPiece: ImaBitmapSheet = new ImaBitmapSheet(Assets.GfxFxPiecePreInBox, Assets.FX_PIECE3_WIDTH, Assets.FX_PIECE3_HEIGHT);                        
                        
			//Create the pieces included in each group 
			var _numGroups:uint = _groups.length / 4; 
			_pieces = new Vector.<Piece>; 
			_dstMapPiece = new Vector.<uint>; 
			var idPiece:uint = 0;        //Piece id within _pieces 
                        
			for (var i:uint = 0; i < _numGroups; i++) { //for each group 
				var pos:uint = i * 4; 
				var idGroup: uint = _groups[pos + 2]; //group type: 1-piece to 9-pieces
				
				var _numShapesInGroup:uint = _groups[pos + 2] + 1; 
				var idxShapeGroup: uint = _groups[pos + 3]; 
				var idxShape:uint = 0; 
				for (var j:uint = 0; j < _numShapesInGroup; j++) { //for each shape in current group create a Piece located in correct pos 
								
					//Create the corresponding piece to the shape in the group 
					var idShape:uint = getShapeId(idGroup, idxShapeGroup, idxShape/3); 
					_pieces[idPiece] = new Piece3(idPiece, idShape, _shapeSize[idShape]);        //create piece setting dst w and dst h 
					//set the correct location of the piece based in the group pos and the relative pos inside it 
					_pieces[idPiece].x = _groups[pos] + _shapeGroup[idGroup][idxShapeGroup * 3 * (idGroup + 1) + idxShape + 1];                //Set x local position in puzzle Board (all the playable screen, not margins), require to calculate dst position 
					_pieces[idPiece].y = _groups[pos + 1] + _shapeGroup[idGroup][idxShapeGroup * 3 * (idGroup + 1) + idxShape+2];        //Set y local position in puzzle Board (all the playable screen, not margins), require to calculate dst position 
					
					_dstMapPiece[idPiece] = idPiece; 
								
					//create piece bitmapdata and cut the piece shape from the _img using the corresponding shape alphabitmapdata mask 
					var bmdPiece:BitmapData = new BitmapData(_shapeSize[idShape].x, _shapeSize[idShape].y, true, 0x00000000);                                         
					_auxRect.setTo(_pieces[idPiece].x, _pieces[idPiece].y, _shapeSize[idShape].x, _shapeSize[idShape].y);                                           
					_auxPoint2.setTo((uint)(idShape % numShapeCols) * Assets.SPRITE_PIECESHAPE3_WIDTH, (uint)(idShape / numShapeCols) * Assets.SPRITE_PIECESHAPE3_HEIGHT); 
					bmdPiece.copyPixels(_img.bitmapData, _auxRect, _auxPoint, abmpShapes.bitmapData, _auxPoint2, true); //copy piece bitmap with alphabitmap                                         
					
					_pieces[idPiece].addAnimation("InPuzzle",
							new ImaBitmapSheetDirect(new Bitmap(bmdPiece), _shapeSize[idShape].x, _shapeSize[idShape].y), 
							null, [0]); 

					//Apply foreground bevel effect                                                                                                                 
					var bmdPieceFilter: BitmapData = bmdPiece.clone(); 
					_auxRect.setTo(0, 0, _shapeSize[idShape].x, _shapeSize[idShape].y); 
					bmdPieceFilter.applyFilter(bmdPieceFilter, _auxRect, _auxPoint, new BevelFilter(2));                         
					var bmpSheetPieceFilter: ImaBitmapSheetDirect = new ImaBitmapSheetDirect(new Bitmap(bmdPieceFilter), _shapeSize[idShape].x, _shapeSize[idShape].y); //TODO create more frames with fx 
					
					//Create "inBox" animation 
					_pieces[idPiece].addAnimation("InBox", bmpSheetPieceFilter, null, [0]); //necesario null y [0] ?? 
					//Create "PreinBox" animation: FX prior to inbox animation 
					_pieces[idPiece].addAnimation("PreInBox", _bmpSheetFxPiece, null, [0, 0, 1, 2, 3,4,5,6,7,8,9,10,11,12,13,14], null, 10,false,null,onFinishAnimCB); 
					
					idxShape +=3;        //3 values for each figure within _shapeGroup 
					idPiece++;                                                 
				} 
			} 
			_numPieces = idPiece; 
		} 

		function onFinishAnimCB(spr: ImaSpriteAnim):void {
			(spr as Piece).playAnimation("InBox");
		}
		
		/**
		 * Create a list of destination positions for the list of pieces, based in 0,0 local origin.
		 */
		protected function createDstPositions():void {
			_dstPos = new Vector.<Point>(_numPieces);			
					
			for (var i:uint = 0; i < _numPieces; i++) {
				_dstPos[i] = new Point(_pieces[i].x + _pieces[i].w * 0.5, _pieces[i].y + _pieces[i].h* 0.5);	//Adjust registration point to center for each position
			}			
		}
				
		
		
		/* INTERFACE com.imagame.game.IPieceCreator */
		
		public function createPuzzle():AbstractPuzzle 
		{
			return (new Puzzle3(0, _pieces, _dstPos, _dstMapPiece, _bmp));	
		}
		
		public function getPieces():Vector.<Piece> 
		{
			return _pieces; 
		}
		

		
	}

}