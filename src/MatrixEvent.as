package
{
	import flash.events.Event;
	
	public class MatrixEvent extends Event
	{
		public var column:int;
		public var row:int;
		
		public function MatrixEvent(type:String, xCol:int, xRow:int, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			column = xCol;
			row = xRow;
		}
	}
}