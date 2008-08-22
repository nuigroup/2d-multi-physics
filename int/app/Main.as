package app 
{
	import Box2D.Dynamics.*
	import Box2D.Dynamics.Joints.*
	import Box2D.Dynamics.Contacts.*
	import Box2D.Collision.*
	import Box2D.Collision.Shapes.*
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	
	import flash.display.*;
	import flash.filters.*;
	import flash.text.*;
	import flash.events.*;
	import flash.utils.getTimer
	
	import app.*
	import app.core.action.*; 
	// import app.simulations.*;

	public class Main extends Multitouchable
	{ 
			
//======================
// Member data
//======================
	// world's settings
		public var m_world:b2World;
		public var m_bomb:b2Body;
		public var m_mouseJoint:b2MouseJoint;
		public var m_iterations:int = 10;
		public var m_timeStep:Number = 1/30;
		public var m_physScale:Number = 30;
		
	// world mouse position
		private var mousePVec:b2Vec2 = new b2Vec2();

	// Sprite to draw in to
		public var m_sprite:Sprite;
		
		// public var m_currTest:TestCrankGearsPulley;
		
		protected var leftWall:b2Body = null;
		protected var topWall:b2Body = null;		
		protected var rightWall:b2Body = null;
		protected var bottomWall:b2Body = null;				
		
		protected var wallAreaWidth:int = 640;
		protected var wallAreaHeight:int = 480;
		
		static public var m_fpsCounter:FpsCounter = new FpsCounter();
		// public var m_currId:int = 0;
		// public var m_currTest:Sprite;
		static public var m_sprite:Sprite;
		static public var m_aboutText:TextField;

	// test scene's vars
		private var m_joint1:b2RevoluteJoint;
		private var m_joint2:b2PrismaticJoint;
		public var m_gJoint1:b2RevoluteJoint;
		public var m_gJoint2:b2RevoluteJoint;
		public var m_gJoint3:b2PrismaticJoint;
		public var m_gJoint4:b2GearJoint;
		public var m_gJoint5:b2GearJoint;
		
//======================
// Main
//======================
		public function Main()
		{
			// trace("Main - init");
			var inputFixSprite:Sprite = new Sprite();
			inputFixSprite.graphics.lineStyle(0,0,0);
			inputFixSprite.graphics.beginFill(0,0);
			inputFixSprite.graphics.moveTo(-10000, -10000);
			inputFixSprite.graphics.lineTo(10000, -10000);
			inputFixSprite.graphics.lineTo(10000, 10000);
			inputFixSprite.graphics.lineTo(-10000, 10000);
			inputFixSprite.graphics.endFill();
			addChild(inputFixSprite);
			addEventListener(Event.ENTER_FRAME, UpdateFrame, false, 0, true);
			var worldAABB:b2AABB = new b2AABB();
			worldAABB.lowerBound.Set(-2000.0, -2000.0);
			worldAABB.upperBound.Set(2000.0, 2000.0);

	// Define the gravity vector
			var gravity:b2Vec2 = new b2Vec2(0.0, 10.0);
			
	// Allow bodies to sleep
			var doSleep:Boolean = true;
			
	// Construct a world object
			m_world = new b2World(worldAABB, gravity, doSleep);
			var drawSprite:Sprite = new Sprite();
			addChild(drawSprite);					
			m_sprite = drawSprite;
			stage.frameRate=30;
			stage.quality="BEST";
			stage.scaleMode="noScale";
			stage.align = "TL"; 
			if(this.stage)
				addedToStage(new Event(Event.ADDED_TO_STAGE));
			else
				this.addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);

	// Tuio communication init. (Flosc)			
			TUIO.init(stage, 'localhost', 3000, '', true);			

	// set debug draw
			var dbgDraw:b2DebugDraw = new b2DebugDraw();
			
			//var dbgSprite:Sprite = new Sprite();
			//m_sprite.addChild(dbgSprite);
			dbgDraw.m_sprite = m_sprite;
			dbgDraw.m_drawScale = 30.0;
			dbgDraw.m_fillAlpha = 0.3;
			dbgDraw.m_lineThickness = 5.0;
			dbgDraw.m_drawFlags = b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit;
			m_world.SetDebugDraw(dbgDraw);

	// UI Elements init.
			setUiElements();
			
	// Test scene init.
			setGravity(0, 10);
			TestScene();
			// m_currTest = new TestCrankGearsPulley();
			// m_currTest.UpdateFrame();
			setWalls(stage.stageWidth, stage.stageHeight);
		}
		
//======================
// UpdateFrame
//======================
		public function UpdateFrame(e:Event):void 
		{

	// Clearing for rendering
			m_sprite.graphics.clear();

	// Update drag joint
			InputDrag();
			
	// Update physics
			var physStart:uint = getTimer();
			m_world.Step(m_timeStep, m_iterations);
			Main.m_fpsCounter.updatePhys(physStart);
			
	// Update counter and limit framerate
			m_fpsCounter.update();
			FRateLimiter.limitFrame(30);
		}
		
//======================
// TestScene
//======================
		public function TestScene()
		{
	// Set Scene name textfield
//			m_aboutText.text = "Test scene";			
//			var ground:b2Body = m_world.GetGroundBody();
//			var i:int;
//			var anchor:b2Vec2 = new b2Vec2();
//			var body:b2Body;
//			
//	// Big circle
//			var bodyDefC:b2BodyDef = new b2BodyDef();
//			var circDef:b2CircleDef = new b2CircleDef();
//			circDef.density = 1.0;
//			circDef.radius = (60) / m_physScale;
//			
//	// Override the default friction
//			circDef.friction = 0.3;
//			circDef.restitution = 0.1;
//			bodyDefC.position.Set((Math.random() * 400 + 120) / m_physScale, (Math.random() * 150 + 50) / m_physScale);
//			bodyDefC.angle = Math.random() * Math.PI;
//			body = m_world.CreateBody(bodyDefC);
//			body.CreateShape(circDef);
//			body.SetMassFromShapes();

		// Set Scene name textfield
			m_aboutText.text = "Crank/Gears/Pulley";
			var ground:b2Body = m_world.GetGroundBody();
			var body:b2Body;
			var sd:b2PolygonDef;
			var bd:b2BodyDef;
			
	//==============
	// CRANK
	//==============
	
		// Define crank.
				sd = new b2PolygonDef();
				sd.SetAsBox(7.5/m_physScale, 30.0/m_physScale);
				sd.density = 1.0;
				var rjd:b2RevoluteJointDef = new b2RevoluteJointDef();
				var prevBody:b2Body = ground;
				bd = new b2BodyDef();
				bd.position.Set(100.0/m_physScale, (360.0-105.0)/m_physScale);
				body = m_world.CreateBody(bd);
				body.CreateShape(sd);
				body.SetMassFromShapes();
				rjd.Initialize(prevBody, body, new b2Vec2(100.0/m_physScale, (360.0-75.0)/m_physScale));
				rjd.motorSpeed = 1.0 * -Math.PI;
				rjd.maxMotorTorque = 5000.0;
				rjd.enableMotor = true;
				m_joint1 = m_world.CreateJoint(rjd) as b2RevoluteJoint;
				prevBody = body;
				
		// Define follower.
				sd.SetAsBox(7.5/m_physScale, 60.0/m_physScale);
				bd.position.Set(100.0/m_physScale, (360.0-195.0)/m_physScale);
				body = m_world.CreateBody(bd);
				body.CreateShape(sd);
				body.SetMassFromShapes();
				rjd.Initialize(prevBody, body, new b2Vec2(100.0/m_physScale, (360.0-135.0)/m_physScale));
				rjd.enableMotor = false;
				m_world.CreateJoint(rjd);
				prevBody = body;
				
		// Define piston
				sd.SetAsBox(22.5/m_physScale, 22.5/m_physScale);
				bd.position.Set(100.0/m_physScale, (360.0-255.0)/m_physScale);
				body = m_world.CreateBody(bd);
				body.CreateShape(sd);
				body.SetMassFromShapes();
				rjd.Initialize(prevBody, body, new b2Vec2(100.0/m_physScale, (360.0-255.0)/m_physScale));
				m_world.CreateJoint(rjd);
				var pjd:b2PrismaticJointDef = new b2PrismaticJointDef();
				pjd.Initialize(ground, body, new b2Vec2(100.0/m_physScale, (360.0-255.0)/m_physScale), new b2Vec2(0.0, 1.0));
				pjd.maxMotorForce = 500.0;
				pjd.enableMotor = true;
				m_joint2 = m_world.CreateJoint(pjd) as b2PrismaticJoint;
				
		// Create a payload
				sd.density = 2.0;
				bd.position.Set(100.0/m_physScale, (360.0-345.0)/m_physScale);
				body = m_world.CreateBody(bd);
				body.CreateShape(sd);
				body.SetMassFromShapes();
				
	//==============
	// GEARS
	//==============
				var circle1:b2CircleDef = new b2CircleDef();
				circle1.radius = 25 / m_physScale;
				circle1.density = 5.0;
				var circle2:b2CircleDef = new b2CircleDef();
				circle2.radius = 50 / m_physScale;
				circle2.density = 5.0;
				var box:b2PolygonDef = new b2PolygonDef();
				box.SetAsBox(10 / m_physScale, 100 / m_physScale);
				box.density = 5.0;
				var bd1:b2BodyDef = new b2BodyDef();
				bd1.position.Set(200 / m_physScale, 360/2 / m_physScale);
				var body1:b2Body = m_world.CreateBody(bd1);
				body1.CreateShape(circle1);
				body1.SetMassFromShapes();
				var jd1:b2RevoluteJointDef = new b2RevoluteJointDef();
				jd1.Initialize(ground, body1, bd1.position);
				//jd1.anchorPoint.SetV(bd1.position);
				//jd1.body1 = ground;
				//jd1.body2 = body1;
				m_gJoint1 = m_world.CreateJoint(jd1) as b2RevoluteJoint;
				var bd2:b2BodyDef = new b2BodyDef();
				bd2.position.Set(275 / m_physScale, 360/2 / m_physScale);
				var body2:b2Body = m_world.CreateBody(bd2);
				body2.CreateShape(circle2);
				body2.SetMassFromShapes();
				var jd2:b2RevoluteJointDef = new b2RevoluteJointDef();
				jd2.Initialize(ground, body2, bd2.position);
				//jd2.body1 = ground;
				//jd2.body2 = body2;
				//jd2.anchorPoint.SetV(bd2.position);
				m_gJoint2 = m_world.CreateJoint(jd2) as b2RevoluteJoint;
				var bd3:b2BodyDef = new b2BodyDef();
				bd3.position.Set(335 / m_physScale, 360/2 / m_physScale);
				var body3:b2Body = m_world.CreateBody(bd3);
				body3.CreateShape(box);
				body3.SetMassFromShapes();
				var jd3:b2PrismaticJointDef = new b2PrismaticJointDef();
				jd3.Initialize(ground, body3, bd3.position, new b2Vec2(0,1));
				//jd3.body1 = ground;
				//jd3.body2 = body3;
				//jd3.anchorPoint.SetV(bd3.position);
				//jd3.axis.Set(0.0, 1.0);
				jd3.lowerTranslation = -25.0 / m_physScale;
				jd3.upperTranslation = 100.0 / m_physScale;
				jd3.enableLimit = true;
				m_gJoint3 = m_world.CreateJoint(jd3) as b2PrismaticJoint;
				var jd4:b2GearJointDef = new b2GearJointDef();
				jd4.body1 = body1;
				jd4.body2 = body2;
				jd4.joint1 = m_gJoint1;
				jd4.joint2 = m_gJoint2;
				jd4.ratio = circle2.radius / circle1.radius;
				m_gJoint4 = m_world.CreateJoint(jd4) as b2GearJoint;
				var jd5:b2GearJointDef = new b2GearJointDef();
				jd5.body1 = body2;
				jd5.body2 = body3;
				jd5.joint1 = m_gJoint2;
				jd5.joint2 = m_gJoint3;
				jd5.ratio = -1.0 / circle2.radius;
				m_gJoint5 = m_world.CreateJoint(jd5) as b2GearJoint;
				
	//==============
	// PULLEY
	//==============
				sd = new b2PolygonDef();
				sd.SetAsBox(50 / m_physScale, 20 / m_physScale);
				sd.density = 5.0;
				bd = new b2BodyDef();
				bd.position.Set(480 / m_physScale, 200 / m_physScale);
				body2 = m_world.CreateBody(bd);
				body2.CreateShape(sd);
				body2.SetMassFromShapes();
				var pulleyDef:b2PulleyJointDef = new b2PulleyJointDef();
				var anchor1:b2Vec2 = new b2Vec2(335 / m_physScale, 180 / m_physScale);
				var anchor2:b2Vec2 = new b2Vec2(480 / m_physScale, 180 / m_physScale);
				var groundAnchor1:b2Vec2 = new b2Vec2(335 / m_physScale, 50 / m_physScale);
				var groundAnchor2:b2Vec2 = new b2Vec2(480 / m_physScale, 50 / m_physScale);
				pulleyDef.Initialize(body3, body2, groundAnchor1, groundAnchor2, anchor1, anchor2, 2.0);
				pulleyDef.maxLength1 = 200 / m_physScale;
				pulleyDef.maxLength2 = 150 / m_physScale;
				//m_joint1 = m_world.CreateJoint(pulleyDef) as b2PulleyJoint;
				m_world.CreateJoint(pulleyDef) as b2PulleyJoint;
				
		// Add a circle to weigh down the pulley
				var circ:b2CircleDef = new b2CircleDef();
				circ.radius = 40 / m_physScale;
				circ.friction = 0.3;
				circ.restitution = 0.3;
				circ.density = 5.0;
				bd.position.Set(485 / m_physScale, 100 / m_physScale);
				body1 = m_world.CreateBody(bd);
				body1.CreateShape(circ);
				body1.SetMassFromShapes();
		}		

//======================
// setWalls
//======================
		public function setWalls(areaWidth:int, areaHeight:int)
		{
			wallAreaWidth = areaWidth;
			wallAreaHeight = areaHeight;
			
		// Remove existing walls
			if(bottomWall)
				m_world.DestroyBody(bottomWall);
			if(topWall)
				m_world.DestroyBody(topWall);			
			if(leftWall)
				m_world.DestroyBody(leftWall); 
			if(rightWall)
				m_world.DestroyBody(rightWall);			
				
		// Create new walls
			var wallSd:b2PolygonDef = new b2PolygonDef();
			var wallBd:b2BodyDef = new b2BodyDef();
			var wallB:b2Body;
		  // Left
			wallBd.position.Set(-148/m_physScale, areaHeight/m_physScale/2);
			wallSd.SetAsBox(150/m_physScale, areaHeight/m_physScale);
			leftWall = m_world.CreateBody(wallBd);
			leftWall.CreateShape(wallSd);
			leftWall.SetMassFromShapes();
		  // Right
			wallBd.position.Set((areaWidth+148)/m_physScale, areaHeight/m_physScale/2);
			rightWall = m_world.CreateBody(wallBd);
			rightWall.CreateShape(wallSd);
			rightWall.SetMassFromShapes();		
		  // Top
			wallBd.position.Set(areaWidth/m_physScale/2, -148/m_physScale);
			wallSd.SetAsBox(areaWidth/m_physScale, 150/m_physScale);
			topWall = m_world.CreateBody(wallBd);
			topWall.CreateShape(wallSd);
			topWall.SetMassFromShapes();
		  // Bottom
			wallBd.position.Set(areaWidth/m_physScale/2, (areaHeight+148)/m_physScale);
			bottomWall = m_world.CreateBody(wallBd);
			bottomWall.CreateShape(wallSd);
			bottomWall.SetMassFromShapes();
		}
		
//======================
// setGravity
//======================
		public function setGravity( xgrav:Number, ygrav:Number )
		{
			m_world.m_gravity = new b2Vec2(xgrav, ygrav);
		}
		
//======================
// addedToStage
//======================
		function addedToStage(e:Event)
		{
			// trace("AddedToStage");
			this.stage.addEventListener(Event.RESIZE, stageResized, false, 0, true);			
			stageResized(new Event(Event.RESIZE));			
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);			
		}
		
