package com.maksbrainiac.flipbook.components
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	
	import com.maksbrainiac.flipbook.events.*;
	
	/**
	 * ...
	 * @author Maks Teslenko
	 */
	public class PageObject extends MovieClip
	{
		public var index:int;
		
		public var src:String;
		public var large:String;
		public var href:String;
		
		public var marginTop:Number;
		public var marginBottom:Number;
		
		public var marginLeft:Number;
		public var marginRight:Number;
		
		public var pageWidth:Number;
		public var pageHeight:Number;
		
		public var resize:int;
		public var loaded:Boolean = false;
		
		public var preloader:GUILoader;
		public var loader:Loader;
		public var urlRequest:URLRequest;
		
		public function PageObject(width:Number, height:Number, marginTop:Number = 0, marginBottom:Number = 0, marginLeft:Number = 0, marginRight:Number = 0) 
		{
			pageWidth = width;
			pageHeight = height;
			
			this.marginTop = marginTop;
			this.marginBottom = marginBottom;
			this.marginLeft = marginLeft;
			this.marginRight = marginRight;
			
			preloader = new GUISimpleLoader(pageWidth + marginLeft + marginRight, pageHeight + marginTop + marginBottom);
			addChild(preloader);
		}
		
		private function progressHandler(e:ProgressEvent):void 
		{
			preloader.setProgress(e.bytesLoaded / e.bytesTotal * 100);
		}
		
		private function ioErrorHandler(e:IOErrorEvent):void 
		{
			
		}
		
		private function initHandler(e:Event):void 
		{
			
		}
		
		private function httpStatusHandler(e:HTTPStatusEvent):void 
		{
			
		}
		
		private function completeHandler(e:Event):void 
		{
			if (resize)
			{
				loader.scaleX = (pageWidth + marginLeft + marginRight) / loader.content.width;
				loader.scaleY = (pageHeight + marginTop + marginBottom)  / loader.content.height;
				
				if (loader.content is Bitmap)
				{
					Bitmap(loader.content).smoothing = true;
					loader.addEventListener(MouseEvent.CLICK, mouseClickHandler);
				}
				
				/*if (getQualifiedClassName(loader.content) == 'flash.display::Bitmap')
				{
					Bitmap(loader.content).smoothing = true;
				}*/
			}
			loaded = true;
			dispatchEvent(new PageEvent(PageEvent.PAGE_LOADED, false, false, index));
			
			removeChild(preloader);
			preloader = null;
		}
		
		private function mouseClickHandler(e:MouseEvent):void 
		{
			dispatchEvent(new PageEvent(PageEvent.PAGE_CLICKED, false, false, index));
		}
		
		public function loadContent()
		{
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
            loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            loader.contentLoaderInfo.addEventListener(Event.INIT, initHandler);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			
			urlRequest = new URLRequest(src);
            loader.load(urlRequest);
			
			addChild(loader);

			setChildIndex(preloader, numChildren - 1);
		}
		
	}

}