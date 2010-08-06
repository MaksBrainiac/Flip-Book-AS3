package com.maksimus 
{
	import flash.display.LoaderInfo;
	import flash.net.LocalConnection;
	import flash.external.ExternalInterface;
	
	/**
	 * ...
	 * @author Maks Teslenko
	 */
	public class FacebookConnection
	{
		public var connection:LocalConnection;
		public var connectionServer:LocalConnection;
		public var connectionName_fb_local:String;
		public var connectionName_fb_fbjs:String;
		
		public var active:Boolean = false;
		public var debugMode:Boolean; 
		
		public function FacebookConnection(loaderInfo:LoaderInfo) 
		{
			connectionName_fb_local = loaderInfo.parameters.fb_local_connection;
			connectionName_fb_fbjs = loaderInfo.parameters.fb_fbjs_connection;
			
			if (connectionName_fb_local != "")
				active = true;
			
			connection = new LocalConnection();
			connectionServer = new LocalConnection();
			connectionServer.allowDomain("*.facebook.com");
			connectionServer.allowDomain("facebook.com");
			connectionServer.allowInsecureDomain('*.facebook.com');
			connectionServer.allowInsecureDomain('facebook.com');
			
			debugMode = (loaderInfo.url.indexOf("http") == -1);
		}
		
		public function getURL(url)
		{
			if (active)
				connection.send(connectionName_fb_local, "navigateToURL", url);
		}
		
		public function callFBJS(methodName:String, ... parameters):void
		{
			if (active)
				connection.send(connectionName_fb_local, "callFBJS", methodName, parameters);
		}
		
		public function firebug(v:*, caption:String = ""):void
		{
			try
			{
				if (debugMode)
					Utils.debug(v, caption);
				else
				{
					if (ExternalInterface.available)
					{
						try
						{
							ExternalInterface.call("debug", v, caption);
						}
						catch (e:Error) {
							callFBJS("debug", v, caption);
						}
					}
					else
						callFBJS("debug", v, caption);
				}
			}
			catch (e:Error) {
				
			}
		}
		
	}

}