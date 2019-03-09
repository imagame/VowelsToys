package com.imagame.engine 
{
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	/**
	 * Imagame engine Log
	 * @author imagame
	 */
	public class ImaLog extends Sprite
	{
		private var xml:XML;
		private var theText:TextField;
		
		public function ImaLog() 
		{
			xml =
			<xml>
			<sectionTitle>AIR</sectionTitle>			
			<sectionLabel>RTv: </sectionLabel>
			<runTimeVersion>-</runTimeVersion>
			<sectionLabel>RTpl: </sectionLabel>
			<runTimePatchLevel>-</runTimePatchLevel>
			<sectionTitle>DEVICE</sectionTitle>
			<sectionLabel>ScrRect: </sectionLabel>
			<screenRect>-</screenRect>
			<sectionLabel>DevRect: </sectionLabel>
			<deviceRect>-</deviceRect>
			<sectionTitle>GAME PROPS</sectionTitle>
			<sectionLabel>Fx: </sectionLabel>
			<fx>-</fx>
			<sectionLabel>Tween: </sectionLabel>
			<tween>-</tween>			

			</xml>;
			
			var style:StyleSheet = new StyleSheet();
			style.setStyle("xml",{fontSize:"9px",fontFamily:"arial"});
			style.setStyle("sectionTitle", { color:"#FFAA00" } );
			style.setStyle("sectionLabel",{color:"#CCCCCC",display:"inline"});
			style.setStyle("runTimeVersion",{color:"#FFFFFF"});
			style.setStyle("runTimePatchLevel",{color:"#FFFFFF"});
			style.setStyle("screenRect", { color:"#FFFFFF" } );
			style.setStyle("deviceRect", { color:"#FFFFFF" } );
			style.setStyle("fx", { color:"#FFFFFF" } );
			style.setStyle("tween", { color:"#FFFFFF" } );

			theText = new TextField();
			theText.alpha=0.8;
			theText.autoSize=TextFieldAutoSize.LEFT;
			theText.styleSheet=style;
			theText.condenseWhite=true;
			theText.selectable=false;
			theText.mouseEnabled=false;
			theText.background=true;
			theText.backgroundColor=0x000000;
			addChild(theText);
			addEventListener(Event.ENTER_FRAME, update);			
		}
		
		private function update(e:Event):void {
			xml.runTimeVersion = NativeApplication.nativeApplication.runtimeVersion;
			xml.runTimePatchLevel = NativeApplication.nativeApplication.runtimePatchLevel;
			
			xml.screenRect = Registry.gameRect.toString();
			xml.deviceRect = Registry.deviceRect.toString();
			xml.fx = Registry.bFx;
			xml.tween = Registry.bTween;
			theText.htmlText=xml;	
		}
		
	}

}