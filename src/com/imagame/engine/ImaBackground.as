package com.imagame.engine 
{
	import com.imagame.game.Assets;
	import com.imagame.utils.ImaCachedBitmap;
	import flash.geom.Rectangle;
	
	import flash.display.Bitmap;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.GradientType;

	import flash.geom.Matrix;	
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	
	
	/**
	 * Creates a background images that covers the full screen resolution (Registry.screenRect)
	 * @author imagame
	 */
	public class ImaBackground extends Sprite 
	{	
		protected var _bmpBkg: Bitmap;
		
		/**
		 * 
		 * @param	idBkg		Background idx on Assets.bkgImages[]
		 * @param	idBkgExtW	idx bkg for horizontal background extensions. 0 for use idBkg
		 * @param	idBkgExtH	idx bkg for vertical background extensions. 0 for use idBkg
		 */
		public function ImaBackground(idBkg: uint, idBkgExtW: uint = 0, idBkgExtH: uint = 0) 
		{
			trace("IMABACKGROUND >> idBkg:" + idBkg + " extW: "+idBkgExtW+ " extH: "+idBkgExtH);
			//dynamic creation of the bitmap class
			var classReference:Class = getDefinitionByName(getQualifiedClassName(Assets.bkgImages[idBkg])) as Class;
			var bmp: Bitmap = ImaCachedBitmap.instance.createBitmap(classReference);
			
			//STEP 1: background image
			trace("Registry.gameRect: " + Registry.gameRect.toString());
			trace("Registry.appLeftOffset: " + Registry.appLeftOffset);
			trace("Registry.appUpOffset: " + Registry.appUpOffset);
			//1.- crear bmd que cubra todo el stage, y dibujar bmp escalado con baseScale en baseOffsetX, baseOffsetY
			var bmd:BitmapData = new BitmapData(Registry.gameRect.width, Registry.gameRect.height, true, 0x00000000);
			var matrix:Matrix = new Matrix();
			matrix.translate(Registry.appLeftOffset, Registry.appUpOffset);
			bmd.draw(bmp, matrix);

			//2.- replicate bkg img to cover all the device screen
			if (Registry.appLeftOffset > 0) { //screen device wider than default game rect
				if (idBkgExtW > 0 )  //if extension Bmp is differente than bkg bmp
					classReference = getDefinitionByName(getQualifiedClassName(Assets.bkgImages[idBkgExtW])) as Class;		
				var bmpExt: Bitmap = ImaCachedBitmap.instance.createBitmap(classReference);
				
				matrix.identity();
				matrix.translate(-bmpExt.width + Registry.appLeftOffset, 0);
				bmd.draw(bmpExt, matrix); //repeat background img in the left blank area
				matrix.translate(bmpExt.width * 2, 0);
				bmd.draw(bmpExt, matrix); //repeat background img in the right blank area 
			}
			else if (Registry.appUpOffset > 0) { //screen device taller than default game rect
				if (idBkgExtH > 0)
					classReference = getDefinitionByName(getQualifiedClassName(Assets.bkgImages[idBkgExtH])) as Class;
				var bmpExt: Bitmap = ImaCachedBitmap.instance.createBitmap(classReference);				
				
				matrix.identity();
				//paint bkg in the up and down blank areas
				matrix.translate(0,-bmpExt.height + Registry.appUpOffset);
				bmd.draw(bmpExt, matrix); //repeat background img in the top blank area
				matrix.translate(0, bmpExt.height * 2);
				bmd.draw(bmpExt, matrix); //repeat background img in the down blank area 					
			}
			
			_bmpBkg = new Bitmap(bmd);
			//addChild(_bmpBkg);	//DUDA: Se pierde el fondo quedándose negro, solo con la 1ra imagen
			addChild(new Bitmap(bmd));
			
			
			matrix = null;
			bmd = null;
			
/*			//Op1: create background image than covers full screen
			var imgFondo:Bitmap = new GfxBkgImg();
			addChild(imgFondo);
			
			imgFondo.scaleX = imgFondo.scaleY = Registry.appScale;
			imgFondo.x = (Registry.screenRect.width - imgFondo.width) * 0.5; //imgFondo.x = Registry.appLeftOffset;
			imgFondo.y = (Registry.screenRect.height - imgFondo.height) * 0.5;
			//Op2: create background tiled images to cover full screen
			//TODO
			
			//if (Registry.appLeftOffset > 0)
			//	if(Reg
*/			
			
			//STEP 2: Gradient

			//Variables (Lineal vertical)
/*			var bgcolor1:uint = 0xFF0000;
			var bgcolor2:uint = 0x000000;
			var fType:String = GradientType.LINEAR; //Type of Gradient we will be using
			var colors:Array = [ bgcolor1, bgcolor2]; //Colors of our gradient in the form of an array
			var alphas:Array = [ 0, 0.9 ];//Store the Alpha Values in the form of an array
			var ratios:Array = [ 0, 255 ]; //Array of color distribution ratios. (The value defines percentage of the width where the color is sampled at 100%)
			var matr:Matrix = new Matrix(); //Create a Matrix instance and assign the Gradient Box
			matr.createGradientBox( Registry.screenRect.width, Registry.screenRect.height, (180+90)*(Math.PI/180), 0, 0 );
			var sprMethod:String = SpreadMethod.PAD; //SpreadMethod will define how the gradient is spread. Note!!! Flash uses CONSTANTS to represent String literals
*/	
			
/*
			//Variables (Radial)
			var bgcolor1:uint = 0x0000ff;
			var bgcolor2:uint = 0x000000;
			var fType:String = GradientType.RADIAL; //Type of Gradient we will be using
			var colors:Array = [ bgcolor1, bgcolor2]; //Colors of our gradient in the form of an array
			var alphas:Array = [ 0, 0.7 ];//Store the Alpha Values in the form of an array
			var ratios:Array = [ 0, 255 ]; //Array of color distribution ratios. (The value defines percentage of the width where the color is sampled at 100%)
			var matr:Matrix = new Matrix(); //Create a Matrix instance and assign the Gradient Box
			matr.createGradientBox( Registry.gameRect.width + 0.4*Registry.gameRect.width, Registry.gameRect.height, 0, -0.2*Registry.gameRect.width, -48 );
			//matr.createGradientBox( Registry.screenRect.width, Registry.screenRect.height, 0, 0, -48 );
			var sprMethod:String = SpreadMethod.PAD; //SpreadMethod will define how the gradient is spread. Note!!! Flash uses CONSTANTS to represent String literals
			
			
			//Gradient creation
			var shape:Shape = new Shape();
			var g:Graphics = shape.graphics; //Save typing + increase performance through local reference to a Graphics object
			//g.clear();
			g.beginGradientFill( fType, colors, alphas, ratios, matr, sprMethod );
			g.drawRect( 0, 0, Registry.gameRect.width, Registry.gameRect.height );
			g.endFill();
			addChild( shape );			
	*/		
			
			
			
			/* 2A VERSION GRADIENT
			 
			var background:BitmapData = new BitmapData(480, 320, true, 0x00ffffff); //alpha 00:transp
			var mat:Matrix = new Matrix();
			var drawer:Shape = new Shape;
			var g:Graphics = drawer.graphics;
			var bgangle:Number = -90
			var bgcolor1:uint = 0xffffff;
			var bgcolor2:uint = 0x0000000;		
		
			//Draw gradient rect 
			mat.createGradientBox(480, 320, (bgangle+90)*0.017453292519943295, 0, 0);
			g.clear();
			g.beginGradientFill(GradientType.LINEAR, [bgcolor1, bgcolor2], [0,0.8], [0,255], mat);
			g.drawRect(0, 0, 480, 320);
			g.endFill();
			background.draw(drawer);
        
			
			//Draw lines
			g.lineStyle(2, 0, 0.125);
			for (var i:int=0; i<=480; i+=32) {
				g.moveTo(0,i);
				g.lineTo(480,i);
				g.moveTo(i,0);
				g.lineTo(i,320);
			}
			background.draw(drawer);
			
						
			addChild(new Bitmap(background));	     
			
			*/
		}
		
		public function destroy():void { 
			_bmpBkg.bitmapData.dispose();
			_bmpBkg.bitmapData = null; 
			_bmpBkg = null; 
		} 
				
		public function getImg(rect: Rectangle=null): Bitmap { 
			if (rect == null)
				rect = Registry.gameRect;
			return ImaCachedBitmap.instance.createBitmapFromSheetDirect(_bmpBkg, rect.left, rect.top, rect.width, rect.height); 
		} 
		
	}

}