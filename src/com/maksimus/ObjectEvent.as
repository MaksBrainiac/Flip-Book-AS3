package com.maksimus 
{
	import flash.events.Event;
		
	public class ObjectEvent extends Event 
	{
		public var object:Object;
		
		public function ObjectEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, ob:Object = null)
		{
			super(type, bubbles, cancelable);
			this.object = ob;
		}
	}
	
}