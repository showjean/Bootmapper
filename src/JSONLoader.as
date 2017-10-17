package
{
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
		
	public class JSONLoader
	{
		protected var __listener:Function;
		
		protected var urlLoader:URLLoader;
		
		public function JSONLoader()
		{
			
		}
		public function close():void{
			__listener = null;
			if(urlLoader) urlLoader.close();
		}
		
		public function load(xRequest:URLRequest, xListener:Function):void{
			__listener = xListener;
			
			urlLoader = new URLLoader();
			var gRequest:URLRequest = xRequest;	
							
			
			urlLoader.addEventListener(Event.COMPLETE, __onLoad);
			urlLoader.addEventListener(Event.OPEN, __onLoad);
			urlLoader.addEventListener(ProgressEvent.PROGRESS, __onLoad);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, __onSecurityError);
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, __onHTTP);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, __onIOError);
			try {
				urlLoader.load(gRequest);
			} catch (error:Error) {
				trace(this, "Unable to load requested document.");
			}
			
		}
		
		protected function __onHTTP(event:HTTPStatusEvent):void
		{						
			//trace(this, HTTPStatusEvent(event).status);			
		}
		
		protected function __error(event:ErrorEvent):void
		{			
			trace(this, ErrorEvent(event).errorID + ", " + ErrorEvent(event).text + " ....................");	
			__listener(new ErrorEvent(ErrorEvent.ERROR, false, false, ErrorEvent(event).text, int(ErrorEvent(event).errorID)));		
		}
		
		protected function __onSecurityError(event:SecurityErrorEvent):void
		{
			__error(event);		
		}
		protected function __onIOError(event:IOErrorEvent):void
		{
			__error(event);	
		}
		
		protected function __onLoad(event:Event):void
		{
			
				if(__listener == null) return;
				
				switch(event.type){
					case Event.COMPLETE:
						
						try{
							__listener(event);
							
							
						}catch(e:Error){
							__listener(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message, e.errorID));
						}
						
						break;
					
					case ProgressEvent.PROGRESS:							
						__listener(new ProgressEvent(ProgressEvent.PROGRESS, false, false, ProgressEvent(event).bytesLoaded, ProgressEvent(event).bytesTotal));
						break;
				}
		}
	}
}