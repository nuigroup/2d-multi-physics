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

package General {

import Box2D.Dynamics.*
import Box2D.Dynamics.Joints.*
import Box2D.Dynamics.Contacts.*
import Box2D.Collision.*
import Box2D.Collision.Shapes.*
import Box2D.Common.Math.*
import General.*
import TestBed.*;
import flash.display.*;
import flash.text.*;
import flash.events.*;

	public class Main extends Sprite {
		
		public function Main() {

// Tuio communication init (Flosc)			

			stage.frameRate=30;
			stage.quality="BEST";
			stage.scaleMode="noScale";
			stage.align = "TL"; 
			TUIO.init(stage, 'localhost', 3000, '', true);			

			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
			
			m_fpsCounter.x = 7;
			m_fpsCounter.y = 5;
			addChildAt(m_fpsCounter, 0);
			
			m_sprite = new Sprite();
			addChild(m_sprite);
			
// Basic control interface - input
			
			m_input = new Input(m_sprite);	
			
// Instructions text
			
			var instructions_text:TextField = new TextField();
			var instructions_text_format:TextFormat = new TextFormat("Arial", 9, 0xffffff, false, false, false);
			instructions_text_format.align = TextFormatAlign.RIGHT;
			instructions_text.defaultTextFormat = instructions_text_format
			instructions_text.x = 138
			instructions_text.y = 8
			instructions_text.width = 495
			instructions_text.height = 61
			instructions_text.text = "'Left'/'Right' arrows to go to previous/next scene \n'R' to reset current scene"
			instructions_text.mouseEnabled = false;
			addChild(instructions_text);
			
// Scene name - textfield
			
			m_aboutText = new TextField();
			var m_aboutTextFormat:TextFormat = new TextFormat("Arial", 16, 0x00CCFF, true, false, false);
			m_aboutTextFormat.align = TextFormatAlign.RIGHT;
			m_aboutText.defaultTextFormat = m_aboutTextFormat
			m_aboutText.x = 334
			m_aboutText.y = 35
			m_aboutText.width = 300
			m_aboutText.height = 30
			m_aboutText.mouseEnabled = false;
			addChild(m_aboutText);

			var key:Sprite = new Sprite();
            addChild(key); 
			key.addEventListener(MouseEvent.MOUSE_DOWN, onSpritePress);//detect which press is made 
			
		}
		
        private function onSpritePress(event:MouseEvent):void {
            trace("mouse down");
			//want to be able to control each sprite separatley

        } 		
		
		public function update(e:Event):void {
			
// clear for rendering

			m_sprite.graphics.clear()

// toggle between scenes

			if (Input.isKeyPressed(39)){ // Right Arrow
				m_currId++;
				m_currTest = null;
			}
			else if (Input.isKeyPressed(37)){ // Left Arrow
				m_currId--;
				m_currTest = null
			}
			
// Reset scene

			else if (Input.isKeyPressed(82)){ // R
				m_currTest = null
				}
			
// if null, set new scene

			if (!m_currTest){
				switch(0){
					
		// TestBridge
					case 0:
						m_currTest = new TestBridge();
						break;
		// TestBridge
					case 1:
						m_currTest = new TestBridge();
						break;
		// TestBridge
					case 2:
						m_currTest = new TestBridge();
						break;
		// Wrap around
					default:
						if (m_currId < 0){
							m_currId = 0;
							m_currTest = new TestBridge();
						}
						else{
							m_currId = 0;
							m_currTest = new TestBridge();
						}
						break;
				}
			}
			
// update current scene

			m_currTest.Update();
			
// Update input (last)

			Input.update();
			
// update counter and limit framerate

			m_fpsCounter.update();
			FRateLimiter.limitFrame(30);
			
			}
		
		
//======================
// Member data
//======================

		static public var m_fpsCounter:FpsCounter = new FpsCounter();
		public var m_currId:int = 0;
		public var m_currTest:Test;
		static public var m_sprite:Sprite;
		static public var m_aboutText:TextField;
		
// input
		
		public var m_input:Input;
	}
}