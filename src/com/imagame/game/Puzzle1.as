package com.imagame.game 
{
	import com.greensock.TweenLite;
	import com.imagame.engine.Registry;
	import com.imagame.fx.DashedLine;
	import com.imagame.fx.Draw;
	import com.imagame.fx.ImaFx;
	import com.imagame.fx.ImaFxGroupTapIndicator;
	import com.imagame.fx.ImaFxSelArea;
	import com.imagame.utils.ImaBitmapSheet;
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Vowel character image decoration
	 * @author imagame
	 */
	public class Puzzle1 extends AbstractPuzzle 
	{		
		private var _dstSizePos: Vector.<Point>;        //List of size dimension (w,h) for dst positions (rect area) 
		
		private var _selAreaList: Vector.<ImaFxSelArea>;
		private var _dstRectPos: Vector.<Rectangle>; 	
		private var _bmpPre: Bitmap;
		
		private var idT1: TweenLite;
		private var idT2: TweenLite;
													
		/**
		 * Puzzle 1: Set bodyparts in each of the object types
		 * @param	id
		 * @param	pieces
		 * @param	dstPos
		 * @param	dstSize		List of sizes for each pos
		 * @param	dstMapPiece
		 */
		public function Puzzle1(id:uint, pieces:Vector.<Piece>, dstPos: Vector.<Point>, dstSize: Vector.<Point>, dstMapPiece: Vector.<uint>) 
		{
			_dstSizePos = dstSize.map(pointCloner); 
			super(id, pieces, dstPos, dstMapPiece);		
			// _numPieces = dstPos.length; 
			 
			 //Create AreaRect objects, with dstPos as the left pivot point, and with dstSize as dimensions 
			_selAreaList = new Vector.<ImaFxSelArea>(_numPieces); //after puzzle creation _numPieces has the same value as Assets.NUMTOBJ 
			for (var i = 0; i < _numPieces; i++) {  	
				//_selAreaList[i] = new ImaFxSelArea(_dstRectPos[i].x - 32, _dstRectPos[i].y - 32, _dstRectPos[i].width + 64, _dstRectPos[i].height + 64); // , col, thick, sep1, sep2); 
				_selAreaList[i] = new ImaFxSelArea(_dstRectPos[i].x - 8, _dstRectPos[i].y - 8, _dstRectPos[i].width + 16, _dstRectPos[i].height + 16); // , col, thick, sep1, sep2); 
				//_selAreaList[i] = new ImaFxSelArea(_dstRectPos[i].x, _dstRectPos[i].y, _dstRectPos[i].width, _dstRectPos[i].height); // , col, thick, sep1, sep2); 				
				addChild(_selAreaList[i]); 				
			} 			
			//_selAreaList[0].visible = true;
		}
				
		override protected function createPuzzleImage(pieces: Vector.<Piece>):uint { 
			var s:GameState = (Registry.game.getState() as GameState);
			_tileSheet = new ImaBitmapSheet(Assets.vowelImages[s.phase], Assets.IMG_VOWEL_WIDTH, Assets.IMG_VOWEL_HEIGHT);
			_bmp = _tileSheet.getTile(1); 
			_bmp.visible = false;
            addChild(_bmp);
			_bmpPre = _tileSheet.getTile(0);
			addChild(_bmpPre);
			
 
			x = (uint)((Registry.gameRect.width - _bmp.width) * 0.5);	//uint: fuerza quitar decimales
			y = (uint)(Registry.appUpOffset + 16); 

			
			return Assets.NUMTOBJ;
		} 
		
		
		/** 
		* Create auxiliar structures required to check correct piece dst position  
		*/           
		override protected function createAuxStructures(pieces: Vector.<Piece>):void { 
			super.createAuxStructures(pieces); 
			
			//Mark as free positions those ones where a piece of any category is able to be put	
			_dstRectPos = new Vector.<Rectangle>(_numPieces); 
			for (var i:uint = 0; i < _numPieces; i++){ 
				_dststslist[i] = DSTSTS_FREE; 		
				_dstRectPos[i] = new Rectangle (_dstLocalPos[i].x - _dstSizePos[i].x * 0.5, _dstLocalPos[i].y - _dstSizePos[i].y * 0.5, _dstSizePos[i].x, _dstSizePos[i].y);   //Local leup pos, w, h     (Local: dentro de 256x256)      
				
				//_dstRectPos[i] = new Rectangle (32, 32, _dstSizePos[i].x, _dstSizePos[i].y);      //Local leup pos, w, h     (Local: dentro de 256x256)
			}
			
		} 
			
		
		override public function destroy():void { 	
			if (idT1 != null) {
				idT1.kill();
				idT1 = null;
			}
			if (idT2 != null) {
				idT2.kill();
				idT2 = null;
			}
			
			for (var i:uint = 0; i < _numPieces; i++){
				_dstRadio[i] = null; 
			}
			_dstRadio = null;
			
			for (var i:uint = 0; i < _selAreaList.length; i++) {
				removeChild(_selAreaList[i]);
				_selAreaList[i].destroy();
				_selAreaList[i] = null;
			}
			_selAreaList = null;
			
			removeChild(_bmpPre);
			_bmpPre = null;
			
			super.destroy(); 
		}
		
		override public function init():void { 
			//FX Vowel init: fade-out outlined image, fade-in rendered image
			_bmp.alpha = 0;
			_bmp.visible = true; 
			idT1 = TweenLite.to(_bmp, 1, { delay:1,  alpha:1} );
			idT2 = TweenLite.to(_bmpPre, 1, { delay:1, alpha:0,	onComplete: function(){_bmpPre.visible = false; }} );
		} 			

		/** 
		 * Check if drop position is valid, based on group dropping condition (distance < _radio) 
		 * Assumption: only one position must be valid at the same time 
		 * @param	x 
		 * @param  	y 
		 * @param 	piece	Piece that ask to check if located in correct position
		 * @return  True if pos (x,y) is a valid destination position 
		 */ 
        override public function chkCorrectDstPos(x: Number, y: Number, piece: Piece, updSts: Boolean=false): Point { 
			//r: a que round pertenece la pieza: 
			//idx: indice secuencia relativa dentro del round r 
			//To check in _dstPos[_round[_roundAct] + idx] 
			//return null;
			for (var i:uint = 0; i < _numPieces; i++) { 
				var d:Number = distance(x, y, _dstGlobalPos[i].x, _dstGlobalPos[i].y);
				if(d<32){
				//option 1: total distance 
				//if(distance(x, y, _dstGlobalPos[i].x, _dstGlobalPos[i].y) < 32) { 
				//Option 2: Axis distance (w/2,h/2) 
				//if(distanceAxis(x, _dstGlobalPos[i].x) < _dstSizePos[i].x * 0.5 && distanceAxis(y, _dstGlobalPos[i].y) < _dstSizePos[i].y * 0.5) { 
				//Option 2: Axis distance (w/3, h/3) 
				//if(distanceAxis(x, _dstGlobalPos[i].x) < _dstSizePos[i].x * 0.3 && distanceAxis(y, _dstGlobalPos[i].y) < _dstSizePos[i].y * 0.3) {                                 
					if(_dstMapPiece[i] == piece.category) 
						return _dstGlobalPos[i]; 
				} 
			}                         
			return null; 
		} 
		
 
				
		protected function distanceAxis(x1: Number, x2: Number): Number { 			
			return Math.abs(x1 - x2);
		} 
		
		
		protected function isPuzzleComplete():Boolean { 
			for(var i:uint=0; i<_dststslist.length; i++){ 
				if(_dststslist[i] != DSTSTS_OCCUPIED) 
					return false; 
			} 
			return true; 
		} 		
		
		//------------------------------------------------------------------- Callbacks                    	             		
		
		
		/**
		 * Event called when an box piece is selected and starts drag&drop operation over the puzzle
		 * @param	InPiece
		 */
		public function onBodyPartSelect(InPiece: Piece1):void { 
			_selAreaList[InPiece.category].startFx();
			this.setChildIndex(_selAreaList[InPiece.category], this.numChildren-1);
		} 

		public function onBodyPartRestore(InPiece: Piece1):void { 
			_selAreaList[InPiece.category].stopFx();
		} 
		
		/** 
		 * Update group sprites execution. To be overriden 
		 */ 
		override public function update():void { 
			super.update();	//Call update method of sprite members
		
			//BodyPart selection area animation
			for(var i:uint=0; i< _selAreaList.length; i++){ 
				_selAreaList[i].update();
			}
			
			if(_sts != STS_FINISHED) { 
				if (isPuzzleComplete()){ //final condition: (all have been put in puzzle)                                         
					_sts = STS_FINISHED;                                                                                                                                 
				} 
			} 
		} 
            
	}

}