//======================
// stageResized
//======================
		function stageResized(e:Event)
		{			
			stage.align = StageAlign.TOP_LEFT;
			stage.displayState = StageDisplayState.FULL_SCREEN;			
			this.x = 0;
			this.y = 0;
			setUiElements();
			setWalls(stage.stageWidth, stage.stageHeight);
		}
		
//======================
// distributeUiElements
//======================
		function setUiElements()
		{			
						
	// Fps counter position
			m_fpsCounter.x = 7;
			m_fpsCounter.y = stage.stageHeight - 52;
			addChildAt(m_fpsCounter, 0);

	// Scene name - textfield
			if(m_aboutText)
				removeChild(m_aboutText);
			else 
				m_aboutText = new TextField();
			var m_aboutTextFormat:TextFormat = new TextFormat("Freestyle Script", 36, 0x00CCFF, true, false, false);
			m_aboutTextFormat.align = TextFormatAlign.RIGHT;
			m_aboutText.defaultTextFormat = m_aboutTextFormat;
			m_aboutText.x = (stage.stageWidth - 310);
			m_aboutText.y = 5;
			m_aboutText.width = 300;
			m_aboutText.height = 50;
			m_aboutText.mouseEnabled = false;
			addChild(m_aboutText);
			
	// DEBUG_TEXT position
		}
		
