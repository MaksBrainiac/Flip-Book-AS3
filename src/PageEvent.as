package  
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Maks Teslenko
	 */
	public class PageEvent extends Event
	{
		public static const FLIPPED:String 			= "FLIPPED";
		public static const ANIMATION_START:String 	= "ANIMATION_START";
		public static const ANIMATION_END:String 	= "ANIMATION_END";
		
		public static const PAGE_LOADED:String 		= "PAGE_LOADED";
		public static const PAGE_CLICKED:String 	= "PAGE_CLICKED";
		public static const PAGE_CHANGED:String 	= "PAGE_CHANGED";
		
		public var index:int;
		
		public function PageEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, index:int = 0) 
		{
			super(type, bubbles, cancelable);
			this.index = index;
		}
		
	}

}