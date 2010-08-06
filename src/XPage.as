package 
{
	import com.maksimus.ObjectEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	
	/**
	 * ...
	 * @author Maks Teslenko
	 */
	public class XPage extends MovieClip 
	{
		public var index: int;
		public var front: int;
		public var back: int;
		
		public var pageType: String;
		public var pagePosition: String;
		
		/**
		 * Front Page
		 */
		public var pmedia:MovieClip;

		/**
		 * Back Page
		 */
		public var xmedia:MovieClip;
		
		/**
		 * Back Page Wrapper
		 */
		public var xpage:MovieClip;

		/**
		 * Main Maks xblock
		 */
		public var xblock:MovieClip;
		
		/**
		 * Main Maks Element
		 */
		public var xmask:MovieClip;
		
		/**
		 * Element for Mask
		 */
		public var maskContainer:MovieClip;
		
		/**
		 * Debug Element
		 */
		public var dots:MovieClip;
		
		/**
		 * Mouse Position
		 */
		public var mouse:Point;
		
		/**
		 * Follow Point
		 */
		public var follow:Point;
		
		/**
		 * Mouse Follow Enabled
		 */
		public var active:Boolean = false;
		
		/**
		 * Mouse Follow Enabled
		 */
		public var hover:Boolean = false;
		
		/**
		 * Animation in Process
		 */
		public var animated:Boolean = false;
		
		
		public var pmask:MovieClip;
		public var pblock:MovieClip;
		public var bottomPage:MovieClip;
		public var bottomContainer:MovieClip;
		
		public static const DRAG_TOP:String 		= "top";
		public static const DRAG_BOTTOM:String 		= "bottom";
		
		public static const TYPE_RIGHT:String		= "right"; // visible 0, invisible 1, on the right side, visible pages by default
		public static const TYPE_LEFT:String 		= "left";

		public var dragtype:String = DRAG_BOTTOM;
		
		public var hotCornerTop:MovieClip;
		public var hotCornerBottom:MovieClip;
		
		public var clicktime:int;
		
		public function XPage(index:int, type:String)
		{
			super();
			
			mouse = new Point(0, 0);
			follow = new Point(0, 0);
			
			this.index = index;
			this.pageType = type;
			this.pagePosition = type;
			
			switch (type)
			{
				case TYPE_RIGHT:
					front = index * 2;
					back = index * 2 + 1;
					break;
				case TYPE_LEFT:
					front = index * 2 + 1;
					back = index * 2;
					break;
			}
			
			xmedia = Main.getPageContent(back);
			
			xpage  = new MovieClip();
			xpage.addChild(xmedia); // Центр расположен в углу за который выполнятется перетягивание
			
			xblock = new GUIMask();
			xblock.scaleX = Main.maskWidth / 100;
			xblock.scaleY = Main.maskHeight / 100;
			
			xmask = new MovieClip();
			xmask.addChild(xblock);  // Центр расположен в углу вокруг которого выполняется вращение
			
			maskContainer = new MovieClip();
			maskContainer.addChild(xpage);
			addChild(xmask);
			addChild(maskContainer);
			maskContainer.mask = xmask;
						
			mouseEnabled = false;
			mouseChildren = false;
			
			// ------- Create Bottom Element ---------- //
			bottomPage = new MovieClip();
						
			pmedia = Main.getPageContent(front);
			
			pblock = new GUIMask();
			pblock.scaleX = Main.maskWidth / 100;
			pblock.scaleY = Main.maskHeight / 100;
			
			pmask = new MContainer();
			pmask.addChild(pblock);  // Центр расположен в углу вокруг которого выполняется вращение
			pmask.mouseEnabled = false;
			
			bottomContainer = new MovieClip();
			bottomContainer.addChild(pmedia);
			bottomPage.addChild(pmask);
			bottomPage.addChild(bottomContainer);
			bottomContainer.mask = pmask;
			// ---------------------------------------- //
			
			addCorners();
			resetPosition();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function regenerateContent()
		{
			//trace("REGENERATE", index, pageType);
			
			maskContainer.removeChild(xpage);
			xmedia = Main.getPageContent(back);
			if (xmedia.parent != null) xmedia.parent.removeChild(xmedia);
			xpage.addChild(xmedia);
			maskContainer.addChild(xpage);
			
			pmedia = Main.getPageContent(front);
			if (pmedia.parent != null) pmedia.parent.removeChild(pmedia);
			bottomContainer.addChild(pmedia);
			
			bottomContainer.setChildIndex(hotCornerTop, bottomContainer.numChildren - 1);
			bottomContainer.setChildIndex(hotCornerBottom, bottomContainer.numChildren - 1);
		}
		
		public function addCorners()
		{
			hotCornerTop = new GUIMask();
			hotCornerTop.buttonMode = true;
			hotCornerTop.scaleX = Main.cornerSize / 100;
			hotCornerTop.scaleY = Main.cornerSize / 100;
			hotCornerTop.alpha = 0;
		
			hotCornerBottom = new GUIMask();
			hotCornerBottom.buttonMode = true;
			hotCornerBottom.scaleX = Main.cornerSize / 100;
			hotCornerBottom.scaleY = Main.cornerSize / 100;
			hotCornerBottom.alpha = 0;
			
			if (pageType == TYPE_RIGHT)
			{
				hotCornerTop.x = 2 * Main.pageWidth - Main.cornerSize;
				hotCornerBottom.x = 2 * Main.pageWidth - Main.cornerSize;
			}
			if (pageType == TYPE_LEFT)
			{
				hotCornerTop.x = 0;
				hotCornerBottom.x = 0;	
			}
			hotCornerTop.y = 0;
			hotCornerBottom.y = Main.pageHeight - Main.cornerSize;
			
			bottomContainer.addChild(hotCornerTop);
			bottomContainer.addChild(hotCornerBottom);
			
			hotCornerTop.addEventListener(MouseEvent.MOUSE_OVER, onPageTopCorner_MouseOver);
			hotCornerBottom.addEventListener(MouseEvent.MOUSE_OVER, onPageBottomCorner_MouseOver);
			
			hotCornerTop.addEventListener(MouseEvent.MOUSE_OUT, onPageCorner_MouseOut);
			hotCornerBottom.addEventListener(MouseEvent.MOUSE_OUT, onPageCorner_MouseOut);
			
			hotCornerTop.addEventListener(MouseEvent.MOUSE_DOWN, oPageCorner_MouseDown);
			hotCornerBottom.addEventListener(MouseEvent.MOUSE_DOWN, oPageCorner_MouseDown);
		}
		
		private function onPageCorner_MouseOut(e:MouseEvent):void 
		{
			clicktime = 0;
			if (hover)
			{
				hover = false;
				deactivateDrag();
			}
		}
		
		private function onPageBottomCorner_MouseOver(e:MouseEvent):void 
		{
			activateHover(DRAG_BOTTOM);
		}
		
		private function onPageTopCorner_MouseOver(e:MouseEvent):void 
		{
			activateHover(DRAG_TOP);
		}
		
		private function activateHover(dragtype:String)
		{
			this.dragtype = dragtype;
			
			mouse  = Main.getMouseOriginPosition();
			//follow = Main.getMouseOriginPosition();
			
			var yPos:Number = 0;
			var xPos:Number = 0;
			
			if (dragtype == DRAG_BOTTOM)
				yPos = Main.pageHalfHeight;
			if (dragtype == DRAG_TOP)
				yPos = -Main.pageHalfHeight;
			if (pageType == TYPE_RIGHT)
                xPos = Main.pageWidth;
            if (pageType == TYPE_LEFT)
				xPos = -Main.pageWidth;
				
			follow = new Point(xPos, yPos);	
			
			animated = true;
			hover = true;
			
			resetPosition();
		}
		
		private function activateDrag(dragtype:String)
		{
			this.dragtype = dragtype;
			
			mouse  = Main.getMouseOriginPosition();
			follow = Main.getMouseOriginPosition();
			
			animated = true;
			active = true;
			hover = false;
			
			dispatchEvent(new Event("AnimationStarted"));
			
			resetPosition();
		}
		
		public function deactivateDrag()
		{
			var yPos:Number = 0;
			var xPos:Number = 0;
			
			if (dragtype == DRAG_BOTTOM)
				yPos = Main.pageHalfHeight;
			if (dragtype == DRAG_TOP)
				yPos = -Main.pageHalfHeight;
			
			var stoptime:int = getTimer();
			if (stoptime - clicktime < Main.clickSpeed)
				mouse.x = -mouse.x;
				
			if (mouse.x < 0)
                xPos = -Main.pageWidth;
            else
				xPos = Main.pageWidth;
				
			mouse = new Point(xPos, yPos);	
			active = false;
		}
		
		private function oPageCorner_MouseDown(e:MouseEvent):void 
		{
			clicktime = getTimer();
			
			if (mouseY > Main.pageHalfHeight)
				activateDrag(DRAG_BOTTOM);
			else
				activateDrag(DRAG_TOP);
		}
		
		private function onEnterFrame(e:Event):void 
		{
			if (!animated && !hover) return;
			
			follow.x += (mouse.x - follow.x) * Main.animationSpeed;
            follow.y += (mouse.y - follow.y) * Main.animationSpeed;
			
			render();
			
			if (!active && !hover) // check if we need to close automatic animation
			{
				// check if we need to stop animation
				if (Math.abs(follow.x - ( -Main.pageWidth)) < 5)
				{
					if (pagePosition == TYPE_LEFT)
					{
						resetPosition();
					}
					else
					{
						//trace("RESET to LEFT");
						
						pagePosition = TYPE_LEFT;
						dispatchEvent(new Event("AnimationComplete"));
					}
					animated = false;
				}
				if (Math.abs(follow.x - Main.pageWidth) < 5)
				{
					if (pagePosition == TYPE_RIGHT)
					{
						resetPosition();
					}
					else
					{
						//trace("RESET to RIGHT");
						
						pagePosition = TYPE_RIGHT;
						dispatchEvent(new Event("AnimationComplete"));
					}
					animated = false;	
				}
			} //
		}
		
		public function resetPosition(toPosition:String = null)
		{
			if (toPosition != null)
				pagePosition = toPosition;

			//trace("Reset position page:", pageType, "position:", pagePosition, "index:", index, "visible:", visible.toString(), "Dragtype: ", dragtype);	
				
			pmedia.y = 0; // always
				
			if (dragtype == DRAG_BOTTOM)
			{
				xmedia.y 		= - Main.pageHeight;
				xpage.y 		= Main.pageHeight;

				xblock.y 		= - Main.pageWidth - Main.pageHeight;
				pblock.y 		= - Main.pageWidth - Main.pageHeight;
				
				xmask.y 		= Main.pageHeight;
				pmask.y 		= Main.pageHeight;
			}
			if (dragtype == DRAG_TOP)
			{
				xmedia.y 		= 0;
				xpage.y 		= 0;
				
				xblock.y 		= - Main.pageWidth;
				pblock.y 		= - Main.pageWidth;
				
				xmask.y 		= 0;
				pmask.y 		= 0;
			}
			
			/*trace(xpage.y);
			trace(xmedia.y);
			trace(xpage.getChildAt(0).y);*/
			
			xpage.rotation 	= 0;
			
			xmask.rotation 	= 0;
			pmask.rotation 	= 0;

			
			if (pageType == TYPE_RIGHT)
			{
				pmedia.x = Main.pageWidth;
				xmedia.x = 0;
				
				xblock.x = - Main.maskWidth;
				pblock.x = - Main.maskWidth;
				
				if (pagePosition == TYPE_RIGHT)
				{
					xmask.x = 2 * Main.pageWidth;
					pmask.x = 2 * Main.pageWidth;
				}
				if (pagePosition == TYPE_LEFT)
				{
					xmask.x = Main.pageWidth;
					pmask.x = Main.pageWidth;
				}
			}
			if (pageType == TYPE_LEFT)
			{
				pmedia.x = 0;
				xmedia.x = - Main.pageWidth;
				xblock.x = 0; 
				pblock.x = 0; 
				
				if (pagePosition == TYPE_LEFT)
				{
					xmask.x = 0;
					pmask.x = 0;
				}
				if (pagePosition == TYPE_RIGHT)
				{
					xmask.x = Main.pageWidth;
					pmask.x = Main.pageWidth;
				}
			}
			
			if (pagePosition == TYPE_RIGHT)
			{
				xpage.x = 2 * Main.pageWidth;
			}	
			if (pagePosition == TYPE_LEFT)
			{
				xpage.x = 0;
			}
		}
		
		public function render()
		{
			var dx:Number 					= 0;
			var dy:Number 					= 0;
			var a2f:Number 					= 0;
			var distanceToFollow:Number 	= 0;
			var distToRadius1:Number		= 0;
			var bisectorAngle:Number 		= 0;
			var bisectorTanget:Number 		= 0;
			var tangentToCornerAngle:Number = 0;
			
			var nearx:Number				= 0;
			var neary:Number				= 0;	
			
			var farx:Number					= 0;
			var fary:Number					= 0;
			
			var radius1:Point 				= new Point(0, 0);
			var radius2:Point 				= new Point(0, 0);
			var corner:Point				= new Point(0, 0);
			var bisector:Point				= new Point(0, 0);
			var tangentBottom:Point 		= new Point(0, 0);
			
			if (dragtype == DRAG_BOTTOM)
			{
				neary = Main.pageHalfHeight;
				fary = -Main.pageHalfHeight;
			}
			if (dragtype == DRAG_TOP)
			{
				neary = -Main.pageHalfHeight
				fary = Main.pageHalfHeight;
			}
			
			
			// RADIUS 1 SECTION
		
			// CHECK DISTANCE FROM SPINE BOTTOM TO RAW FOLLOW
			dx					= follow.x;
			dy					= neary - follow.y;
			
			// DETERMINE ANGLE FROM SPINE BOTTOM TO RAW FOLLOW
			a2f					= Math.atan2(dy, dx);
		
			// PLOT THE FIXED RADIUS FOLLOW
			radius1.x			= Math.cos(a2f) * Main.fixedRadius;	
			radius1.y			= neary - Math.sin(a2f) * Main.fixedRadius;
			
			// DETERMINE THE SHORTER OF THE TWO DISTANCES
			distanceToFollow	= Math.sqrt((neary - follow.y) * (neary - follow.y) + (follow.x * follow.x));
			distToRadius1	 	= Math.sqrt((neary - radius1.y) * (neary - radius1.y) + (radius1.x * radius1.x));
			
			// THE SMALLER OF THE TWO RADII DETERMINES THE CORNER
            if (distToRadius1 < distanceToFollow)
            {
                corner.x = radius1.x; 
                corner.y = radius1.y;
            }
            else
            {
                corner.x = follow.x; 
                corner.y = follow.y;
            }

			// RADIUS 2 SECTION
			
			// NOW CHECK FOR THE OTHER CONSTRAINT, FROM THE SPINE TOP TO THE RADIUS OF THE PAGE DIAMETER...
			dx 					= farx - corner.x;
			dy 					= corner.y + neary;
			distanceToFollow	= Math.sqrt(dx * dx + dy * dy);
			a2f 				= Math.atan2(dy, dx);
			radius2.x 			= -Math.cos(a2f) * Main.pageDiagonal;
			radius2.y 			= fary + Math.sin(a2f) * Main.pageDiagonal;
			
			if (distanceToFollow > Main.pageDiagonal) 
            {
                corner.x = radius2.x; 
                corner.y = radius2.y;
            }
			
			// CALCULATE THE BISECTOR AND CREATE THE CRITICAL TRIANGLE
            // DETERMINE THE MIDSECTION POINT
			
			if (pageType == TYPE_LEFT)
			{
				bisector.x 			= corner.x - 0.5 * (Main.pageWidth + corner.x);
				bisector.y 			= corner.y + 0.5 * (neary - corner.y);
				
				bisectorAngle 		= Math.atan2(neary - bisector.y, Main.pageWidth + bisector.x);
				bisectorTanget 		= bisector.x + Math.tan(bisectorAngle) * (neary - bisector.y);
				
				tangentBottom.x 	= bisectorTanget;
				tangentBottom.y 	= neary;
				
				if (bisectorTanget > 0)
					bisectorTanget = 0;
			}
			if (pageType == TYPE_RIGHT)
			{
				bisector.x 			= corner.x + 0.5 * (Main.pageWidth - corner.x);
				bisector.y 			= corner.y + 0.5 * (neary - corner.y);
				
				bisectorAngle 		= Math.atan2(neary - bisector.y, Main.pageWidth - bisector.x);
				bisectorTanget 		= bisector.x - Math.tan(bisectorAngle) * (neary - bisector.y);
				
				tangentBottom.x 	= bisectorTanget;
				tangentBottom.y 	= neary;
            
				if (bisectorTanget < 0)
					bisectorTanget = 0;
			}
				

			// DETERMINE THE tangentToCorner FOR THE ANGLE OF THE PAGE
            tangentToCornerAngle = Math.atan2(tangentBottom.y - corner.y, tangentBottom.x - corner.x);
			
			xpage.x 		= Main.origin.x + corner.x;
			xpage.y 		= Main.origin.y + corner.y;
			
			if (pageType == TYPE_RIGHT)
				xpage.rotation = tangentToCornerAngle * 180.0 / Math.PI;
			if (pageType == TYPE_LEFT)
				xpage.rotation = 180 + tangentToCornerAngle * 180.0 / Math.PI;
			
			// DETERMINE THE ANGLE OF THE MAIN MASK RECTANGLE
            var tanAngle:Number		= Math.atan2(neary - bisector.y, bisector.x - bisectorTanget);
				
            // VISUALIZE THE CLIPPING RECTANGLE
			xmask.rotation = tanAngle != 0 ? 90 * (tanAngle / Math.abs(tanAngle)) - tanAngle * 180 / Math.PI : 0;
			xmask.x = tangentBottom.x + Main.pageWidth;
			
			pmask.rotation = xmask.rotation;
			pmask.x = xmask.x;

			// DEBUG AREA
			{
				clearDots();
				
				drawLine(0, 0, follow.x, follow.y, Main.grey);
				drawLine(follow.x, follow.y, -Main.pageWidth, Main.pageHalfHeight, Main.grey);
				
				drawLine(0, -Main.pageHalfHeight, corner.x, corner.y, Main.red);
				drawLine(0, 0, corner.x, corner.y, Main.red);
				drawLine(corner.x, corner.y, -Main.pageWidth, Main.pageHalfHeight, Main.red);
				drawLine(0, Main.pageHalfHeight, corner.x, corner.y, Main.red);
				drawLine(0, Main.pageHalfHeight, corner.x, corner.y, Main.red);
				
				addDot(follow.x, follow.y,"F");
				
				//addDot(Main.pageWidth, Main.pageHalfHeight, "RB");
				//addDot(-Main.pageWidth, Main.pageHalfHeight, "LB");
				
				addDot(0, 0, "SC");
				addDot(0, -Main.pageHalfHeight, "ST");
				addDot(0, Main.pageHalfHeight, "SB");
				
				addDot(radius1.x, radius1.y, "R1");
				addDot(radius2.x, radius2.y, "R2"); 

				addDot(mouse.x, mouse.y, "M");
				addDot(corner.x, corner.y, "C");
				
				if (dragtype == DRAG_BOTTOM)
				{
					drawLine(bisector.x, bisector.y, bisector.x, Main.pageHalfHeight, Main.blue);
					drawLine(bisector.x, bisector.y, tangentBottom.x, tangentBottom.y, Main.blue);
					drawLine(bisector.x, Main.pageHalfHeight, tangentBottom.x, tangentBottom.y, Main.blue);
					
					addDot(bisector.x, bisector.y, "T0");
					addDot(bisector.x, Main.pageHalfHeight, "T1");
					addDot(tangentBottom.x, tangentBottom.y, "T2");
					
					drawDemoCircle(0, Main.pageHalfHeight, Main.pageWidth, "");
					drawDemoCircle(0, -Main.pageHalfHeight, Main.pageDiagonal, "");
				}
				if (dragtype == DRAG_TOP)
				{
					drawLine(bisector.x, bisector.y, bisector.x, -Main.pageHalfHeight, Main.blue);
					drawLine(bisector.x, bisector.y, tangentBottom.x, tangentBottom.y, Main.blue);
					drawLine(bisector.x, -Main.pageHalfHeight, tangentBottom.x, tangentBottom.y, Main.blue);
					
					addDot(bisector.x, bisector.y, "T0");
					addDot(bisector.x, -Main.pageHalfHeight, "T1");
					addDot(tangentBottom.x, tangentBottom.y, "T2");
					
					drawDemoCircle(0, -Main.pageHalfHeight, Main.pageWidth, "");
					drawDemoCircle(0, Main.pageHalfHeight, Main.pageDiagonal, "");
				}
				
				/*var r0: Point = dots.globalToLocal(maskAngle.localToGlobal(new Point(- maskSize.x, -85)));
				var r1: Point = dots.globalToLocal(maskAngle.localToGlobal(new Point(0, -85)));
				var r2: Point = dots.globalToLocal(maskAngle.localToGlobal(new Point(- maskSize.x, 15)));
				var r3: Point = dots.globalToLocal(maskAngle.localToGlobal(new Point(0, 15)));
				
				addDot(r0.x, r0.y, "R0");
				addDot(r1.x, r1.y, "R1");
				addDot(r2.x, r2.y, "R2");
				addDot(r3.x, r3.y, "R3");*/
				
			}
		}
		
		private function clearDots()
		{
			if (dots)
				removeChild(dots);
			
			dots = new MovieClip();
			dots.mouseEnabled = false;
			dots.mouseChildren = false;
			dots.x = Main.origin.x;
			dots.y = Main.origin.y;
			addChild(dots);
			
			dots.visible = false;
		}
		
		private function addDot(x: Number, y: Number, s:String)
        {
			drawDemoCircle(x, y, 10, s);
		}

        private function drawLine(x1:Number, y1:Number, x2:Number, y2:Number, c:uint)
        {
			var clip:MovieClip = new MovieClip();
			clip.graphics.lineStyle(1, c, 0.6, true, "normal", CapsStyle.ROUND, JointStyle.ROUND, 3);
			clip.graphics.moveTo(x1, y1);
			clip.graphics.lineTo(x2, y2);
			
			dots.addChild(clip);
        }

		private function drawDemoCircle(x: Number, y:Number, radius:Number, text:String)
		{
			var clip:MovieClip = new MovieClip();
			clip.graphics.lineStyle(1, 0, 0.6, true, "normal", CapsStyle.ROUND, JointStyle.ROUND, 3);
			clip.graphics.beginFill(0xCCCCCC, 0.5);
			clip.graphics.drawCircle(0, 0, radius);
			clip.graphics.endFill();
			clip.x = x;
			clip.y = y;
			
			if (text != null)
			{
				var tf:TextField = new TextField();
				tf.autoSize = TextFieldAutoSize.LEFT;
				tf.text = text;
				tf.textColor = 0;
				tf.x = 0 - tf.width / 2;
				tf.y = 0 - tf.height / 2;
				clip.addChild(tf);
			}
			
			dots.addChild(clip);
		}
		
	}
}