//======================
// destroyBody
//======================
		public function destroyBody(b:b2Body)
		{
			if(b.m_userData && b.m_userData.sprite)
			{
				removeChild(b.m_userData.sprite);
				b.m_userData.sprite = null;
			}
			m_world.DestroyBody(b);									
		}
		
//======================
// clearWorld
//======================		
		public function clearWorld()
		{
			for (var bb:b2Body = m_world.m_bodyList; bb; bb = bb.m_next){
				if (bb.m_userData && bb.m_userData.sprite is Sprite){
					removeChild(bb.m_userData.sprite);
				} 
			}						
			var worldAABB:b2AABB = new b2AABB();
			worldAABB.lowerBound.Set(-2000.0, -2000.0);
			worldAABB.upperBound.Set(2000.0, 2000.0);
			m_world = new b2World(worldAABB, m_world.m_gravity, true);
			setWalls(wallAreaWidth, wallAreaHeight);
		}		

//======================
// Input Drag 
//======================
		public function InputDrag():void
		{
			for(var i:int=0; i<blobs.length; i++)
			{
				if(blobs[i].m_Joint)
				{				
					var xworld:Number = blobs[i].x/m_physScale,
						yworld:Number = blobs[i].y/m_physScale;
					var p2:b2Vec2 = new b2Vec2(xworld, yworld);
					blobs[i].m_Joint.SetTarget(p2);
				} 
				else
				{
					physDragBlob(blobs[i].id, blobs[i].x, blobs[i].y);
				}
			}
		}		
		
