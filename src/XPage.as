package 
{
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
		
		
		public var back_side:MovieClip;
			public var back_content:MovieClip;
				public var back_media:MovieClip;
		public var back_mask:MovieClip;
			public var back_mblock:MovieClip;
		public var back_inner_shadow:MovieClip;
			public var back_ishadow_clip:MovieClip;
		public var back_ismask:MovieClip;
			public var back_isblock:MovieClip;
		public var back_outer_shadow:MovieClip;
			public var back_oshadow_clip:MovieClip;
		public var back_osmask:MovieClip;
			public var back_osblock:MovieClip;
			
		public var dots:MovieClip;
			
		public var frontPage:MovieClip;
		
			public var front_side:MovieClip;
				public var front_media:MovieClip;
				public var front_side_shadow:MovieClip;
					public var front_sshadow_clip:MovieClip;
				public var hotCornerTop:MovieClip;
				public var hotCornerBottom:MovieClip;
					
			public var front_mask:MovieClip;
			public var front_mblock:MovieClip;
			
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
		
		
		public static const DRAG_TOP:String 		= "top";
		public static const DRAG_BOTTOM:String 		= "bottom";
		
		public static const TYPE_RIGHT:String		= "right"; // visible 0, invisible 1, on the right side, visible pages by default
		public static const TYPE_LEFT:String 		= "left";

		public var dragtype:String = DRAG_BOTTOM;
		public var clicktime:int = 0;
		
		
		
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
			
			mouseEnabled = false;
			mouseChildren = false;
			
			// ------------------ Create Back Page ----------------------------------------------------------- //
			back_media = Main.getPageContent(back, type);
			
			back_content  = new MovieClip();
			back_content.addChild(back_media); // Центр расположен в углу за который выполнятется перетягивание
			
			back_side = new MovieClip();
			back_side.addChild(back_content);
			
			back_mblock = new GUIMask();
			back_mblock.scaleX = Main.maskWidth / 100;
			back_mblock.scaleY = Main.maskHeight / 100;
			
			back_mask = new MovieClip();
			back_mask.addChild(back_mblock); // Центр расположен в углу вокруг которого выполняется вращение
			
			addChild(back_side);
			addChild(back_mask);
			
			back_mask.mouseEnabled = false;
			back_mask.mouseChildren = false;
			back_side.mask = back_mask;
			// ------------------ Create Back Page ----------------------------------------------------------- //
			
			
			// ------------------ Create Inner Diagonal Shadow ----------------------------------------------- //
			back_ishadow_clip = new GUIShadow();
			back_ishadow_clip.scaleX = Main.shadowWidth / 100;
			back_ishadow_clip.scaleY = Main.maskHeight / 100;

			if (pageType == TYPE_RIGHT)
				back_ishadow_clip.rotation = 180;
			
			back_inner_shadow = new MovieClip();
			back_inner_shadow.addChild(back_ishadow_clip);
			
			back_isblock = new GUIMask();
			back_isblock.scaleX = Main.pageWidth / 100;
			back_isblock.scaleY = Main.pageHeight / 100;
			
			back_ismask = new MovieClip();
			back_ismask.addChild(back_isblock);
			
			addChild(back_inner_shadow);
			addChild(back_ismask);
			
			back_ismask.mouseEnabled = false;
			back_ismask.mouseChildren = false;
			back_inner_shadow.mask = back_ismask;
			// ------------------ Create Inner Diagonal Shadow ----------------------------------------------- //
			
			
			// ------------------ Create Outer Diagonal Shadow ----------------------------------------------- //
			back_oshadow_clip = new GUIShadow();
			back_oshadow_clip.scaleX = Main.shadowWidth / 100;
			back_oshadow_clip.scaleY = Main.maskHeight / 100;

			if (pageType == TYPE_LEFT)
				back_oshadow_clip.rotation = 180;
			
			back_outer_shadow = new MovieClip();
			back_outer_shadow.addChild(back_oshadow_clip);
			
			back_osblock = new GUIMask();
			back_osblock.scaleX = Main.pageWidth / 100;
			back_osblock.scaleY = Main.pageHeight / 100;
			
			back_osmask = new MovieClip();
			back_osmask.addChild(back_osblock);
			
			addChild(back_outer_shadow);
			addChild(back_osmask);
			
			back_osmask.mouseEnabled = false;
			back_osmask.mouseChildren = false;
			back_outer_shadow.mask = back_osmask;
			// ------------------ Create Outer Diagonal Shadow ----------------------------------------------- //
			
			
			
			// ------------------ Create Front Static Page -------------------------------------------------- //
			frontPage = new MovieClip();
			
			front_media = Main.getPageContent(front, type);
			
				// -------- Inner Static Shadow -------------------------------- //
				front_sshadow_clip = new GUIShadow();
				front_sshadow_clip.scaleX = Main.shadowWidth / 100;
				front_sshadow_clip.scaleY = Main.pageHeight / 100;	// TODO: Plus page paddings

				if (pageType == TYPE_LEFT)
				{
					front_sshadow_clip.rotation = 180;
					front_sshadow_clip.y = Main.pageHeight;
				}
				
				front_side_shadow = new MovieClip();
				front_side_shadow.addChild(front_sshadow_clip);			
				// -------- Inner Static Shadow -------------------------------- //
				
			front_side = new MovieClip();
			front_side.addChild(front_media);
			front_side.addChild(front_side_shadow);			
			
			__addCorners();
			
			front_mblock = new GUIMask();
			front_mblock.scaleX = Main.maskWidth / 100;
			front_mblock.scaleY = Main.maskHeight / 100;
			
			front_mask = new MovieClip();
			front_mask.addChild(front_mblock);  // Центр расположен в углу вокруг которого выполняется вращение
			front_mask.mouseEnabled = false;
			
			frontPage.addChild(front_mask);
			frontPage.addChild(front_side);
			
			front_mask.mouseEnabled = false;
			front_mask.mouseChildren = false;
			front_side.mask = front_mask;
			// ------------------ Create Front Static Page -------------------------------------------------- //
			
			resetPosition();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function regenerateContent()
		{
			back_media = Main.getPageContent(back, pagePosition);
			if (back_media.parent != null) back_media.parent.removeChild(back_media);
			back_content.addChild(back_media);
			
			front_media = Main.getPageContent(front, pagePosition);
			if (front_media.parent != null) front_media.parent.removeChild(front_media);
			front_side.addChild(front_media);

			front_side.setChildIndex(front_side_shadow, front_side.numChildren - 1);
			front_side.setChildIndex(hotCornerTop, front_side.numChildren - 1);
			front_side.setChildIndex(hotCornerBottom, front_side.numChildren - 1);
		}
		
		private function __addCorners()
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
			
			front_side.addChild(hotCornerTop);
			front_side.addChild(hotCornerBottom);
			
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
			if (clicktime > 0 && stoptime - clicktime < Main.clickSpeed)
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
				
			front_media.y = 0; 						// always
			front_side_shadow.x = Main.pageWidth;	// always
			front_side_shadow.y = 0;				// always
			
			if (dragtype == DRAG_BOTTOM)
			{
				back_media.y 			= - Main.pageHeight;
				back_content.y 			= Main.pageHeight;

				back_mblock.y 			= - Main.maskBefore - Main.pageHeight;
				back_mask.y 			= Main.pageHeight;
			}
			if (dragtype == DRAG_TOP)
			{
				back_media.y 			= 0;
				back_content.y 			= 0;
				
				back_mblock.y 			= - Main.maskBefore;
				back_mask.y 			= 0;
			}
			
			if (pageType == TYPE_RIGHT)
			{
				back_media.x = 0;
				back_mblock.x = - Main.maskWidth;
				front_media.x = Main.pageWidth;
				
				if (pagePosition == TYPE_RIGHT)
				{
					back_mask.x = 2 * Main.pageWidth;
				}
				if (pagePosition == TYPE_LEFT)
				{
					back_mask.x = Main.pageWidth;
				}
			}
			if (pageType == TYPE_LEFT)
			{
				back_media.x = - Main.pageWidth;
				back_mblock.x = 0; 
				front_media.x = 0;

				if (pagePosition == TYPE_LEFT)
				{
					back_mask.x = 0;
				}
				if (pagePosition == TYPE_RIGHT)
				{
					back_mask.x = Main.pageWidth;
				}
			}
			
			if (pagePosition == TYPE_RIGHT)
			{
				back_content.x = 2 * Main.pageWidth;
			}	
			if (pagePosition == TYPE_LEFT)
			{
				back_content.x = 0;
			}
			
			

			if (pageType == TYPE_RIGHT)
			{
				if (dragtype == DRAG_BOTTOM)
				{
					back_ishadow_clip.y 	= Main.maskBefore; 
					back_oshadow_clip.y		= -Main.maskBefore - Main.pageHeight;
				}
				if (dragtype == DRAG_TOP)
				{
					back_ishadow_clip.y 	= Main.maskBefore + Main.pageHeight;
					back_oshadow_clip.y		= -Main.maskBefore;
				}
			}
			if (pageType == TYPE_LEFT)
			{
				if (dragtype == DRAG_BOTTOM)
				{
					back_ishadow_clip.y 	= -Main.pageDiagonal;
					back_oshadow_clip.y		= Main.maskBefore;
				}
				if (dragtype == DRAG_TOP)
				{
					back_ishadow_clip.y 	= -Main.maskBefore;
					back_oshadow_clip.y		= Main.maskBefore + Main.pageHeight;
				}
			}
			
			back_content.rotation 		= 0;
			back_mask.rotation 			= 0;
			
			// ------- FrontMBlock == BackMBlock ---------- // Block of front page mask is the same as back
			front_mblock.x				= back_mblock.x;
			front_mblock.y				= back_mblock.y;
			
			// -------- BackInnerShadowBlock == BackMedia - // Mask for shadow is page size and position
			back_isblock.x 				= back_media.x;
			back_isblock.y 				= back_media.y;

			// -------- BackOuterMask == FrontMedia - // Mask for outer shadow is front page
			back_osmask.x 				= front_media.x;
			back_osmask.y 				= front_media.y;
			
			// ------- FrontMask == BackMask -------------- // Front page mask is the same as back
			front_mask.rotation			= back_mask.rotation;
			front_mask.x 				= back_mask.x;
			front_mask.y 				= back_mask.y;
			
			// -------- BackInnerShadow == BackMask ------- // Position of diagonal shadow is position of mask
			back_inner_shadow.rotation	= back_mask.rotation;
			back_inner_shadow.x 		= back_mask.x;
			back_inner_shadow.y 		= back_mask.y;

			// -------- BackOuterShadow == BackMask ------- // Position of diagonal shadow is position of mask
			back_outer_shadow.rotation	= back_mask.rotation;
			back_outer_shadow.x 		= back_mask.x;
			back_outer_shadow.y 		= back_mask.y;
			
			// -------- BackShadowMash == MackContent ----- // Shadow Mask has the same position as back page
			back_ismask.rotation 		= back_content.rotation;
			back_ismask.x 				= back_content.x;
			back_ismask.y 				= back_content.y;
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
				
				if (bisectorTanget > 0)
					bisectorTanget = 0;
			}
			if (pageType == TYPE_RIGHT)
			{
				bisector.x 			= corner.x + 0.5 * (Main.pageWidth - corner.x);
				bisector.y 			= corner.y + 0.5 * (neary - corner.y);
				
				bisectorAngle 		= Math.atan2(neary - bisector.y, Main.pageWidth - bisector.x);
				bisectorTanget 		= bisector.x - Math.tan(bisectorAngle) * (neary - bisector.y);
				
				if (bisectorTanget < 0)
					bisectorTanget = 0;
			}
				
			tangentBottom.x = bisectorTanget;
			tangentBottom.y = neary;

			// DETERMINE THE tangentToCorner FOR THE ANGLE OF THE PAGE
            tangentToCornerAngle = Math.atan2(tangentBottom.y - corner.y, tangentBottom.x - corner.x);
			
			back_content.x 		= Main.origin.x + corner.x;
			back_content.y 		= Main.origin.y + corner.y;
			
			if (pageType == TYPE_RIGHT)
				back_content.rotation = tangentToCornerAngle * 180.0 / Math.PI;
			if (pageType == TYPE_LEFT)
				back_content.rotation = 180 + tangentToCornerAngle * 180.0 / Math.PI;
			
			// DETERMINE THE ANGLE OF THE MAIN MASK RECTANGLE
            var tanAngle:Number		= Math.atan2(neary - bisector.y, bisector.x - bisectorTanget);
				
            // VISUALIZE THE CLIPPING RECTANGLE
			back_mask.rotation = tanAngle != 0 ? 90 * (tanAngle / Math.abs(tanAngle)) - tanAngle * 180 / Math.PI : 0;
			back_mask.x = tangentBottom.x + Main.pageWidth;
			
			
			
			
			// ------- FrontMask == BackMask -------------- // Front page mask is the same as back
			front_mask.rotation			= back_mask.rotation;
			front_mask.x 				= back_mask.x;
			front_mask.y 				= back_mask.y;
			
			// -------- BackInnerShadow == BackMask ------- // Position of diagonal shadow is position of mask
			back_inner_shadow.rotation	= back_mask.rotation;
			back_inner_shadow.x 		= back_mask.x;
			back_inner_shadow.y 		= back_mask.y;

			// -------- BackOuterShadow == BackMask ------- // Position of diagonal shadow is position of mask
			back_outer_shadow.rotation	= back_mask.rotation;
			back_outer_shadow.x 		= back_mask.x;
			back_outer_shadow.y 		= back_mask.y;
			
			// -------- BackShadowMash == MackContent ----- // Shadow Mask has the same position as back page
			back_ismask.rotation 		= back_content.rotation;
			back_ismask.x 				= back_content.x;
			back_ismask.y 				= back_content.y;
			
			
			
			
			
			/*var py:Number = -Main.pageHalfHeight;
			var px:Number = tangentBottom.x + Main.pageHeight / Math.tan(tanAngle);
			if (px > Main.pageWidth)
			{
				px = Main.pageWidth;
				py = tangentBottom.y - (Main.pageWidth - tangentBottom.x)  * Math.tan(tanAngle);
			}
			
			maskedShadow.scaleY = Math.sqrt(
				(neary - py) * (neary - py) + 
				(tangentBottom.x - px)  * (tangentBottom.x - px)
			) / Main.pageHeight;*/
			
			// DEBUG AREA
			{
				clearDots();
				
				//addDot(px, py, "DD");
				
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
					
					//drawDemoCircle(0, Main.pageHalfHeight, Main.pageWidth, "");
					//drawDemoCircle(0, -Main.pageHalfHeight, Main.pageDiagonal, "");
				}
				if (dragtype == DRAG_TOP)
				{
					drawLine(bisector.x, bisector.y, bisector.x, -Main.pageHalfHeight, Main.blue);
					drawLine(bisector.x, bisector.y, tangentBottom.x, tangentBottom.y, Main.blue);
					drawLine(bisector.x, -Main.pageHalfHeight, tangentBottom.x, tangentBottom.y, Main.blue);
					
					addDot(bisector.x, bisector.y, "T0");
					addDot(bisector.x, -Main.pageHalfHeight, "T1");
					addDot(tangentBottom.x, tangentBottom.y, "T2");
					
					//drawDemoCircle(0, -Main.pageHalfHeight, Main.pageWidth, "");
					//drawDemoCircle(0, Main.pageHalfHeight, Main.pageDiagonal, "");
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