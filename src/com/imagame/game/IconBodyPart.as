package com.imagame.game 
{
	import com.imagame.engine.ImaSprite;
	import com.imagame.engine.ImaSpriteAnim;
	import com.imagame.utils.IImaBitmapSheet;
	
	/**
	 * BodyPart Icon to be shown in Box1 when a piece is not present (dragging or put in puzzle)
	 * @author imagame
	 */
	public class IconBodyPart extends ImaSpriteAnim 
	{
		
		public function IconBodyPart(id:uint, bs: IImaBitmapSheet, aGfx1: Array, aGfx2: Array) 
		{
			super(ImaSprite.TYPE_ICON, id);
			//2 anims with 5 frames each one				
			addAnimation("iconMissing", bs, null, aGfx1); //first anim with 5 frames for void body parts (1st body part of ecah Tobj)
			addAnimation("iconDisabled", bs, null, aGfx2); //second anim with 5 frames for disabled body parts
			
		}
		
	}

}