//======================
// GetBodyAtPos
//======================
		public function GetBodyAtPos(xworld:Number, yworld:Number, includeStatic:Boolean=false):b2Body
		{
		// Make a small box.
			mousePVec.Set(xworld, yworld);
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(xworld - 0.02, yworld - 0.02);
			aabb.upperBound.Set(xworld + 0.02, yworld + 0.02);
						
		// Query the world for overlapping shapes.
			var k_maxCount:int = 10;
			var shapes:Array = new Array();
			var count:int = m_world.Query(aabb, shapes, k_maxCount);
			var body:b2Body = null;
			for (var i:int = 0; i < count; ++i)
			{
				if (shapes[i].m_body.IsStatic() == false || includeStatic)
				{
//					var inside:Boolean = shapes[i].TestPoint(mousePVec);
//					if (inside)
//					{
//						body = shapes[i].m_body;
//						break;
//					}
				}
				if (shapes[i].GetBody().IsStatic() == false || includeStatic)
				{
					var tShape:b2Shape = shapes[i] as b2Shape;
					var inside:Boolean = tShape.TestPoint(tShape.GetBody().GetXForm(), mousePVec);
					if (inside)
					{
						body = tShape.GetBody();
						break;
					}
				}
			}
			return body;
		}		
		
//======================
// physDragBlob
//======================
		public function physDragBlob(id:int, mx:Number, my:Number)
		{
			trace("Handle blob created " + id);
			var blobinfo = getBlobInfo(id);

			var xworld:Number = mx/m_physScale,
				yworld:Number = my/m_physScale;			
				
			var body:b2Body = GetBodyAtPos(xworld, yworld);
			
			if (body && !(body.m_userData && body.m_userData.grabbable == false))
			{
				var md:b2MouseJointDef = new b2MouseJointDef();
				md.body1 = m_world.m_groundBody;
				md.body2 = body;
				md.target.Set(xworld, yworld);
				md.maxForce = 20000.0 * body.m_mass;
				md.timeStep = m_timeStep;
				blobinfo.m_Joint = m_world.CreateJoint(md) as b2MouseJoint;
				body.WakeUp();
			}			
		}		

