package  
{
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Maks Teslenko
	 */
	public class GUILoader extends MovieClip
	{
		public function GUILoader(width:Number = 0, height:Number = 0) 
		{
			super();
			setProgress(0);
			
			if (width > 0)
				setDimensions(width, height);
		}
		
		public function setDimensions(width:Number, height:Number):void {};
		public function setProgress(value:Number):void {};
		
	}

}