//===========================================================
//=========================================================//
//						-=ANTHEM=-
//	file: frameLimiter.as
//
//	copyright: Matthew Bush 2007
//
//	notes: limits framerate
//
//=========================================================//
//===========================================================



//===========================================================
// frame limiter
//===========================================================

package app
{
	
	import flash.utils.getTimer;
	import app.core.action.*; 

	
	public class FRateLimiter // extends Multitouchable
	{
//======================
// limit frame function
//======================
		static public function limitFrame(maxFPS:uint):void
		{
			var fTime:uint = 1000 / maxFPS;
			
			while(Math.abs(newT - oldT) < fTime){
				newT = getTimer();
			}
			oldT = getTimer();
		}
		
//======================
// member vars
//======================
		private static var oldT:uint = getTimer();
		private static var newT:uint = oldT;
	}
}