//======================
// handleBlobCreated
//======================		
		override public function handleBlobCreated(id:int, mx:Number, my:Number):void
		{
			physDragBlob(id, mx, my);
		}
		
//======================
// handleBlobRemoved
//======================		
		override public function handleBlobRemoved(id:int):void
		{
			trace("Handle blob removed");			
			var blobinfo = getBlobInfo(id);		
			if (blobinfo.m_Joint)
			{
				trace("Destroying joint");				
				m_world.DestroyJoint(blobinfo.m_Joint);
				blobinfo.m_Joint = null;
			}			
		}		
		
//======================
// Draw Pairs
//======================
		public function DrawPairs():void
		{
			var bp:b2BroadPhase = m_world.m_broadPhase;
			var invQ:b2Vec2 = new b2Vec2();
			invQ.Set(1.0 / bp.m_quantizationFactor.x, 1.0 / bp.m_quantizationFactor.y);
			for (var i:int = 0; i < bp.m_pairManager.m_pairCount; ++i)
			{
				var pair:b2Pair = bp.m_pairManager.m_pairs[ i ];
				var id1:uint = pair.proxyId1;
				var id2:uint = pair.proxyId2;
				var p1:b2Proxy = bp.m_proxyPool[ id1 ];
				var p2:b2Proxy = bp.m_proxyPool[ id2 ];
				var b1:b2AABB = new b2AABB();
				var b2:b2AABB = new b2AABB();
				b1.lowerBound.x = bp.m_worldAABB.lowerBound.x + invQ.x * bp.m_bounds[0][p1.lowerBounds[0]].value;
				b1.lowerBound.y = bp.m_worldAABB.lowerBound.y + invQ.y * bp.m_bounds[1][p1.lowerBounds[1]].value;
				b1.upperBound.x = bp.m_worldAABB.lowerBound.x + invQ.x * bp.m_bounds[0][p1.upperBounds[0]].value;
				b1.upperBound.y = bp.m_worldAABB.lowerBound.y + invQ.y * bp.m_bounds[1][p1.upperBounds[1]].value;
				b2.lowerBound.x = bp.m_worldAABB.lowerBound.x + invQ.x * bp.m_bounds[0][p2.lowerBounds[0]].value;
				b2.lowerBound.y = bp.m_worldAABB.lowerBound.y + invQ.y * bp.m_bounds[1][p2.lowerBounds[1]].value;
				b2.upperBound.x = bp.m_worldAABB.lowerBound.x + invQ.x * bp.m_bounds[0][p2.upperBounds[0]].value;
				b2.upperBound.y = bp.m_worldAABB.lowerBound.y + invQ.y * bp.m_bounds[1][p2.upperBounds[1]].value;
				var x1:b2Vec2 = b2Math.MulFV(0.5, b2Math.AddVV(b1.lowerBound, b1.upperBound) );
				var x2:b2Vec2 = b2Math.MulFV(0.5, b2Math.AddVV(b2.lowerBound, b2.upperBound) );
				m_sprite.graphics.lineStyle(1,0xff2222,1);
				m_sprite.graphics.moveTo(x1.x * m_physScale, x1.y * m_physScale);
				m_sprite.graphics.lineTo(x2.x * m_physScale, x2.y * m_physScale);
			}
		}
		
