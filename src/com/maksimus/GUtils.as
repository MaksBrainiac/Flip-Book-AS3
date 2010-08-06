package com.maksimus
{
	import flash.display.Bitmap;
	
	/**
	 * ...
	 * @author Maks Teslenko
	 */
	public class GUtils 
	{
		public static function duplicateImage(original:Bitmap):Bitmap
		{
            return new Bitmap(original.bitmapData.clone());
        }
	}
	
}