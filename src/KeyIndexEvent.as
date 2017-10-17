package
{
	import flash.events.Event;
	
	public class KeyIndexEvent extends Event
	{
		public var index:int;
		
		public function KeyIndexEvent(type:String, xIdx:int, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			index = xIdx;
		}
	}
}