//======================
// Draw Contacts
//======================
		public function DrawContacts():void
		{
//			for (var c:b2Contact = m_world.m_contactList; c; c = c.m_next)
//			{
//				var ms:Array = c.GetManifolds();
//				for (var i:int = 0; i < c.GetManifoldCount(); ++i)
//				{
//					var m:b2Manifold = ms[ i ];
//					//this.graphics.lineStyle(3,0x11CCff,0.7);
//					for (var j:int = 0; j < m.pointCount; ++j)
//					{	
//						m_sprite.graphics.lineStyle(m.points[j].normalImpulse,0x11CCff,0.7);
//						var v:b2Vec2 = m.points[j].position;
//						m_sprite.graphics.moveTo(v.x * m_physScale, v.y * m_physScale);
//						m_sprite.graphics.lineTo(v.x * m_physScale, v.y * m_physScale);
//					}
//				}
//			}
		}
		
//======================
// Draw Shape 
//======================
		public function DrawShape(shape:b2Shape):void
		{
//			switch (shape.m_type)
//			{
//				case b2Shape.e_circleShape:
//				{
//					var circle:b2CircleShape = shape as b2CircleShape;
//					var pos:b2Vec2 = circle.m_position;
//					var r:Number = circle.m_radius;
//					var k_segments:Number = 16.0;
//					var k_increment:Number = 2.0 * Math.PI / k_segments;
//					m_sprite.graphics.lineStyle(1,0xffffff,1);
//					m_sprite.graphics.moveTo((pos.x + r) * m_physScale, (pos.y) * m_physScale);
//					var theta:Number = 0.0;
//					for (var i:int = 0; i < k_segments; ++i)
//					{
//						var d:b2Vec2 = new b2Vec2(r * Math.cos(theta), r * Math.sin(theta));
//						var v:b2Vec2 = b2Math.AddVV(pos , d);
//						m_sprite.graphics.lineTo((v.x) * m_physScale, (v.y) * m_physScale);
//						theta += k_increment;
//					}
//					m_sprite.graphics.lineTo((pos.x + r) * m_physScale, (pos.y) * m_physScale);
//					m_sprite.graphics.moveTo((pos.x) * m_physScale, (pos.y) * m_physScale);
//					var ax:b2Vec2 = circle.m_R.col1;
//					var pos2:b2Vec2 = new b2Vec2(pos.x + r * ax.x, pos.y + r * ax.y);
//					m_sprite.graphics.lineTo((pos2.x) * m_physScale, (pos2.y) * m_physScale);
//				}
//				break;
//				case b2Shape.e_polyShape:
//				{
//					var poly:b2PolyShape = shape as b2PolyShape;
//					var tV:b2Vec2 = b2Math.AddVV(poly.m_position, b2Math.b2MulMV(poly.m_R, poly.m_vertices[i]));
//					m_sprite.graphics.lineStyle(1,0xffffff,1);
//					m_sprite.graphics.moveTo(tV.x * m_physScale, tV.y * m_physScale);
//					for (i = 0; i < poly.m_vertexCount; ++i)
//					{
//						v = b2Math.AddVV(poly.m_position, b2Math.b2MulMV(poly.m_R, poly.m_vertices[i]));
//						m_sprite.graphics.lineTo(v.x * m_physScale, v.y * m_physScale);
//					}
//					m_sprite.graphics.lineTo(tV.x * m_physScale, tV.y * m_physScale);
//				}
//				break;
//			}
		}
		
