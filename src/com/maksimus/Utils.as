package com.maksimus
{
	import flash.text.*;
	
	public class Utils
	{
		public static function debug(variable:*, caption:String = "")
		{
			if (caption != "")
				trace(caption, variable);
			else
				trace(variable);
		}
		
		public static function bold(t:TextField, val:Boolean = true):void
		{
			var tf:TextFormat = t.getTextFormat();
			tf.bold = val;
			t.setTextFormat(tf);
		}
		
		public static function underline(t:TextField):void
		{
			var tf:TextFormat = t.getTextFormat();
			tf.underline = true;
			t.setTextFormat(tf);
			t.defaultTextFormat = tf;
		}

	}
}
	