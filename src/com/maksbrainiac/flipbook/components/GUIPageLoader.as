package com.maksbrainiac.flipbook.components
{
	/**
	 * ...
	 * @author Maks Teslenko
	 */
	public class GUIPageLoader extends GUILoader
	{
		
		public function GUIPageLoader(width:Number = 0, height:Number = 0) 
		{
			super(width, height);
		}
		
		override public function setDimensions(width:Number, height:Number):void
		{
			mc_background.scaleX = width / 100;
			mc_background.scaleY = height / 100;
			
			mc_info.x = width / 2;
			mc_info.y = height / 2;
		}
		
		override public function setProgress(value:Number):void
		{
			mc_info.txt_value.text = Math.round(value) + "%";
		}
	}

}