//======================
// Draw Joint 
//======================
		public function DrawJoint(joint:b2Joint):void
		{
//			var b1:b2Body = joint.m_body1;
//			var b2:b2Body = joint.m_body2;
//			var x1:b2Vec2 = b1.m_position;
//			var x2:b2Vec2 = b2.m_position;
//			var p1:b2Vec2 = joint.GetAnchor1();
//			var p2:b2Vec2 = joint.GetAnchor2();
//			m_sprite.graphics.lineStyle(1,0x44aaff,1/1);
//			switch (joint.m_type)
//			{
//			case b2Joint.e_distanceJoint:
//			case b2Joint.e_mouseJoint:
//				m_sprite.graphics.moveTo(p1.x * m_physScale, p1.y * m_physScale);
//				m_sprite.graphics.lineTo(p2.x * m_physScale, p2.y * m_physScale);
//				break;
//			case b2Joint.e_pulleyJoint:
//				var pulley:b2PulleyJoint = joint as b2PulleyJoint;
//				var s1:b2Vec2 = pulley.GetGroundPoint1();
//				var s2:b2Vec2 = pulley.GetGroundPoint2();
//				m_sprite.graphics.moveTo(s1.x * m_physScale, s1.y * m_physScale);
//				m_sprite.graphics.lineTo(p1.x * m_physScale, p1.y * m_physScale);
//				m_sprite.graphics.moveTo(s2.x * m_physScale, s2.y * m_physScale);
//				m_sprite.graphics.lineTo(p2.x * m_physScale, p2.y * m_physScale);
//				break;
//			default:
//				if (b1 == m_world.m_groundBody){
//					m_sprite.graphics.moveTo(p1.x * m_physScale, p1.y * m_physScale);
//					m_sprite.graphics.lineTo(x2.x * m_physScale, x2.y * m_physScale);
//				}
//				else if (b2 == m_world.m_groundBody){
//					m_sprite.graphics.moveTo(p1.x * m_physScale, p1.y * m_physScale);
//					m_sprite.graphics.lineTo(x1.x * m_physScale, x1.y * m_physScale);
//				}
//				else{
//					m_sprite.graphics.moveTo(x1.x * m_physScale, x1.y * m_physScale);
//					m_sprite.graphics.lineTo(p1.x * m_physScale, p1.y * m_physScale);
//					m_sprite.graphics.lineTo(x2.x * m_physScale, x2.y * m_physScale);
//					m_sprite.graphics.lineTo(p2.x * m_physScale, p2.y * m_physScale);
//				}
//			}
		}

