package com.imagame.fx 
{
	
	/**
	 * Interface for ImaFx classes
	 * @author imagame
	 */
	public interface IImaFX 
	{
		/**
		 * Starts/Resumes the FX, adding a bitmap to each sprite children
		 * @param	bStart	True to start from the beginning, Falst to resume after being pause
		 */
		function startFx(bStart: Boolean = false):void; 
		
		/**
		 * Stops/Pauses the fX, deleting bitmaps from each sprite children
		 * @param	bStop	True stops the Fx and destroys sprite children, and False pauses the Fx (to resume -or reuse- later)
		 * @param	bVisible	True to keep it visible after pausing/stoping, False to hide it
		 */		
		function stopFx(bPause: Boolean = true, bVisible: Boolean = false):void;
	}
	
}//TODO: Que stop siempre sea una pausa, y que start de la opción de reanudar (si había pausa previa) o empezar de 0