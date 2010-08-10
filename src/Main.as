package 
{
	import com.maksbrainiac.events.ObjectEvent;
	import fl.motion.Color;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Maks Teslenko
	 */
	public class Main extends MovieClip 
	{
		public static const TOOLBAR_BOTTOM_HEIGHT:Number 	= 0;
		public static const TOOLBAR_TOP_HEIGHT:Number 		= 0;
		
		private var clickSpeed:Number 		= 500;
		private var pageWidth:Number 		= 250;
		private var pageHeight:Number 		= 300;
		private var pageHalfHeight:Number 	= 0;
		private var cornerSize:Number 		= 70;
		private var animationSpeed:Number	= 0.2;
		private var shadowWidth:Number 		= 50;
		
		private var pagesCount: int = 2;
		private var pages:/*PageObject*/Array = [];
		private var pagesLeft:/*XPage*/Array = [];
		private var pagesRight:/*XPage*/Array = [];
		private var loadQuee:Array = [];
		
		private var layoutRoot:MovieClip;
		private var pageArea:MovieClip;
		private var dragPage: XPage;
		private var flashLoader: GUIPageLoader;
		
		private var dataURL:String = "pages.xml";
		
		private var urlRequest:URLRequest;
		private var urlLoader:URLLoader;

		private var _currentPage:int = 0; // On The Right Side, Only even (0,2,4,6...) numbers		
		private var followPage:int = 0; // On The Right Side, Only even (0,2,4,6...) numbers		
		
		private var pageTimer:Timer;
		
		private var flipSpeed:Number = 100;
		
		/**
		 * Main Constructor
		 */
		public function Main():void 
		{
			init();
		}
		
		private function init():void
		{
			flashLoader = new GUIPageLoader(stage.stageWidth, stage.stageHeight);
			addChild(flashLoader);
			
			if (loaderInfo.parameters['data'])
				dataURL = loaderInfo.parameters['data'];

			urlRequest = new URLRequest(dataURL);
			urlLoader = new URLLoader(urlRequest);
			
			urlLoader.addEventListener(Event.COMPLETE, onConfigLoadComplete);
			urlLoader.load(urlRequest);
		}
		
		private function onConfigLoadComplete(e:Event):void 
		{
			var xml:XML = new XML(urlLoader.data);
			if (xml.name() != 'data') {
				trace("Bad Config");
				return; // DIE!!! Wrong Config!
			}
			
			removeChild(flashLoader);
			
			//trace(xml.toXMLString());
			
			pageWidth = Number(xml.@width);
			pageHeight = Number(xml.@height);
			
			pageHalfHeight 	= pageHeight * 0.5;
			
			var i:int = 0;
			
			for each (var pageXML:XML in xml.page)
			{
				var pageObject:PageObject = new PageObject(pageWidth, pageHeight, 
													Number(pageXML.@marginTop), Number(pageXML.@marginBottom),
													Number(pageXML.@marginLeft), Number(pageXML.@marginRight)
												);
				pageObject.index = i++;

				pageObject.src = String(pageXML.@src);
				pageObject.large = String(pageXML.@large);
				pageObject.href = String(pageXML.@href);
				
				pageObject.resize = int(pageXML.@resize);
				pageObject.addEventListener("BitmapPageClick", onPageClicked);
				
				pages.push(pageObject);
				pageLoader_addPage(pageObject);
			}
			
			pagesCount = pages.length;
			initializeBook();
		}
		
		private function onPageClicked(e:Event):void 
		{
			trace("clicked page", PageObject(e.target).index);
		}
		
		private function pageLoader_addPage(page:PageObject)
		{
			loadQuee.push(page);
			if (loadQuee.length == 1) pageLoader_loadNext();
		}
		
		private function pageLoader_loadNext()
		{
			var page:PageObject = loadQuee[0];
			page.addEventListener("PageLoadComplete", pageLoader_onPageLoaded);
			page.loadContent();
		}
		
		private function pageLoader_onPageLoaded(e:Event):void 
		{
			loadQuee.shift();
			if (loadQuee.length > 0) pageLoader_loadNext();
		}
		
		private function gotoPage(page:int)
		{
			if (page % 2 == 1) page++;
			if (page == currentPage) return;
			if (page < 0) return;
			if (page > pagesCount) return; // pagesCount!
			
			//trace('Goto Page: ', page, ' From Page: ', currentPage);
			
			followPage = page;
			pageTimer.start();
			onPageTimer(null);
<<<<<<< HEAD
		}
		
		private function __getTopRightPage()
		{
			return currentPage / 2;
		}
		
		private function __getTopLeftPage()
		{
			return currentPage / 2 - 1;
=======
>>>>>>> 23611fbe212d468e181fc29b6cc12df5d7ca8b5c
		}
		
		private function getRightPageToFlipLeft()
		{
			// Get top not active page
			
			var i;
			
			for (i = currentPage / 2; i < pagesCount / 2; i++)
			{
				//trace("Check ", i - 1, "animated", i - 1 >= 0 ? pagesLeft[i - 1].animated : "??");
				
				if (i - 1 >= 0 && pagesLeft[i - 1].animated && !pagesLeft[i - 1].hover)
					break;
				if (!pagesRight[i].animated || pagesRight[i].mouse.x > 0)
					return i;
			}
			
			return -1;
		}
		
		private function getLeftPageToFlipRight()
		{
			// Get top not active page
			
			var i;
			
			for (i = currentPage / 2 - 1; i >= 0;  i--)
			{
				//trace("Check ", i + 1, "animated", i + 1 < pagesCount / 2 ? pagesLeft[i + 1].animated : "??");
				
				if (i + 1 < pagesCount / 2 && pagesRight[i + 1].animated && !pagesRight[i + 1].hover)
					break;
				if (!pagesLeft[i].animated || pagesLeft[i].mouse.x < 0)
					return i;
			}
			
			return -1;
		}
		
		private function onPageTimer(e:TimerEvent):void 
		{
			if (followPage == currentPage)
			{
				pageTimer.stop();
				return;
			}
			
			var p:int;
			
			//trace("follow Page", followPage, "current Page", currentPage);
			
			if (followPage > currentPage)
			{
				p = getRightPageToFlipLeft();
				if (p != -1 && p < followPage / 2)
				{
					pagesRight[p].flip();
				}
			}
			
			if (followPage < currentPage)
			{
				p = getLeftPageToFlipRight();
				if (p != -1 && p >= followPage / 2)
				{
					pagesLeft[p].flip();
				}
			}
		}

		
		/**
		 * Initialize interface, calculate defaults
		 */
		private function initializeBook()
		{
			// ----------------- Draw Basic Interface ----------------------------- //
			layoutRoot = new MovieClip();
			layoutRoot.x = 0;
			layoutRoot.y = 0;
			addChild(layoutRoot);
			
			pageArea = __createPageArea(); 
			pageArea.y = (stage.stageHeight - TOOLBAR_BOTTOM_HEIGHT - TOOLBAR_TOP_HEIGHT) / 2 + TOOLBAR_TOP_HEIGHT;
			pageArea.x = stage.stageWidth / 2;
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
				pageArea.addChild(pagesLeft[i].frontPage);
				pagesLeft[i].visible = false;
			}
			for (i = (pagesCount / 2) - 1; i >= 0; i--)
			{
				pageArea.addChild(pagesRight[i].frontPage);
				//pagesRight[i].visible = false;
			}
			for (i = (pagesCount / 2) - 1; i >= 0; i--)
			{
				pageArea.addChild(pagesLeft[i]);
				pagesLeft[i].frontPage.visible = false;
			}
			for (i = 0; i < pagesCount / 2; i++)
			{
				pageArea.addChild(pagesRight[i]);
				//pagesRight[i].visible = false;
			}
			// ----------------- Create Pages ------------------------------------- //
			
<<<<<<< HEAD
			if (pagesCount > 0)
				pagesRight[0].blocked = false; // unlock top page only
			
=======
>>>>>>> 23611fbe212d468e181fc29b6cc12df5d7ca8b5c
			for (i = 0; i <= pagesCount / 2; i++)
			{
				var k:int;
				
				var element:MovieClip = MovieClip(getChildByName('bz' + i));
				element.buttonMode = true;
				element.number = i * 2;
				element.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) {
							gotoPage(e.target.number);
						}
					);
			}
				
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseButtonUpHandler);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
			stage.addEventListener(Event.ENTER_FRAME, debugInformation);
			
			pageTimer = new Timer(flipSpeed);
			pageTimer.addEventListener(TimerEvent.TIMER, onPageTimer);
			
			addEventListener("PageChanged", onPageChanged);
		}
		
		private function debugInformation(e:Event):void 
		{
			txt_pagesRight.text = pagesRight.toString();
			txt_pagesLeft.text = pagesLeft.toString();
		}
		
		private function keyboardHandler(e:KeyboardEvent):void 
		{
			var p:int;
			
			switch (e.keyCode)
			{
				case Keyboard.LEFT:
				case Keyboard.PAGE_UP:
					if (dragPage != null) return; // Block if some page dragged
					
					pageTimer.stop();
					
					p = getRightPageToFlipLeft();
					if (p != -1)
						pagesRight[p].flip();
						
					break;
				case Keyboard.RIGHT:
				case Keyboard.PAGE_DOWN:
					if (dragPage != null) return; // Block if some page dragged
					
					pageTimer.stop();
					
					p = getLeftPageToFlipRight();
					if (p != -1)
						pagesLeft[p].flip();
					
					break;
				case Keyboard.HOME:
					if (dragPage != null) return; // Block if some page dragged
					
					gotoPage(0);
					
					break;
				case Keyboard.END:
					if (dragPage != null) return; // Block if some page dragged
					
					gotoPage(pagesCount);
					break;
			}
		}
		
		private function onPageChanged(e:ObjectEvent):void 
		{
			txt_pageNumber_right.text = e.object.page + 1;
			txt_pageNumber_left.text = e.object.page + 0;

			if (currentPage <=0)
				txt_pageNumber_left.text = "";
			if (currentPage >= pagesCount)
				txt_pageNumber_right.text = ""
		}
		
		private function __createPageArea():MovieClip
		{
			var pageAreaClip:MovieClip = new MovieClip();
			
			var lineColor: uint = 0x666666;
			var fillColor: uint = 0xCCCCCC;
			
			var clip:MovieClip = new MovieClip();
			clip.graphics.lineStyle(1, lineColor, 1, true, "normal", CapsStyle.ROUND, JointStyle.ROUND, 3);
			clip.graphics.beginFill(fillColor, 1);
			clip.graphics.drawRect(- pageWidth, - pageHalfHeight, pageWidth * 2, pageHeight);
			clip.graphics.endFill();
			
			clip.graphics.moveTo(0, - pageHalfHeight);
			clip.graphics.lineTo(0, pageHalfHeight);
			
			pageAreaClip.addChild(clip);
			
			return pageAreaClip;
		}

		private function __createPage(index:int, type:String)
		{
			var page:MovieClip = new XPage(index, type, getPage(2 * index), getPage(2 * index + 1), 
				{ cornerSize: cornerSize, shadowWidth:shadowWidth, pageHeight: pageHeight, clickSpeed: clickSpeed, animationSpeed: animationSpeed } 
			);
			page.addEventListener("AnimationStarted", page_onStartAnimation);
			page.addEventListener("AnimationComplete", page_onStopAnimation);
			page.addEventListener("AnimationFlipped", page_onFlipAnimation);
			return page;
		}
		
		private function getPage(i:int)
		{
			return pages[i];
		}
		
		private function mouseMoveHandler(e:MouseEvent):void 
		{
			var i;
			
			for (i = 0; i < pagesCount / 2; i++)
				if (pagesRight[i].active || pagesRight[i].hover)
					pagesRight[i].mouse = new Point(pageArea.mouseX, pageArea.mouseY);
			for (i = 0; i < pagesCount / 2; i++)
				if (pagesLeft[i].active || pagesLeft[i].hover)
					pagesLeft[i].mouse = new Point(pageArea.mouseX, pageArea.mouseY);					
		}
		
		private function mouseButtonUpHandler(e:MouseEvent):void 
		{
			if (dragPage != null)
			{
				dragPage.deactivateDrag();
				dragPage = null;
			}
		}
		
		private function page_onFlipAnimation(e:Event):void 
		{
			// 1. Block all pages from other side
			// 2. Unlock next page from this side
			
			var p:XPage = XPage(e.target);
			
			if (p.pagePosition == XPage.TYPE_RIGHT)
			{
				if (p.index > 0)
					pagesLeft[p.index - 1].blocked = true;
					
				if (p.index + 1 < pagesCount / 2)
					pagesRight[p.index + 1].blocked = false;
			}
			
			if (p.pagePosition == XPage.TYPE_LEFT)
			{
				if (p.index + 1 < pagesCount / 2)
					pagesRight[p.index + 1].blocked = true;
					
				if (p.index > 0)
					pagesLeft[p.index - 1].blocked = false;
			}
		}
		
		private function page_onStopAnimation(e:Event):void 
		{
			//trace("page:", e.target.pageType, "position:", e.target.pagePosition, "index:", e.target.index);
			
			var p:XPage = XPage(e.target);
			
			if (p.pagePosition == XPage.TYPE_LEFT)
			{
				pagesRight[p.index].visible = false;
				pagesRight[p.index].frontPage.visible = false;

				pagesLeft[p.index].visible = true;	
				pagesLeft[p.index].frontPage.visible = true;	
				pagesLeft[p.index].regenerateContent();
				pagesLeft[p.index].resetPosition(XPage.TYPE_LEFT);

				// 1. Unlock landing page
				// 2. Block page before
				pagesLeft[p.index].blocked = false;	
				if (p.index > 0)
					pagesLeft[p.index - 1].blocked = true;	
				
				currentPage = p.index * 2 + 2;
			}
			if (p.pagePosition == XPage.TYPE_RIGHT)
			{
				pagesLeft[p.index].visible = false;
				pagesLeft[p.index].frontPage.visible = false;

				pagesRight[p.index].visible = true;
				pagesRight[p.index].frontPage.visible = true;
				pagesRight[p.index].regenerateContent();
				pagesRight[p.index].resetPosition(XPage.TYPE_RIGHT);

				// 1. Unlock landing page
				// 2. Block page before
				pagesRight[p.index].blocked = false;
				if (p.index + 1 < pagesCount / 2)
					pagesRight[p.index + 1].blocked = true;	
				
				currentPage = p.index * 2;
			}
			
			if (followPage == currentPage) pageTimer.stop();
			dispatchEvent(new ObjectEvent("PageChanged", false, false, { "page": currentPage } ));
		}
		
		private function page_onStartAnimation(e:Event):void 
		{
			var p:XPage = XPage(e.target);
			
			if (p.active)
				dragPage = p;
			
			/*var k:int;
			
			if (p.pagePosition == XPage.TYPE_RIGHT)
			{
				k = __getTopLeftPage();
				if (k >=0 )
					pagesLeft[k].blocked = true;
			}*/
		}
		
		public function get currentPage():int { return _currentPage; }
		
		public function set currentPage(value:int):void 
		{
			_currentPage = value;
			txt_currentPage.text = value.toString();
		}
	}
	
}