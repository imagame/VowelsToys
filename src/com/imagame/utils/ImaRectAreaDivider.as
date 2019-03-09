package com.imagame.utils 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/** 
	* Creator of subrect divisions of a Rectangle that surrounds a Shape (image). 
	* The divisions have the following features: 
	* - Square divisions based on same width and height 
	* - Optional variation of width of height based in a random parameter limited by a % of variation   
	* - Optional removing of blank divisions (divisions that not overlap with the shape included in the source rect) 
	* - Area of divisions greater or equal to rect area containing the shape (displacement of areas indicated by offset parameter) 
	* - Returning a list of divisions including initial x,y pos and with-height of the subrect division 
	* @author imagame 
	*/ 
	public class ImaRectAreaDivider 
	{   
		private var _bmd: BitmapData;        //bmd with the image contained in pos [_xShape,_yShape] of the rect to be divided 
		private var _x: uint;        //relative x position of image within rect area to divide 
		private var _y: uint;        //relative y position of image within rect area to divide         
		private var _w: uint;        //width of rect to be divided 
		private var _h: uint;        //height of rect to be divided 
				
		private var _divisions: Vector.<uint>;        //Vector to storage the divisions [x,y,w,h] 
		private var _numDivs: uint;        //Number of subrects divisions 
		private var _numsepx: uint; //Number of separation axes in x 
		private var _numsepy: uint; //Number of separation axes in y 
		private var _numsepadd: uint //Number of additional separations to be made in subrecs 
		private var _stdW: uint //standar division width
		private var _stdH: uint //standar division height
		
		private var _auxPoint: Point = new Point(); 
		private var _auxRect: Rectangle = new Rectangle(); 
		//auxiliar structures 
		//private var _divTab: Vector.<uint>;        //[numDivs, num_of_x_sep, num_of_y_sep, num_of_additional_subrect_divs] (to be filled til 20 divisions) 
		
		
		/** 
		 * Shape divider constructor 
		 * @param        bmd        Image to divide and check against to discard blank divisions 
		 * @param        inX        relative x position of image within rect area to divide 
		 * @param        inY        relative y position of image within rect area to divide 
		 * @param        inW        width of rect area to divide 
		 * @param        inH        height of rect area to divide           
		 * @return 
		 */ 
		public function ImaRectAreaDivider(bmd: BitmapData, inX: uint=0, inY: uint=0, inW: uint=0, inH:uint=0) //TODO: color vector parameter 
		{ 
			trace("ImaRectAreaDivider >> ImaRectAreaDivider()"); 

			_bmd = bmd.clone();                                   
			if(inW==0){ 
				_x =0; 
				_w = bmd.width; 
			} 
			else { 
				_x = inX; 
				_w = inW; 
			} 
			if(inH==0) { 
				_y = 0; 
				_h = bmd.height; 
			} 
			else { 
				_y = inY; 
				_h = inH; 
			} 
			
			//init auxiliar data required to perform divisions  (Alternative to calculate it dinamically) 
			//divTab = new Vector<uint>(20); 
			//divTab.push(2,1,0,0, 3,1,0,1, 4,); 
			//divTab[0].push(9,0,0, 1,32,0,                 
			//setDivsAndParams(2); //search and set the params to reach the _numDivs goal (sepx,sepy,addSep)                 
		} 

		
		public function destroy():void {         
			_bmd = null; 
			_divisions = null; 
		} 
		
		/** 
		* Set the divisions parameters (_numsepx, _numsepy and _numsepadd) to get <numDivs> subrects divisions within the original rect area 
		*/ 
		private function setDivisions(numDivs: uint):void { 
			_numDivs = numDivs; 
			_numsepx = _numsepy = _numsepadd = 0; 
			
			if(_numDivs < 2) //At least the area has to be divided in 2 subrects 
				return; 
							
			var res: uint = 0; 
			var p: uint = 1; 
			var q: uint = 1; 
			do { 
				if(p==q)         
					p++; 
				else 
					q++; 
				res = p*q;         
			} while (res < _numDivs) //or the compute of subdivisions is exact, or is greater than the expected result. 
			
			_numsepx = p-1; 
			_numsepy = q-1;                 
			if(res == _numDivs) 
				_numsepadd = 0; 
			else { //If subdivs computation is greater than expected result, adjust one axis division, and compute cell subdivisions required to match numDivs expected result. 
				_numsepx--;        //Remove one separation to let create additional subdivisions in existing divs. 
				_numsepadd = _numDivs - ((_numsepx+1)*(_numsepy+1)); 
			} 
		} 
		

		/** 
		* Create an exact number of subrects within the origina area rect, with a variable widh/height depending on size factor (0..1) 
		*/ 
		public function createDivisions(numDivs:uint, factorHomog: Number):Vector.<uint> { 
			//Check correct factorHomog 
			if(factorHomog <= 0)   
				factorHomog = 0; 
			else if (factorHomog >=1) 
				factorHomog = 0.9; 
																			
			//1.- Set params to create subrects 
			setDivisions(numDivs);        //Calculate _numsepx, _numsepy, _numsepadd 
			_divisions = new Vector.<uint>; // (4 * _numDivs);        //x,y,w,h                         
			var sepx = (uint)(_w/(_numsepx+1));  //x axis width separation (without adjustment) 
			var sepy = (uint)(_h/(_numsepy+1)); //y axis height separation (without adjustment)         
			
			//2.- Calculate subrects within original rect area (0,_w, 0, _h) in rows&columns format (with exception for additional subrects)         
			var rAct = new Rectangle(0,0,0,0); 
			var rAnt = new Rectangle(0,0,0,0);         

			for(var j:uint = 0; j<= _numsepy; j++) {        //all rows 
				//Calc subrect height                                 
				if(j <_numsepy) { 
					var adjusty:uint = ImaUtils.randomize(-sepy*factorHomog,sepy*factorHomog) 
					rAct.height = sepy + adjusty; 
				} 
				else //last row                                 
					rAct.height = _h - (rAnt.y + rAnt.height);
				
				//Calc subrects in current row (j) 
				rAct.y = rAnt.y + rAnt.height; 
				rAnt.x = rAnt.width = 0; 
				for (var i:uint = 0; i< _numsepx; i++) {        //all columns minus 1 in row 
					//subrect init pos 
					rAct.x = rAnt.x + rAnt.width;                                                                                 
					//calc subrect width 
					var adjustx:uint = (uint)(ImaUtils.randomize(-sepx*factorHomog,sepx*factorHomog)); 
					rAct.width = sepx + adjustx; 
					
					//Store subrect 
					_divisions.push(rAct.x,rAct.y,rAct.width,rAct.height); 

					//Remind ant subrect 
					rAnt.x = rAct.x; 
					rAnt.width = rAct.width; 
				} 
				//last subrect in row 
				rAct.x = rAnt.x + rAnt.width;         
				rAct.width = _w - rAct.x; 
				//Store last subrect in row 
				_divisions.push(rAct.x, rAct.y, rAct.width, rAct.height);    
				
				rAnt.y = rAct.y;
				rAnt.height = rAct.height;
			} 
			
			_stdW = rAct.width;
			_stdH = rAct.height;
			
			//3.- Create additional subrects to match exact number of divisions 
			//Plan: set N=P*Q, identify subrect (within the first N subrects), remove, divide and add to the end of the list, substract N by 1 
			var nsubrects:uint = (_numsepx+1) * (_numsepy+1); 
			for(var k:uint= 0; k<_numsepadd; k++) { 
				var idsubrect:uint = (uint)(ImaUtils.randomize(0,nsubrects-1)); 
				//Divide y axis (since subrects are originally same w/h or may be greater height (1 more sep in x axis than y axis) 
				var idx:uint = idsubrect*4; 
				rAnt.x= _divisions[idx]; 
				rAnt.y= _divisions[idx+1]; 
				rAnt.width = _divisions[idx+2]; 
				rAnt.height = _divisions[idx+3]; 
				
				//remove from the vector the selected subrect to be divided 
				_divisions.splice(idx,4); 
				
				//var divy:uint = (uint)(ImaUtils.randomize(-sepx*factorHomog,sepx*factorHomog)); 
				var divy:uint =  (uint) (rAnt.height /2); 
				_divisions.push(rAnt.x, rAnt.y, rAnt.width, divy); 
				_divisions.push(rAnt.x, rAnt.y+divy, rAnt.width, rAnt.height-divy); 
				
				//Update nsubrects in case there are more additional separators to avoid divide subrects already divided 
				nsubrects--; 
			} 
			//Assert(_numDiv == _divisions.length/4); 
			
			return _divisions; 
		} 

		
		/**
		 * Create divisions and remove those ones that not overlap with the image
		 * @param	numDivs
		 * @param	factorHomog
		 * @return
		 */
		public function createDivisionsWithoutBlanks(numDivs:uint, factorHomog: Number):Vector.<uint> { 
			//Steps 1,2 and 3
			createDivisions(numDivs, factorHomog); 
			
			//4.- Apply subrects to image projected among original rect area 
			//Options: Remove or group subrects based in differente conditions 
			//opt1: Remove blank subrects; 
			//opt2: Remobe subrects in the corners 
			//opt3: remove subrects in the sides 
			//other opts:.... 
			
			var blankStdBmd: BitmapData = new BitmapData(_stdW, _stdH, true, 0x0); 
			var blankDiv: Boolean;
			var idx:uint = 0; 			
			for(var i:uint=0; i < numDivs; i++) { 				
				//1-obtain subimage from _bmd corresponding to the current rect division 
				var currBmd: BitmapData = new BitmapData(_divisions[idx + 2], _divisions[idx + 3],true, 0x0);  
				_auxRect.setTo(_divisions[idx], _divisions[idx + 1], _divisions[idx + 2], _divisions[idx + 3]); 
				currBmd.copyPixels(_bmd, _auxRect, _auxPoint, null, null, true); 
				//currBmd.setPixel(0, 0, 0x00FF45);
				//2- compare it to the blankBmd (the standard one or a new specifically created based on division concrete dimensions) 
				//var res: int = currBmd.compare(blankStdBmd) as int; 
				
			//	var diffBmpData:BitmapData = currBmd.compare(blankStdBmd) as BitmapData;
     		//	trace ("0x" + diffBmpData.getPixel(0, 0).toString(16));
				blankDiv = false;
				if(currBmd.compare(blankStdBmd) == 0)
					blankDiv = true;
				else if(currBmd.compare(blankStdBmd) == -3 || currBmd.compare(blankStdBmd) == -4){ 
					var blankConcreteBmd: BitmapData = new BitmapData(_divisions[idx+2], _divisions[idx+3], true, 0x0); 
					if( currBmd.compare(blankConcreteBmd) == 0) 
						blankDiv = true;
					blankConcreteBmd.dispose(); 
					blankConcreteBmd = null; 
				} 
				
				//3- if comparison result is 0 then the image is void, and has to be spliced from the _divisions vector (test if can be done in this same loop, or has to be done outside it-> it would require to register div-ids in a local array) 
				if(blankDiv){ 
					//Blank division [idx] 
					//OP1: remove within this loop 
					_divisions.splice(idx,4);  //check if loop advances 4 steps more 
					//OP2: save and remove later: 
					//blankDivs.push(idx); 
				} 
				else                         
					idx+=4; 
			} 
			
			//Op2-cont: remove (from rear to front) 
			//for(var i:uint=blankDivs.lenght-1; i>=0; i--){                         
			//        _divisions.splice(blankDivs[i], 4); 
			//} 
			
			blankStdBmd.dispose(); 
			blankStdBmd = null; 
			
			return _divisions; 
		} 
	}

}