package com.imagame.fx 
{
	import com.greensock.data.TweenLiteVars;
	import com.greensock.TweenLite;
	import com.imagame.engine.ImaSprite;
	import flash.display.Graphics;
	import flash.geom.Point;
	/**
	 * Graphics FX Utilities
	 * @author imagame
	 */
	public class ImaFx 
	{
		private static var _idTween: TweenLite = null;
		
		public static function imaFxZoomIn(objParent: Object, spr: ImaSprite, zoom: Number, t: Number, back: Boolean, endCB: Function):void{ 
			var srcX:int = spr.x; 
			var srcY:int = spr.y; 
			
			var dstX:int = srcX - (((spr.width * zoom)- spr.width)*0.5); 
			var dstY:int = srcY - (((spr.height * zoom)- spr.height)*0.5); 
			
			TweenLite.to(spr, t, { x:dstX, y:dstY, alpha:1, scaleX:zoom, scaleY:zoom, 
			//onComplete: function() { if (back) { spr.alpha = 1; spr.scaleX = 1; spr.scaleY = 1; spr.x = srcX; spr.y = srcY; } if (endCB) { endCB(); }}} );                 
			//onComplete: function() { if (back) imaFxZoomInBack(objParent, spr, 1, t, srcX, srcY, endCB) else endCB }} );       
			
			onComplete: function(){if (back) TweenLite.to(spr, t, { x:srcX, y:srcY, alpha:1, scaleX:1, scaleY:1, onComplete: endCB} ) else endCB}} );      
		} 			
	
		
		
		public static function imaFxZoomOut(objParent: Object, spr: ImaSprite, zoom: uint, t: Number, back: Boolean, endCB: Function):void{ 
			var dstX:int = spr.x; 
			var dstY:int = spr.y; 
			spr.x -= (((spr.width * zoom)- spr.width)*0.5); 
			spr.y -= (((spr.height * zoom)- spr.height)*0.5); 
			spr.alpha = 0;
			spr.scaleX = zoom;
			spr.scaleY = zoom;
			var it: TweenLite = TweenLite.to(spr, t, { x:dstX, y:dstY, alpha:1, scaleX:1, scaleY:1, onComplete: function() { if (endCB) { endCB(); } unregisterFx(_idTween) }} );                 
			registerFx(objParent, spr, it);
		}
	
		
		public static function registerFx(ObjParent: Object, target: Object, idTween: TweenLite):void {
			_idTween = idTween;
		}
		
		public static function unregisterFx(idTween: TweenLite):void {
			//idTween.kill();
			_idTween = null;
		}
		
		public static function getIdTween(objParent: Object):TweenLite {
			return _idTween;
		}
		
		
		/**
		 * Draw a segment of a circle
		 * @param graphics      the graphics object to draw into
		 * @param center        the center of the circle
		 * @param start         start angle (radians)
		 * @param end           end angle (radians)
		 * @param r             radius of the circle
		 * @param h_ratio       horizontal scaling factor
		 * @param v_ratio       vertical scaling factor
		 * @param new_drawing   if true, uses a moveTo call to start drawing at the start point of the circle; else continues drawing using only lineTo and curveTo
		 * 
		 */
		public static function drawCircleSegment(graphics:Graphics, center:Point, start:Number, end:Number, r:Number, h_ratio:Number=1, v_ratio:Number=1, new_drawing:Boolean=true):void
		{
			var x:Number = center.x;
			var y:Number = center.y;
			// first point of the circle segment
			if(new_drawing)
			{
				graphics.moveTo(x+Math.cos(start)*r*h_ratio, y+Math.sin(start)*r*v_ratio);
			}

			// draw the circle in segments
			var segments:uint = 8;

			var theta:Number = (end-start)/segments; 
			var angle:Number = start; // start drawing at angle ...

			var ctrlRadius:Number = r/Math.cos(theta/2); // this gets the radius of the control point
			for (var i:int = 0; i<segments; i++) {
				 // increment the angle
				 angle += theta;
				 var angleMid:Number = angle-(theta/2);
				 // calculate our control point
				 var cx:Number = x+Math.cos(angleMid)*(ctrlRadius*h_ratio);
				 var cy:Number = y+Math.sin(angleMid)*(ctrlRadius*v_ratio);
				 // calculate our end point
				 var px:Number = x+Math.cos(angle)*r*h_ratio;
				 var py:Number = y+Math.sin(angle)*r*v_ratio;
				 // draw the circle segment
				 graphics.curveTo(cx, cy, px, py);
			}
		}	

		
		/**
		 * Alternativa con lineTo 
		 * @param	progress	Value between 0 and 1 (0: not started, 1: finished)
		 */
		/*
		protected function paintPieceSelected2(progress: Number):void {
			var startAngle:Number = 0; // Math.round(ImaUtils.randomize( -90, -45)) / 360; //.0; // to start it at 12 o'clock	
			var currentAngle:Number;
			var arcAngle:Number = progress; // ImaUtils.toRadians(50); // Math.PI / 4; // Math.abs (startAngle * 2);
			var steps:Number = 24; // Math.floor ((arcAngle * 360) / 4);  // resolution of arc				
			var angleStep:Number = arcAngle / steps;		
			
			var inRadius:Number = 32;
			var centerX:Number = 0; // _sprSelected.x;
			var centerY:Number = 0; // _sprSelected.y;		
			var segmentX:Number = centerX + Math.cos(startAngle * TWOPI) * inRadius;
			var segmentY:Number = centerY + Math.sin(startAngle * TWOPI) * inRadius;
			
			_sprSelected.graphics.moveTo(segmentX, segmentY);
			_sprSelected.graphics.lineStyle(8, 0xffff25, 1, false, LineScaleMode.NORMAL, CapsStyle.ROUND, JointStyle.BEVEL);

			for(var i=1; i <= steps; i++)
			{
				currentAngle = startAngle + i * angleStep;

				segmentX = centerX + Math.cos(currentAngle * TWOPI) * inRadius;
				segmentY = centerY + Math.sin(currentAngle * TWOPI) * inRadius;
				
				_sprSelected.graphics.lineTo(segmentX, segmentY);
			}
						
		}
		*/
	}
}