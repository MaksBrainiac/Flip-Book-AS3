package com.maksbrainiac.flipbook.components
{
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	
	import com.maksbrainiac.flipbook.events.*;
	
	/**
	 * ...
	 * @author Maks Teslenko
	 */
	public class XPage extends MovieClip 
	{
		public static const grey:uint 						= 0x666666;
		public static const red:uint 						= 0xFF0000;
		public static const blue:uint 						= 0x0000FF;
		
		public static const DRAG_TOP:String 				= "top";
		public static const DRAG_BOTTOM:String 				= "bottom";
		
		public static const TYPE_RIGHT:String				= "right"; // visible 0, invisible 1, on the right side, visible pages by default
		public static const TYPE_LEFT:String 				= "left";

		
		public var index: int;
		
		public var pageType: String;
		public var pagePosition: String;
		
		private var back_side:MovieClip;
			private var back_content:MovieClip;
				private var back_media:PageObject;
		private var back_mask:MovieClip;
			private var back_mblock:MovieClip;
		private var back_inner_shadow:MovieClip;
			private var back_ishadow_clip:MovieClip;
		private var back_ismask:MovieClip;
			private var back_isblock:MovieClip;
		private var back_outer_shadow:MovieClip;
			private var back_oshadow_clip:MovieClip;
		private var back_osmask:MovieClip;
			private var back_osblock:MovieClip;
			
		private var mc_debug:MovieClip;
			
		public var frontPage:MovieClip;
		
			private var front_side:MovieClip;
				private var front_media:PageObject;
				private var front_side_shadow:MovieClip;
					private var front_sshadow_clip:MovieClip;
				private var hotCornerTop:MovieClip;
				private var hotCornerBottom:MovieClip;
					
			private var front_mask:MovieClip;
				private var front_mblock:MovieClip;
			
		/**
		 * Mouse Position
		 */
		public var mouse:Point;
		
		/**
		 * Follow Point
		 */
		public var follow:Point;
		
		
		private var _blocked:Boolean = true;
		
		
		
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
		

		
		private var dragtype:String = DRAG_BOTTOM;
		private var clicktime:int = 0;
		
		private var pageWidth:Number;
		private var pageHeight:Number;
		private var pageDiagonal:Number;
		
		private var pagePositionUp:Number;
		private var pagePositionDown:Number;
		
		private var marginTop:Number;
		private var marginBottom:Number;
		private var marginLeft:Number;
		private var marginRight:Number;
		
		private var maskHeight:Number;
		private var maskWidth:Number;
		private var maskBefore:Number;
		
		private var cornerSize:Number = 70;
		private var shadowWidth:Number = 10;
		private var clickSpeed:Number = 500;
		private var animationSpeed:Number = 0.2;
		
		private var pageHalfHeight:Number = 200;
		
		public function XPage(index:int, type:String, page0:PageObject, page1:PageObject, options:Object)
		{
			super();
			
			mouse = new Point(0, 0);
			follow = new Point(0, 0);
			
			this.index = index;
			this.pageType = type;
			this.pagePosition = type;
			
			if (options.cornerSize)
				cornerSize = options.cornerSize;
			if (options.shadowWidth)
				shadowWidth = options.shadowWidth;
			if (options.pageHeight)
				pageHalfHeight = options.pageHeight / 2;
			if (options.clickSpeed)
				clickSpeed = options.clickSpeed;
			if (options.animationSpeed)
				animationSpeed = options.animationSpeed;
			
			switch (type)
			{
				case TYPE_RIGHT:
					front_media = page0;
					back_media = page1;
					break;
				case TYPE_LEFT:
					front_media = page1;
					back_media = page0;
					break;
			}
			
			mouseEnabled = false;
			mouseChildren = false;
			
			// ------------------ Create Back Page ----------------------------------------------------------- //
			
			marginLeft = back_media.marginLeft;
			marginRight = back_media.marginRight;
			marginTop = back_media.marginTop;
			marginBottom = back_media.marginBottom;
			
			pageWidth = back_media.pageWidth + back_media.marginLeft + back_media.marginRight;
			pageHeight = back_media.pageHeight + back_media.marginTop + back_media.marginBottom;
			
			pagePositionUp 		= -pageHalfHeight - marginTop;
			pagePositionDown 	= pageHalfHeight + marginBottom;
			
			pageDiagonal 	= Math.sqrt(pageWidth * pageWidth + pageHeight * pageHeight);
			
			maskHeight 		= 2 * pageHeight + 2 * pageWidth;
			maskWidth		= pageDiagonal * 2;
			maskBefore		= (maskHeight - pageHeight) / 2;
			
			back_content  = new MovieClip();
			back_content.addChild(back_media); // Центр расположен в углу за который выполнятется перетягивание
			
			back_side = new MovieClip();
			back_side.addChild(back_content);
			
			back_mblock = new GUIMask();
			back_mblock.scaleX = maskWidth / 100;
			back_mblock.scaleY = maskHeight / 100;
			
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
			back_ishadow_clip.scaleX = shadowWidth / 100;
			back_ishadow_clip.scaleY = maskHeight / 100;

			if (pageType == TYPE_RIGHT)
				back_ishadow_clip.rotation = 180;
			
			back_inner_shadow = new MovieClip();
			back_inner_shadow.addChild(back_ishadow_clip);
			
			back_isblock = new GUIMask();
			back_isblock.scaleX = pageWidth / 100;
			back_isblock.scaleY = pageHeight / 100;
			
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
			back_oshadow_clip.scaleX = shadowWidth / 100;
			back_oshadow_clip.scaleY = maskHeight / 100;

			if (pageType == TYPE_LEFT)
				back_oshadow_clip.rotation = 180;
			
			back_outer_shadow = new MovieClip();
			back_outer_shadow.addChild(back_oshadow_clip);
			
			back_osblock = new GUIMask();
			back_osblock.scaleX = pageWidth / 100;
			back_osblock.scaleY = pageHeight / 100;
			
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
			
				// -------- Inner Static Shadow -------------------------------- //
				front_sshadow_clip = new GUIShadow();
				front_sshadow_clip.scaleX = shadowWidth / 100;
				front_sshadow_clip.scaleY = pageHeight / 100;

				if (pageType == TYPE_LEFT)
				{
					front_sshadow_clip.rotation = 180;
					front_sshadow_clip.y = pageHeight;
				}
				
				front_side_shadow = new MovieClip();
				front_side_shadow.addChild(front_sshadow_clip);			
				// -------- Inner Static Shadow -------------------------------- //
				
			front_side = new MovieClip();
			front_side.addChild(front_media);
			front_side.addChild(front_side_shadow);			
			
			__addCorners();
			
			front_mblock = new GUIMask();
			front_mblock.scaleX = maskWidth / 100;
			front_mblock.scaleY = maskHeight / 100;
			
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
		
		public override function toString():String
		{
			return "Page" 
						+ index 
						+ (blocked ? " [" : " (")
						+ (pagePosition == TYPE_LEFT ? "L" : "R") 
						+ (dragtype == DRAG_TOP ? "↑" : "↓")
						+ (active ? "D" : "_")
						+ (animated ? "@" : "_")
						+ (hover ? "H" : "_")
						+ (visible ? "*" : "_")
						+ (blocked ? " ]" : " )")
		}
		
		public function regenerateContent()
		{
			if (back_media.parent != null) back_media.parent.removeChild(back_media);
			back_content.addChild(back_media);
			
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
			hotCornerTop.scaleX = cornerSize / 100;
			hotCornerTop.scaleY = cornerSize / 100;
			hotCornerTop.alpha = 0;
		
			hotCornerBottom = new GUIMask();
			hotCornerBottom.buttonMode = true;
			hotCornerBottom.scaleX = cornerSize / 100;
			hotCornerBottom.scaleY = cornerSize / 100;
			hotCornerBottom.alpha = 0;
			
			if (pageType == TYPE_RIGHT)
			{
				hotCornerTop.x = pageWidth - cornerSize;
				hotCornerBottom.x = pageWidth - cornerSize;
			}
			if (pageType == TYPE_LEFT)
			{
				hotCornerTop.x = - pageWidth;
				hotCornerBottom.x = - pageWidth;	
			}
			hotCornerTop.y = pagePositionUp;
			hotCornerBottom.y = pagePositionDown - cornerSize;
			
			front_side.addChild(hotCornerTop);
			front_side.addChild(hotCornerBottom);
			
			hotCornerTop.addEventListener(MouseEvent.MOUSE_OVER, onPageTopCorner_MouseOver);
			hotCornerBottom.addEventListener(MouseEvent.MOUSE_OVER, onPageBottomCorner_MouseOver);
			
			hotCornerTop.addEventListener(MouseEvent.MOUSE_OUT, onPageCorner_MouseOut);
			hotCornerBottom.addEventListener(MouseEvent.MOUSE_OUT, onPageCorner_MouseOut);
			
			hotCornerTop.addEventListener(MouseEvent.MOUSE_DOWN, oPageCorner_MouseDown);
			hotCornerBottom.addEventListener(MouseEvent.MOUSE_DOWN, oPageCorner_MouseDown);
			
			blocked = true;
		}
		
		private function getTargetPosition(type:String, dragtype:String)
		{
			var yPos:Number = dragtype == DRAG_TOP ? pagePositionUp : pagePositionDown;
			var xPos:Number = type == TYPE_LEFT ? -pageWidth : pageWidth;
			
			return new Point(xPos, yPos);
		}
		
		private function onPageCorner_MouseOut(e:MouseEvent):void 
		{
			clicktime = 0;
			if (hover)
			{
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
		
		public function flip()
		{
			dragtype = DRAG_BOTTOM;

			follow 		= getTargetPosition(pageType, dragtype);
			mouse 		= getTargetPosition(pageType == TYPE_LEFT ? TYPE_RIGHT : TYPE_LEFT, dragtype);
			
			active 		= false;
			animated	= true;
			hover 		= false;
			
			resetPosition();
			
			dispatchEvent(new PageEvent(PageEvent.FLIPPED, false, false, index));
		}
		
		public function activateHover(dragtype:String = DRAG_BOTTOM)
		{
			this.dragtype = dragtype;
			
			mouse 		= new Point(mouseX, mouseY);
			follow 		= getTargetPosition(pageType, dragtype);
			
			active 		= false;
			animated 	= true;
			hover 		= true;
			
			resetPosition();
			
			dispatchEvent(new PageEvent(PageEvent.ANIMATION_START, false, false, index));
		}
		
		public function activateDrag(dragtype:String)
		{
			this.dragtype = dragtype;
			
			mouse  		= new Point(mouseX, mouseY);
			follow 		= new Point(mouseX, mouseY);
			
			animated 	= true;
			active 		= true;
			hover 		= false;
			
			resetPosition();
			
			dispatchEvent(new PageEvent(PageEvent.ANIMATION_START, false, false, index));
		}
		
		public function deactivateDrag()
		{
			var stoptime:int = getTimer();
			var flipped:Boolean = false;
			if (clicktime > 0 && stoptime - clicktime < clickSpeed)
			{
				mouse.x = -mouse.x;
				flipped = true;
			}
			
			active 		= false;
			hover 		= false;	
				
			var toPosition:String = mouse.x < 0 ? TYPE_LEFT : TYPE_RIGHT;
			
			mouse 		= getTargetPosition(toPosition, dragtype);
			
			if (flipped || toPosition != pagePosition)
				dispatchEvent(new PageEvent(PageEvent.FLIPPED, false, false, index));
		}
		
		private function oPageCorner_MouseDown(e:MouseEvent):void 
		{
			clicktime = getTimer();
			
			if (mouseY > 0)
				activateDrag(DRAG_BOTTOM);
			else
				activateDrag(DRAG_TOP);
		}
		
		private function onEnterFrame(e:Event):void 
		{
			if (!animated && !hover) return;
			
			follow.x += (mouse.x - follow.x) * animationSpeed;
            follow.y += (mouse.y - follow.y) * animationSpeed;
			
			render();
			
			if (!active && !hover) // check if we need to close automatic animation
			{
				// check if we need to stop animation
				if (Math.abs(follow.x - (-pageWidth)) < 5)
				{
					if (pagePosition == TYPE_LEFT)
					{
						resetPosition();
					}
					else
					{
						pagePosition = TYPE_LEFT;
						dispatchEvent(new PageEvent(PageEvent.ANIMATION_END, false, false, index));
					}
					animated = false;
				}
				if (Math.abs(follow.x - pageWidth) < 5)
				{
					if (pagePosition == TYPE_RIGHT)
					{
						resetPosition();
					}
					else
					{
						pagePosition = TYPE_RIGHT;
						dispatchEvent(new PageEvent(PageEvent.ANIMATION_END, false, false, index));
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
				
			front_media.y = pagePositionUp;			// always
			front_side_shadow.x = 0;				// always
			front_side_shadow.y = pagePositionUp;	// always
			
			if (dragtype == DRAG_BOTTOM)
			{
				back_media.y 			= -pageHeight;
				back_content.y 			= pagePositionDown;

				back_mblock.y 			= -maskBefore - pageHeight;
				back_mask.y 			= pagePositionDown;
			}
			if (dragtype == DRAG_TOP)
			{
				back_media.y 			= 0;
				back_content.y 			= pagePositionUp;
				
				back_mblock.y 			= -maskBefore;
				back_mask.y 			= pagePositionUp;
			}
			
			if (pageType == TYPE_RIGHT)
			{
				back_media.x = 0;
				back_mblock.x = -maskWidth;
				front_media.x = 0;
				
				if (pagePosition == TYPE_RIGHT)
					back_mask.x = pageWidth;
				if (pagePosition == TYPE_LEFT)
					back_mask.x = 0;
			}
			if (pageType == TYPE_LEFT)
			{
				back_media.x = -pageWidth;
				back_mblock.x = 0; 
				front_media.x = -pageWidth;

				if (pagePosition == TYPE_LEFT)
					back_mask.x = -pageWidth;
				if (pagePosition == TYPE_RIGHT)
					back_mask.x = 0;
			}
			
			if (pagePosition == TYPE_RIGHT)
				back_content.x = pageWidth;
			if (pagePosition == TYPE_LEFT)
				back_content.x = -pageWidth;

			if (pageType == TYPE_RIGHT)
			{
				if (dragtype == DRAG_BOTTOM)
				{
					back_ishadow_clip.y 	= maskBefore; 
					back_oshadow_clip.y		= -maskBefore - pageHeight;
				}
				if (dragtype == DRAG_TOP)
				{
					back_ishadow_clip.y 	= maskBefore + pageHeight;
					back_oshadow_clip.y		= -maskBefore;
				}
			}
			if (pageType == TYPE_LEFT)
			{
				if (dragtype == DRAG_BOTTOM)
				{
					back_ishadow_clip.y 	= -pageDiagonal;
					back_oshadow_clip.y		= maskBefore;
				}
				if (dragtype == DRAG_TOP)
				{
					back_ishadow_clip.y 	= -maskBefore;
					back_oshadow_clip.y		= maskBefore + pageHeight;
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
				neary = pagePositionDown;
				fary = pagePositionUp;
			}
			if (dragtype == DRAG_TOP)
			{
				neary = pagePositionUp;
				fary = pagePositionDown;
			}
			
			// RADIUS 1 SECTION
		
			// CHECK DISTANCE FROM SPINE BOTTOM TO RAW FOLLOW
			dx					= follow.x;
			dy					= neary - follow.y;
			
			// DETERMINE ANGLE FROM SPINE BOTTOM TO RAW FOLLOW
			a2f					= Math.atan2(dy, dx);
		
			// PLOT THE FIXED RADIUS FOLLOW
			radius1.x			= Math.cos(a2f) * pageWidth;	
			radius1.y			= neary - Math.sin(a2f) * pageWidth;
			
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
			dy 					= corner.y - fary;
			distanceToFollow	= Math.sqrt(dx * dx + dy * dy);
			a2f 				= Math.atan2(dy, dx);
			radius2.x 			= -Math.cos(a2f) * pageDiagonal;
			radius2.y 			= fary + Math.sin(a2f) * pageDiagonal;
			
			if (distanceToFollow > pageDiagonal) 
            {
                corner.x = radius2.x; 
                corner.y = radius2.y;
            }
			
			// CALCULATE THE BISECTOR AND CREATE THE CRITICAL TRIANGLE
            // DETERMINE THE MIDSECTION POINT
			
			if (pageType == TYPE_LEFT)
			{
				bisector.x 			= corner.x - 0.5 * (pageWidth + corner.x);
				bisector.y 			= corner.y + 0.5 * (neary - corner.y);
				
				bisectorAngle 		= Math.atan2(neary - bisector.y, pageWidth + bisector.x);
				bisectorTanget 		= bisector.x + Math.tan(bisectorAngle) * (neary - bisector.y);
				
				if (bisectorTanget > 0)
					bisectorTanget = 0;
			}
			if (pageType == TYPE_RIGHT)
			{
				bisector.x 			= corner.x + 0.5 * (pageWidth - corner.x);
				bisector.y 			= corner.y + 0.5 * (neary - corner.y);
				
				bisectorAngle 		= Math.atan2(neary - bisector.y, pageWidth - bisector.x);
				bisectorTanget 		= bisector.x - Math.tan(bisectorAngle) * (neary - bisector.y);
				
				if (bisectorTanget < 0)
					bisectorTanget = 0;
			}
				
			tangentBottom.x = bisectorTanget;
			tangentBottom.y = neary;

			// DETERMINE THE tangentToCorner FOR THE ANGLE OF THE PAGE
            tangentToCornerAngle = Math.atan2(tangentBottom.y - corner.y, tangentBottom.x - corner.x);
			
			back_content.x 		= corner.x;
			back_content.y 		= corner.y;
			
			if (pageType == TYPE_RIGHT)
				back_content.rotation = tangentToCornerAngle * 180.0 / Math.PI;
			if (pageType == TYPE_LEFT)
				back_content.rotation = 180 + tangentToCornerAngle * 180.0 / Math.PI;
			
			// DETERMINE THE ANGLE OF THE MAIN MASK RECTANGLE
            var tanAngle:Number		= Math.atan2(neary - bisector.y, bisector.x - bisectorTanget);
				
            // VISUALIZE THE CLIPPING RECTANGLE
			back_mask.rotation = tanAngle != 0 ? 90 * (tanAngle / Math.abs(tanAngle)) - tanAngle * 180 / Math.PI : 0;
			back_mask.x = tangentBottom.x;
			
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
			
			
			// DEBUG AREA
			{
				debug_clear();
				
				debug_drawLine(0, 0, follow.x, follow.y, grey);
				debug_drawLine(follow.x, follow.y, 0, pagePositionDown, grey);
				
				debug_drawLine(0, pagePositionUp, corner.x, corner.y, red);
				debug_drawLine(0, 0, corner.x, corner.y, red);
				debug_drawLine(corner.x, corner.y, 0, pagePositionDown, red);
				debug_drawLine(0, pagePositionDown, corner.x, corner.y, red);
				
				debug_addPoint(follow.x, follow.y,"F");
				
				debug_addPoint(0, 0, "SC");
				debug_addPoint(0, pagePositionUp, "ST");
				debug_addPoint(0, pagePositionDown, "SB");
				
				debug_addPoint(radius1.x, radius1.y, "R1");
				debug_addPoint(radius2.x, radius2.y, "R2"); 

				//addDot(mouse.x, mouse.y, "M");
				debug_addPoint(corner.x, corner.y, "C");
				
				if (dragtype == DRAG_BOTTOM)
				{
					debug_drawLine(bisector.x, bisector.y, bisector.x, pagePositionDown, blue);
					debug_drawLine(bisector.x, bisector.y, tangentBottom.x, tangentBottom.y, blue);
					debug_drawLine(bisector.x, pagePositionDown, tangentBottom.x, tangentBottom.y, blue);
					
					debug_addPoint(bisector.x, bisector.y, "T0");
					debug_addPoint(bisector.x, pagePositionDown, "T1");
					debug_addPoint(tangentBottom.x, tangentBottom.y, "T2");
					
					debug_drawCircle(0, pagePositionDown, pageWidth, "");
					debug_drawCircle(0, pagePositionUp, pageDiagonal, "");
				}
				if (dragtype == DRAG_TOP)
				{
					debug_drawLine(bisector.x, bisector.y, bisector.x, pagePositionUp, blue);
					debug_drawLine(bisector.x, bisector.y, tangentBottom.x, tangentBottom.y, blue);
					debug_drawLine(bisector.x, pagePositionUp, tangentBottom.x, tangentBottom.y, blue);
					
					debug_addPoint(bisector.x, bisector.y, "T0");
					debug_addPoint(bisector.x, pagePositionUp, "T1");
					debug_addPoint(tangentBottom.x, tangentBottom.y, "T2");
					
					debug_drawCircle(0, pagePositionUp, pageWidth, "");
					debug_drawCircle(0, pagePositionDown, pageDiagonal, "");
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
		
		private function debug_clear()
		{
			if (mc_debug)
				removeChild(mc_debug);
			
			mc_debug = new MovieClip();
			mc_debug.mouseEnabled = false;
			mc_debug.mouseChildren = false;
			mc_debug.x = 0;
			mc_debug.y = 0;
			addChild(mc_debug);
			
			mc_debug.visible = false;
		}
		
		private function debug_addPoint(x: Number, y: Number, s:String)
        {
			debug_drawCircle(x, y, 10, s);
		}

        private function debug_drawLine(x1:Number, y1:Number, x2:Number, y2:Number, c:uint)
        {
			var clip:MovieClip = new MovieClip();
			clip.graphics.lineStyle(1, c, 0.6, true, "normal", CapsStyle.ROUND, JointStyle.ROUND, 3);
			clip.graphics.moveTo(x1, y1);
			clip.graphics.lineTo(x2, y2);
			
			mc_debug.addChild(clip);
        }

		private function debug_drawCircle(x: Number, y:Number, radius:Number, text:String)
		{
			var clip:MovieClip = new MovieClip();
			clip.graphics.lineStyle(1, 0, 0.6, true, "normal", CapsStyle.ROUND, JointStyle.ROUND, 3);
			
			if (text == "")
				clip.graphics.beginFill(0xCCCCCC, 0);
			else
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
			
			mc_debug.addChild(clip);
		}
		
		public function get blocked():Boolean { return _blocked; }
		
		public function set blocked(value:Boolean):void 
		{
			_blocked = value;
			
			hotCornerTop.mouseEnabled = !value;
			hotCornerBottom.mouseEnabled = !value;
		}
		
	}
}