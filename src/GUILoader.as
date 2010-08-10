package  
{
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Maks Teslenko
	 */
	public class GUILoader extends MovieClip
	{
		
		public function GUILoader() 
		{
			super();
			
			mc_info.txt_value.text = "0%";
		}
		
		public function setDimensions(width:Number, height:Number)
		{
			mc_background.scaleX = width / 100;
			mc_background.scaleY = height / 100;
			
			mc_info.x = width / 2;
			mc_info.y = height / 2;
		}
		
		public function setProgress(value:Number)
		{
			mc_info.txt_value.text = Math.round(value) + "%";
		}
		
	}

}