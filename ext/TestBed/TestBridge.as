/*
* Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/

package TestBed {
	
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	import General.*;
	
	public class TestBridge extends Test {
//
//		public var _blobID:int;
//		public var _blobX:int;
//		public var _blobY:int;
//		
//		private function objectDrag(e:TouchEvent){
//			
//			var e2:Event = new Event("dragEvent",true);
//			this._blobID=e.ID;
//			this._blobX=e.stageX;
//			this._blobY=e.stageY;
//			
//			dispatchEvent(e2);
//			
//			e.stopPropagation();
//			}

		
		public function TestBridge(){
			
// Set Scene name textfield

			General.Main.m_aboutText.text = "The big circle";			
			
			var ground:b2Body = m_world.GetGroundBody();
			var i:int;
			var anchor:b2Vec2 = new b2Vec2();
			var body:b2Body;

// Big circle
				
			var bodyDefC:b2BodyDef = new b2BodyDef();
			var circDef:b2CircleDef = new b2CircleDef();
			circDef.density = 1.0;
			circDef.radius = (60) / m_physScale;
			
// Override the default friction

			circDef.friction = 0.3;
			circDef.restitution = 0.1;
			bodyDefC.position.Set((Math.random() * 400 + 120) / m_physScale, (Math.random() * 150 + 50) / m_physScale);
			bodyDefC.angle = Math.random() * Math.PI;
			
			// bodyDefC.addEventListener(Event.ENTER_FRAME, update);
			// addEventListener(TouchEvent.MOUSE_DOWN, objectDrag);
			// addEventListener(Event.ENTER_FRAME,contactUpdate);

			body = m_world.CreateBody(bodyDefC);
			body.CreateShape(circDef);
			body.SetMassFromShapes();
			
			// General.Main.m_aboutText.addEventListener(TouchEvent.MOUSE_DOWN, flash.events.TUIO.objectDrag);
			
		}
	}
}