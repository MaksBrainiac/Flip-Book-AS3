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
		
		public static var cornerSize:Number 	= 70;
		public static var animationSpeed:Number	= 0.2;
		
		public static var fixedRadius:Number 	= 0;
        public static var pageDiagonal:Number 	= 0;
		
		public static var maskHeight:Number 	= 0;
		public static var maskWidth:Number 		= 0;
		
		public static var shadowWidth:Number 	= 20;
		
		public static var origin:Point;

		public static var pagesContent:/*MovieClip*/Array = [];
		public static var originArea:MovieClip;
		
		private var layoutRoot:MovieClip;
		private var pageArea:MovieClip;

		private var pagesLeft:/*XPage*/Array = [];
		private var pagesRight:/*XPage*/Array = [];

		private var pagesCount: int = 2;
		
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
			
			maskHeight 		= 2 * pageHeight + 2 * pageWidth;
			maskWidth		= pageDiagonal * 2;
			
			// Points
			origin 		= new Point(pageWidth, pageHalfHeight);
			
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
				
				// Create Right Pages AFTER! without need to use regenerate content function
				pagesRight[i] = __createPage(i, XPage.TYPE_RIGHT);
			}

			for (i = 0; i < pagesCount / 2; i++)
			{
				pageArea.addChild(pagesLeft[i].bottomPage);
				pagesLeft[i].visible = false;
			}
			for (i = (pagesCount / 2) - 1; i >= 0; i--)
			{
				pageArea.addChild(pagesRight[i].bottomPage);
				//pagesRight[i].visible = false;
			}
			for (i = (pagesCount / 2) - 1; i >= 0; i--)
			{
				pageArea.addChild(pagesLeft[i]);
				pagesLeft[i].bottomPage.visible = false;
			}
			for (i = 0; i < pagesCount / 2; i++)
			{
				pageArea.addChild(pagesRight[i]);
				//pagesRight[i].visible = false;
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
				if (pagesRight[i].active || pagesRight[i].hover)
					pagesRight[i].mouse = new Point(originArea.mouseX, originArea.mouseY);
			for (i = 0; i < pagesCount / 2; i++)
				if (pagesLeft[i].active || pagesLeft[i].hover)
					pagesLeft[i].mouse = new Point(originArea.mouseX, originArea.mouseY);					
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
				pagesRight[XPage(e.target).index].bottomPage.visible = false;

				pagesLeft[XPage(e.target).index].visible = true;	
				pagesLeft[XPage(e.target).index].bottomPage.visible = true;	
				pagesLeft[XPage(e.target).index].regenerateContent();
				pagesLeft[XPage(e.target).index].resetPosition(XPage.TYPE_LEFT);
			}
			
			if (XPage(e.target).pagePosition == XPage.TYPE_RIGHT) // Change visible page
			{
				//trace(XPage(e.target).pageType);
				
				pagesLeft[XPage(e.target).index].visible = false;
				pagesLeft[XPage(e.target).index].bottomPage.visible = false;

				pagesRight[XPage(e.target).index].visible = true;
				pagesRight[XPage(e.target).index].bottomPage.visible = true;
				pagesRight[XPage(e.target).index].regenerateContent();
				pagesRight[XPage(e.target).index].resetPosition(XPage.TYPE_RIGHT);
			}
		}
		
		private function page_onStartAnimation(e:Event):void 
		{
			dragPage = XPage(e.target);
		}
		
	}
	
}