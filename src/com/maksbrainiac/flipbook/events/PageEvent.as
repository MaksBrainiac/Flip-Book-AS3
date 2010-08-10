package com.maksbrainiac.flipbook.events
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Maks Teslenko
	 */
	public class PageEvent extends Event
	{
		public static const FLIPPED:String 			= "Flipped";
		public static const ANIMATION_START:String 	= "AnimationStart";
		public static const ANIMATION_END:String 	= "AnimationEnd";
		
		public static const PAGE_LOADED:String 		= "PageLoaded";
		public static const PAGE_CLICKED:String 	= "PageClicked";
		public static const PAGE_CHANGED:String 	= "PageChanged";
		
		public var index:int;
		
		public function PageEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, index:int = 0) 
		{
			super(type, bubbles, cancelable);
			this.index = index;
		}
		
	}

}