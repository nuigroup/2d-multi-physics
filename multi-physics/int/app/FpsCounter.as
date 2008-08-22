//===========================================================
//=========================================================//
//						-=ANTHEM=-
//	file: .as
//
//	copyright: Matthew Bush 2007
//
//	notes:
//
//=========================================================//
//===========================================================



//===========================================================
// FPS COUNTER CLASS
//===========================================================
package app
{
	
	import flash.display.Sprite;
	import flash.text.*;
	import flash.utils.getTimer;
	import flash.events.*;
	import flash.system.System;
	
	public class FpsCounter extends Sprite
	{
		
//======================
// constructor
//======================
		public function FpsCounter()
		{

			// create text field

			textBox = new TextField();
			var textBoxTextFormat:TextFormat = new TextFormat("Verdana", 10, 0xFFFFFF, true, false, false);
			textBoxTextFormat.align = TextFormatAlign.LEFT;
			textBox.defaultTextFormat = textBoxTextFormat
//			textBox.mouseEnabled = false;
			textBox.text = "...";
			textBox.selectable = false;
			
			textBox2 = new TextField();
			var textBox2TextFormat:TextFormat = new TextFormat("Verdana", 10, 0xFFFFFF, true, false, false);
			textBox2TextFormat.align = TextFormatAlign.LEFT;
			textBox2.defaultTextFormat = textBox2TextFormat
			textBox2.text = "...";
			textBox2.width = 200;
			textBox2.textColor = 0xffffff;
			textBox2.selectable = false;
			textBox2.y = 15;
			
			textBox3 = new TextField();
			var textBox3TextFormat:TextFormat = new TextFormat("Verdana", 10, 0xFFFFFF, true, false, false);
			textBox3TextFormat.align = TextFormatAlign.LEFT;
			textBox3.defaultTextFormat = textBox3TextFormat
			textBox3.text = "...";
			textBox3.textColor = 0xffffff;
			textBox3.selectable = false;
			textBox3.y = 30;
			
			// set initial lastTime
			oldT = getTimer();
			
			addChild(textBox);
			addChild(textBox2);
			addChild(textBox3);
		}
		
//======================
// update function
//======================
		public function update():void
		{
			var newT:uint = getTimer();
			var f1:uint = newT-oldT;
			mfpsCount += f1;
			if (avgCount < 1){
				textBox.text = String(Math.round(1000/(mfpsCount/30))+" fps average");
				avgCount = 30;
				mfpsCount = 0;
			}
			avgCount--;
			oldT = getTimer();
			
			textBox3.text = Math.round(System.totalMemory/(1024*1024)) + " MB used"
		}
		
		public function updatePhys(oldT2:uint):void
		{
			var newT:uint = getTimer();
			var f1:uint = newT-oldT2;
			mfpsCount2 += f1;
			if (avgCount2 < 1){
				textBox2.text = String("Physics step: "+Math.round(mfpsCount2/30)+" ms (" +Math.round(1000/(mfpsCount2/30))+" fps)");
				avgCount2 = 30;
				mfpsCount2 = 0;
			}
			avgCount2--;
		}
		
//======================
// updateESnd function
//======================
		public function updateEnd():void
		{
			// wrong
			/*var newT:uint = getTimer();
			var f1:uint = newT-oldT;
			mfpsCount2 += f1;
			if (avgCount2 < 1){
				textBox2.text = String(Math.round(1000/(mfpsCount2/30))+" fps uncapped");
				avgCount2 = 30;
				mfpsCount2 = 0;
			}
			avgCount2--;*/
		}
		
//======================
// private variables
//======================
		private var textBox:TextField;
		private var textBox2:TextField;
		private var textBox3:TextField;
		private var mfpsCount:int = 0;
		private var mfpsCount2:int = 0;
		private var avgCount:int = 30;
		private var avgCount2:int = 30;
		private var oldT:uint;
	}
}

// End of file
//===========================================================
//===========================================================