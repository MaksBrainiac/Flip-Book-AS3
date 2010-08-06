package 
{
	import fl.motion.Color;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author Maks Teslenko
	 */
	public class Main extends MovieClip 
	{
		public static const TOOLBAR_BOTTOM_HEIGHT:Number 	= 0;
		public static const TOOLBAR_TOP_HEIGHT:Number 		= 0;
		
		public static const grey:uint 						= 0x666666;
		public static const red:uint 						= 0xFF0000;
		public static const blue:uint 						= 0x0000FF;

		public static var clickSpeed:Number 	= 500;
		
		public static var pageWidth:Number 		= 250;
		public static var pageHeight:Number 	= 300;
		public static var pageHalfHeight:Number = 0;
		
		public static var cornerSize:Number 	= 50;
		public static var animationSpeed:Number	= 0.2;
		
		public static var fixedRadius:Number 	= 0;
        public static var pageDiagonal:Number 	= 0;
		
		public static var maskHeight:Number 	= 0;
		public static var maskWidth:Number 		= 0;
		
		public static var origin:Point;
		/////public static var spineTop:Point;
		/////public static var spineBottom:Point;

		public static var pagesContent:/*MovieClip*/Array = [];
		public static var originArea:MovieClip;
		
		private var layoutRoot:MovieClip;
		private var pageArea:MovieClip;

		private var pagesLeft:/*XPage*/Array = [];
		private var pagesRight:/*XPage*/Array = [];

		private var pagesCount: int = 10;
		
		private var dragPage: XPage;
		
		
		/**
		 * Main Constructor
		 */
		public function Main():void 
		{
			init();
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseButtonUpHandler);
			
			//enterFrameHandler(null);
		}
		
		/**
		 * Initialize interface, calculate defaults
		 */
		public function init()
		{
			// Once calculatable variables
			pageHalfHeight 	= pageHeight * 0.5;
			fixedRadius 	= pageWidth;
			pageDiagonal 	= Math.sqrt(pageWidth * pageWidth + pageHeight * pageHeight);
			
			maskHeight 		= pageHeight + 2 * pageWidth;
			maskWidth		= pageDiagonal;
			
			// Points
			origin 		= new Point(pageWidth, pageHalfHeight);
			
			//spineBottom = new Point(0, pageHalfHeight);  // relative to origin ////
            //spineTop 	= new Point(0, -pageHalfHeight); // relative to origin /////
			
			// ------- bzzzzzzz
			//mousez 		= new Point(pageWidth, pageHalfHeight); // relative to origin
			//follow 		= new Point(pageWidth, pageHalfHeight); // relative to origin
			// --------------------------------
			
			
			
			// ----------------- Draw Basic Interface ----------------------------- //
			layoutRoot = new MovieClip();
			layoutRoot.x = (stage.stageWidth - pageWidth * 2) / 2;
			layoutRoot.y = (stage.stageHeight - TOOLBAR_BOTTOM_HEIGHT - TOOLBAR_TOP_HEIGHT - pageHeight) / 2;
			addChild(layoutRoot);
			
			originArea = new MovieClip();
			originArea.x = origin.x;
			originArea.y = origin.y;
			
			pageArea = __createPageArea(); 
			pageArea.addChild(originArea);
			layoutRoot.addChild(pageArea);
			// ----------------- Draw Basic Interface ----------------------------- //
			
			
			// ----------------- Create Pages ------------------------------------- //
			var i;
			
			for (i = 0; i < pagesCount / 2; i++)
			{
				pagesLeft[i] = __createPage(i, XPage.TYPE_LEFT);
				pagesRight[i] = __createPage(i, XPage.TYPE_RIGHT);
			}
			for (i = (pagesCount / 2) - 1; i >= 0; i--)
			{
				pageArea.addChild(pagesRight[i]);
				//trace("add right page", i);
				//pagesRight[i].visible = false;
			}
			for (i = 0; i < pagesCount / 2; i++)
			{
				pageArea.addChild(pagesLeft[i]);
				//trace("add left page", i);
				pagesLeft[i].visible = false;
			}
			// ----------------- Create Pages ------------------------------------- //
		}
		
		private function __createPageArea():MovieClip
		{
			var pageAreaClip:MovieClip = new MovieClip();
			
			var lineColor: uint = 0x666666;
			var fillColor: uint = 0xCCCCCC;
			
			var clip:MovieClip = new MovieClip();
			clip.graphics.lineStyle(1, lineColor, 1, true, "normal", CapsStyle.ROUND, JointStyle.ROUND, 3);
			clip.graphics.beginFill(fillColor, 1);
			clip.graphics.drawRect(0, 0, pageWidth * 2, pageHeight);
			clip.graphics.endFill();
			
			clip.graphics.moveTo(pageWidth, 0);
			clip.graphics.lineTo(pageWidth, pageHeight);
			
			pageAreaClip.addChild(clip);
			
			return pageAreaClip;
		}

		private function __createPage(index:int, type:String)
		{
			var page:MovieClip = new XPage(index, type);
			page.addEventListener("AnimationStarted", page_onStartAnimation);
			page.addEventListener("AnimationComplete", page_onStopAnimation);
			return page;
		}
		
		public static function getPageContent(i:int): MovieClip
		{
			if (pagesContent[i] == null)
			{
				var pageClass:Class = Class(getDefinitionByName("GUIPage" + i % 6));
				var content:MovieClip = new pageClass(); 
				content.cap.caption0.text = i; //  .toString();
				content.cap.caption1.text = i; //  .toString();
				content.cap.caption2.text = i; //  .toString();
				content.cap.caption3.text = i; //  .toString();
				pagesContent[i] = content;
			}
			
			//trace("Show Page", i);
			return pagesContent[i];
		}
		
		public static function getMouseOriginPosition():Point
		{
			var p:Point = new Point(originArea.mouseX, originArea.mouseY);
			return p;
		}
		
		private function mouseMoveHandler(e:MouseEvent):void 
		{
			var i;
			
			for (i = 0; i < pagesCount / 2; i++)
				if (pagesLeft[i].active || pagesLeft[i].hover)
					pagesLeft[i].mouse = new Point(originArea.mouseX, originArea.mouseY);
			for (i = 0; i < pagesCount / 2; i++)
				if (pagesRight[i].active || pagesRight[i].hover)
					pagesRight[i].mouse = new Point(originArea.mouseX, originArea.mouseY);
		}
		
		private function mouseButtonUpHandler(e:MouseEvent):void 
		{
			if (dragPage != null)
			{
				dragPage.deactivateDrag();
				dragPage = null;
			}
		}
		
		private function page_onStopAnimation(e:Event):void 
		{
			//trace("page:", e.target.pageType, "position:", e.target.pagePosition, "index:", e.target.index);
			
			if (XPage(e.target).pagePosition == XPage.TYPE_LEFT) // Change visible page
			{
				//trace(XPage(e.target).pageType);
				
				pagesRight[XPage(e.target).index].visible = false;

				pagesLeft[XPage(e.target).index].visible = true;	
				pagesLeft[XPage(e.target).index].regenerateContent();
				pagesLeft[XPage(e.target).index].resetPosition(XPage.TYPE_LEFT);
			}
			
			if (XPage(e.target).pagePosition == XPage.TYPE_RIGHT) // Change visible page
			{
				//trace(XPage(e.target).pageType);
				
				pagesLeft[XPage(e.target).index].visible = false;

				pagesRight[XPage(e.target).index].visible = true;
				pagesRight[XPage(e.target).index].regenerateContent();
				pagesRight[XPage(e.target).index].resetPosition(XPage.TYPE_RIGHT);
			}
		}
		
		private function page_onStartAnimation(e:Event):void 
		{
			dragPage = XPage(e.target);
			resetZOrder(dragPage);
		}
		
		private function resetZOrder(activePage:XPage)
		{
			// Работает неправильно, так как нужно рассоединить страницу снизу и сверху
			
			//trace(activePage.pageType);
			var i;

			if (activePage.pageType == XPage.TYPE_LEFT)
			{
				/*for (i = (pagesCount / 2) - 1; i >= 0; i--)
					pageArea.addChild(pagesRight[i]);*/
				
				for (i = (pagesCount / 2) - 1; i >= activePage.index; i--)	
					pageArea.setChildIndex(pagesRight[i], pageArea.numChildren - 1);
					
				// Сделать нивидимую страницу слева самой верхней	
				// pageArea.setChildIndex(pagesRight[activePage.index], pageArea.numChildren - 1);
					
				for (i = 0; i < activePage.index; i++)
					pageArea.setChildIndex(pagesLeft[i], pageArea.numChildren - 1);
				for (i = (pagesCount / 2) - 1; i >= activePage.index; i--)
					pageArea.setChildIndex(pagesLeft[i], pageArea.numChildren - 1);
			}				
			
			if (activePage.pageType == XPage.TYPE_RIGHT)
			{
				// Сделать нивидимую страницу самой верхней	
				pageArea.setChildIndex(pagesLeft[activePage.index], pageArea.numChildren - 1);
				
				for (i = (pagesCount / 2) - 1; i > activePage.index; i--)
					pageArea.setChildIndex(pagesRight[i], pageArea.numChildren - 1);
				for (i = 0; i <= activePage.index; i++)
					pageArea.setChildIndex(pagesRight[i], pageArea.numChildren - 1);
					
				/*for (i = 0; i < pagesCount / 2; i++)
					pageArea.addChild(pagesLeft[i]);*/
			}
		}
	}
	
}