package com.maksbrainiac.common.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Maks Teslenko
	 */
	public class ObjectEvent extends Event
	{
		public var object:Object;
		
		public function ObjectEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, object:Object = null) 
		{
			super(type, bubbles, cancelable);
			this.object = object;
		}
		
	}

}