//======================		

//		
////======================
//// Update mouseWorld
////======================
//		public function UpdateMouseWorld():void 
//		{
//			mouseXWorldPhys = (Input.mouseX)/m_physScale; 
//			mouseYWorldPhys = (Input.mouseY)/m_physScale; 
//			mouseXWorld = (Input.mouseX); 
//			mouseYWorld = (Input.mouseY); 
//		}
//		
////======================
//// Mouse Drag 
////======================
//		public function MouseDrag():void
//		{
//			// mouse press
//			if (Input.mouseDown && !m_mouseJoint)
//			{
//				var body:b2Body = GetBodyAtMouse();
//				if (body)
//				{
//					var md:b2MouseJointDef = new b2MouseJointDef();
//					md.body1 = m_world.GetGroundBody();
//					md.body2 = body;
//					md.target.Set(mouseXWorldPhys, mouseYWorldPhys);
//					md.maxForce = 300.0 * body.GetMass();
//					md.timeStep = m_timeStep;
//					m_mouseJoint = m_world.CreateJoint(md) as b2MouseJoint;
//					body.WakeUp();
//				}
//			}
//			// mouse release
//			if (!Input.mouseDown){
//				if (m_mouseJoint)
//				{
//					m_world.DestroyJoint(m_mouseJoint);
//					m_mouseJoint = null;
//				}
//			}
//			// mouse move
//			if (m_mouseJoint)
//			{
//				var p2:b2Vec2 = new b2Vec2(mouseXWorldPhys, mouseYWorldPhys);
//				m_mouseJoint.SetTarget(p2);
//			}
//		}		
//		
////======================
//// Mouse Destroy
////======================
//		public function MouseDestroy():void
//		{
//			// mouse press
//			if (!Input.mouseDown && Input.isKeyPressed(68D))
//			{
//				
//				var body:b2Body = GetBodyAtMouse(true);
//				
//				if (body)
//				{
//					m_world.DestroyBody(body);
//					return;
//				}
//			}
//		}
//		


	}
}