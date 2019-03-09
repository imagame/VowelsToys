package com.imagame.game 
{
	import com.imagame.engine.ImaButton;
	import com.imagame.engine.ImaIcon;
	import com.imagame.engine.ImaTimer;
	import com.imagame.engine.Registry;
	import com.imagame.fx.ImaFx;
	import com.imagame.fx.ImaFxCircularProgressCtrl;
	import com.imagame.utils.ImaBitmapSheet;
	import com.imagame.utils.ImaUtils;
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import org.osflash.signals.Signal;

	/**
	 * Box with piece categories as In-Box pieces and rest of pieces as Out-Box pieces
	 * Number of inbox Pieces: Same as _pieceCategories values, equal to number o elements in _srcId an _srclist
	 * @author imagame
	 */
	public class Box1 extends AbstractBox 
	{				
		private var _iconList: Vector.<IconBodyPart>;	//List of body part icons belonging to all object Type. %5 icons with 5 different imgs each one)
		private var _numObjectTypes: uint;
		private var _numBodyParts: uint;
		private var _idxSelObjectType: int;        //Object type selected id (0.._numObjectsTypes-1) 
		
		public function Box1(id:uint, pieces:Vector.<Piece>, numBodyParts:uint, numObjectTypes:uint) 
		{ 
			super(id, pieces); 
			trace("ABSTRACTBOX >> Box1() " + id);	
			cacheAsBitmap = false;	//avoid cache to keep pices in in-box correctly painted in its group position
			
			//Create Body parts icon list
			_numBodyParts = numBodyParts; 
			_numObjectTypes = numObjectTypes; 
			_iconList = new Vector.<IconBodyPart>(_numBodyParts); 
			//var iniy:uint = (Registry.appUpOffset > 20)? Registry.appUpOffset+32:52; 
			var iniy:uint = Registry.appUpOffset + 64; 
			var _bmpSheetIcon:ImaBitmapSheet = new ImaBitmapSheet(Assets.GfxIconBodyPart, Assets.IMG_ICON_BODYPART_WIDTH, Assets.IMG_ICON_BODYPART_HEIGHT);
			var offset:uint = 0; //3 pictures per bodyPart (missing icon, disabled icon, active icon)
			var offsetStep:uint = 3 * _numBodyParts;
			for(var i:uint=0; i< _numBodyParts; i++) {        //Set active buttons, depending on game progress 
				_iconList[i] = new IconBodyPart(i, _bmpSheetIcon, 
					[offset + 0, offset + offsetStep, offset + offsetStep*2, offset + offsetStep*3, offset + offsetStep*4], //"iconMissing" anim
					[offset + 1, offset + 1 +offsetStep, offset + 1 +offsetStep*2, offset + 1 +offsetStep*3, offset + 1 +offsetStep*4]); //"iconDisabled" anim					
				_iconList[i].x = 8 
				//_iconList[i].y = iniy + 6 + i * Assets.IMG_ICON_BODYPART_HEIGHT + (i - 1) * 6;        //8:sepy 
				_iconList[i].y = iniy+ i*Assets.IMG_ICON_BODYPART_HEIGHT;        //8:sepy 
				_iconList[i].visible = false;
				addChild(_iconList[i]); 
				
				_iconList[i].playAnimation("iconMissing", false, 0); //start anim in the correct frame. It will be stopped since frameloop is 0
				//_iconList[i].pauseAnimation(); //and pause it 
				
				offset += 3; //3 pictures per bodyPart (missing icon, disabled icon, active icon)
			} 	
			
			//Se the source position for inbox pieces (body part objects)
			setSrcPosList();  
			
			//Callbacks declaration
			(Registry.game.getState() as GameLevel1).signalTObjClick.add(onChangeInBoxPieces); 
		} 
		
		override public function destroy():void { 
			//remove  body part icon list
			for(var i:uint=0; i< _numBodyParts; i++){ 
				removeChild(_iconList[i]); 
				_iconList[i].destroy(); 
				_iconList[i] = null; 
			} 
			_iconList = null; 
			super.destroy(); 
		} 
		
		/** 
		* Initializes pieces contained in box (position and visible status) 
		*/ 
		override public function init():void {  
			//Apply default init piece method to all pieces
			for (var i:uint = 0; i < _members.length; i++) { 
				(_members[i] as Piece).init(); 
			} 
 					
			_srcId = new Vector.<int>(_numBodyParts);
			for (var i:uint = 0; i < _numBodyParts; i++)
				_srcId[i] = -1;
			_idxSelObjectType = -1;
			onChangeInBoxPieces(0);
				
			super.init();        //Move on active state 
		} 
 
		/** 
		 * Exit function called when moving from STS_DYING to STS_DEAD, or directly from gamestate exit func 
		 * Closed and consolidate logic data 
		 */ 
		override public function exit():void { 
		}   		

		
		 /** 
		 * Define de initial positions for BodyParts objects (5 objects)
		 * To be executed once in the creation of the Box 
		 */ 
		private function setSrcPosList():void {   
			_srclist = new Vector.<Point>(_numBodyParts);       			
			//var iniy:uint = (Registry.appUpOffset > 20)? Registry.appUpOffset+32:52; 
			var iniy:uint = Registry.appUpOffset + 64 ; 
			for(var i:uint = 0; i< _numBodyParts; i++){ 
				_srclist[i] = new Point(); 
				_srclist[i].x = (uint)(8); 
				//_srclist[i].y = (uint)(iniy + 6 + i * Assets.IMG_ICON_BODYPART_HEIGHT + (i - 1) * 6);   
				_srclist[i].y = (uint)(iniy + i * Assets.IMG_ICON_BODYPART_HEIGHT);   
				_srclist[i].offset((uint)(Assets.IMG_ICON_BODYPART_WIDTH * 0.5), (uint)(Assets.IMG_ICON_BODYPART_HEIGHT*0.5)); //adjust to center reg point
			} 			
		}                 
		
		

		/*-------------------------------------------------------------------------- Getters / Setters */ 

		public function retrieveByCategoryIndex(inCat: uint, inIdxInCat: uint):Piece1 { 
			for (var i:uint = 0; i < _members.length; i++) { 
				if ((_members[i] as Piece1).category == inCat && (_members[i] as Piece1).idxInCat == inIdxInCat) 
					return (_members[i] as Piece1);                                 
			} 
			return null;                     
		} 
		
		/*-------------------------------------------------------------------------- Piece operations */

		/**
		 * Add piece to Box, setting in box if there its category is not in box
		 * @param	piece	Piece to put in box
		 */
		override public function setPieceInBox(piece: Piece):void {
			super.setPieceInBox(piece);	//adds to Box if piece comes from outside (puzzle)
	
			var idx:uint = (Piece1)(piece).idxInCat;
	_iconList[idx].visible = false;		//test, y check gfx (void) disappears
			
			setPieceInBoxPos(piece, (Piece1)(piece).idxInCat); 
		}
		
		/**
		 * Set a piece in Box in a given position
		 * @param	piece	Piece to put in box
		 * @param	idx		In-Box idx position to put the piece
		 */
		private function setPieceInBoxPos(piece: Piece, idx: uint):void { 
			_srcId[idx] = piece.id; 
			piece.playAnimation("InBoxEnabled"); 			
			piece.updPutInBox(); 
			piece.setSrcPos(_srclist[idx]); 
		} 

		
		/**
		 * Remove piece from in-box and replace it by one with the same category from out-box (if any exist)
		 * @param	piece
		 */
		override public function removePieceFromBox(piece: Piece): void { 
			super.removePieceFromBox(piece);	//remove the piece from the group		
                        
			var idx:uint = (Piece1)(piece).idxInCat;                 
			_srcId[idx] = -1; 
			showIconMissing(idx, piece.category); //Mostrar icono missing 
 		} 
		
		/*-------------------------------------------------------------------- BodyParts operations */ 
		
		private function showIconMissing(InIdx:uint, InObjType: uint):void { 
			var f:uint = InObjType; //obtener nº frame de la anim 1 "iconMissing" para el InObjType; //frame entre 0..4 => frame=selCat 
			_iconList[InIdx].playAnimation("iconMissing", false, f); //start anim in the correct frame 
			//_iconList[InIdx].pauseAnimation(); //and pause it 
			_iconList[InIdx].visible = true; 
		} 

		private function showIconDisabled(InIdx:uint, InObjType: uint):void {                 
			var f:uint = InObjType; //obtener nº frame de la anim 2 "iconDisabled" para el InObjType; //frame entre 0..4 => frame=selCat 
			_iconList[InIdx].playAnimation("iconDisabled", false, f); //start anim in the correct frame 
			//_iconList[InIdx].pauseAnimation(); //and pause it                 
			_iconList[InIdx].visible = true; 
		} 
			
		/**
		 * Move pieces in-box to out-box and hide bodypart icons 
		 */
		private function hidePiecesInBox():void {
			//New version (supporting type object "Random")                         
			for (var i:uint = 0; i < _numBodyParts; i++) { 
					_iconList[i].visible = false;        //hide icon 
					_srcId[i] = -1;  //reset bodypart piece reference                                 
			} 
			//move to out box all pieces from the current category 
			for each(var piece:Piece1 in _members) { 
					//if (piece.category == _idxSelObjectType) 
							piece.updPutOutBox();                                 
			} 			
		}
		
		
		
		/**
		 * Show the pieces with the selected type (category) in In-Box positions
		 * @param	tObj	Object Type 
		 */
		private function showPiecesInBox(InObjType: uint):void {			
			//Move to in-box the pieces belonging to the selected type of object
			for each(var piece:Piece1 in _members) {
				if (piece.category == InObjType) {
					setPieceInBoxPos(piece, piece.idxInCat);
				}					
			}
     
			//show BodyParts icons (with void gfx, if original piece is now put in the puzzle) 
			for (var i:uint = 0; i < _numBodyParts; i++){ 
				if (_srcId[i] == -1) 
						showIconMissing(i, InObjType);                                         
				//else                                                                //ocultar si icon enabled no se usa 
				//        showIconEnabled(i, InObjType);        //ocultar si icon enabled no se usa 
			}        			

		}
				
		//------------------------------------------------------------------- Callbacks                    	             		
				
		/**
		 * Event called when a new Object Type is selected in Level 1
		 * @param	tObj
		 */
		private function onChangeInBoxPieces(InObjType: uint):void { 
			trace("InBox pieces - TObj: " + InObjType);
			
			//return when trying to hide/how current Object type bodyparts 
			if(InObjType == _idxSelObjectType && InObjType != _numObjectTypes) 
				return; 

			hidePiecesInBox(); //Hide pieces in in-box		
			if(InObjType < _numObjectTypes) 
				showPiecesInBox(InObjType);//Show Pieces with <tOBj> category 
			_idxSelObjectType = InObjType; 
		}
		
		/**
		 * Event called when an in-box piece is selected and starts drag&drop operation 
		 * @param	InPiece
		 */		
		public function onBodyPartSelect(InPiece: Piece1):void { 
			showIconDisabled(InPiece.idxInCat, InPiece.category); 
		} 

		/**
		 * Event called when an in-box piece is returned to its source inbox position 
		 * @param	InPiece
		 */
		public function onBodyPartRestore(InPiece: Piece1):void { 
			//showIconEnabled(InPiece.idxInCat, InPiece.category); 
			_iconList[InPiece.idxInCat].visible = false; 
		} 
                
		
		
		
		/** 
		 * Update group sprites execution: call each sprite update() method, and chk exit group condition 
		 */                 
/*		override public function update():void { 
			super.update();  ///std behavior: para cada sprite de _members llama a update() 
		} 		
	*/
	}

}